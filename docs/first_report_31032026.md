Technical Report: Troubleshooting SQL Server Replication in a Docker-Based Distributed Database Lab
1. Overview

This report documents a real-world troubleshooting session for building a distributed database demo using SQL Server replication on Docker containers. The goal was to implement a horizontally fragmented database setup where a central SQL Server instance held the full dataset and published filtered fragments to two subscriber nodes.

The work was not a pure research exercise. It was a practical lab aligned with a classroom demo scenario, based on SQL Server replication rather than a custom distributed data synchronization mechanism.

The session exposed several important engineering realities:

SQL Server replication behaves differently in Docker than in a traditional Windows-hosted SQL Server deployment.
SSMS wizards are convenient, but they can become misleading when the execution context differs from the GUI client context.
Internal SQL Server identity, Docker container networking, SQL Server Agent availability, and distributor metadata consistency are all critical for a successful replication setup.

This report explains what went wrong, why it went wrong, and how each issue was resolved.

2. System Architecture
2.1 Deployment Model

The system was deployed using Docker containers on a Linux-based environment under WSL.

Three SQL Server containers were used:

sql1 → primary server, publisher, and distributor
sql2 → subscriber node for fragment A
sql3 → subscriber node for fragment B

2.2 External Access Model

From the host machine, the SQL Server instances were accessed through published ports:

localhost,1434 → sql1
localhost,1435 → sql2
localhost,1436 → sql3

2.3 Internal Docker Network Model

Inside Docker, the containers communicated using container names and default SQL Server port 1433:

sql1
sql2
sql3

This distinction became one of the most important technical factors in the debugging process.

2.4 Data Model

The database DDB contained the following tables:

Customers
Employees
Pizzas
Orders
OrderItems
Payments

The distributed demo focused on the Orders table.

2.5 Fragmentation Strategy

Horizontal fragmentation was implemented using transactional replication with row filters:

Fragment A: OrderID <= 3
Fragment B: OrderID >= 4

This was better than a fixed 1–3 and 4–6 split because it allowed future inserts with higher IDs to continue flowing into fragment B.

3. Issues Encountered
3.1 Replication Wizard Failed Due to Invalid Snapshot Working Directory
Symptoms

During distributor configuration, SQL Server reported:

invalid working directory
snapshot folder issues related to /var/opt/mssql/ReplData

Root Cause

The replication snapshot working directory had not been created inside the SQL Server container. SQL Server replication expected the snapshot folder to exist and be accessible to the SQL Server service account.

Why It Happened

In containerized deployments, filesystem paths must exist inside the container namespace. Unlike a Windows-hosted SQL Server setup where folders may be more obvious or preconfigured, the Docker container started without the required replication snapshot directory.

Fix

Created the directory inside sql1:

docker exec -it sql1 bash
mkdir -p /var/opt/mssql/ReplData
chown -R mssql:mssql /var/opt/mssql/ReplData

This established a valid snapshot working directory for replication.

3.2 Distributor Appeared Configured but Was Actually in a Broken State
Symptoms

After running the configuration wizard, SSMS no longer showed Configure Distribution, but later operations failed with distributor-related errors such as:

distributor not installed correctly
inconsistent replication metadata
inability to enable publishing for database DDB

Root Cause

The initial distribution setup failed partially. SQL Server stored enough metadata for SSMS to think distribution had already been configured, but the configuration was not actually usable.

Why It Happened

Replication setup is metadata-heavy. If configuration fails midway, SQL Server may persist incomplete distributor state. SSMS then hides the original wizard option and assumes distribution exists, even though downstream operations fail.

Fix

Disabled publishing and distribution, then cleaned up replication-related metadata and distribution database state.

Attempted cleanup steps included:

USE master;
GO
EXEC sp_dropdistributor @no_checks = 1, @ignore_distributor = 1;
GO

Also used cleanup patterns such as:

USE master;
GO
EXEC sp_removedbreplication @dbname = N'DDB';
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = N'distribution')
BEGIN
    ALTER DATABASE distribution SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE distribution;
END
GO

This was part of the recovery process before recreating replication cleanly.

3.3 SQL Server Internal Name Mismatch Broke Replication
Symptoms

Replication actions failed even though connections to localhost,1434 worked normally. The internal metadata showed inconsistent naming such as:

LOCALHOST
localhost,1434
sql1

The query:

SELECT @@SERVERNAME;

returned sql1, while the operator was connecting through localhost,1434.

Root Cause

SQL Server replication depends heavily on the internal server identity stored in SQL Server metadata. The host connection endpoint and the SQL Server internal server name were being mixed incorrectly during configuration.

Why It Happened

In Docker, the actual SQL Server instance identity is usually the container hostname, not the host-side mapped endpoint. The replication engine uses the internal server identity, not the SSMS connection label.

An incorrect assumption was briefly made that @@SERVERNAME should be changed to localhost,1434. That turned out to be wrong for replication in this environment.

Fix

After experimentation, the correct approach was to keep the internal SQL Server name as sql1, not localhost,1434.

The environment was reset so that:

SELECT @@SERVERNAME;

returned:

sql1

This aligned replication metadata with the actual container identity.

Incorrect Assumption Noted

At one point, it seemed attractive to rename the server internally to localhost,1434 so that it matched SSMS. That approach caused sp_adddistpublisher and distribution configuration to treat the server as if it were remote. In Docker, the correct internal identity is the container hostname, not the host-mapped endpoint.

3.4 SQL Server Agent Was Not Running
Symptoms

Replication stored procedures failed or produced messages involving SQL Server Agent not running. Distribution cleanup and setup behaved inconsistently.

Root Cause

The container was launched without SQL Server Agent enabled.

Why It Happened

SQL Server Agent is not automatically enabled in SQL Server Linux containers unless explicitly configured. Transactional replication depends on several agent jobs:

Snapshot Agent
Log Reader Agent
Distribution Agent

Without SQL Server Agent, replication metadata may exist, but the actual replication jobs cannot operate correctly.

Fix

Updated Docker Compose so that the SQL Server container included:

environment:
  ACCEPT_EULA: "Y"
  MSSQL_SA_PASSWORD: "Pcuong@2411"
  MSSQL_AGENT_ENABLED: "true"

Then recreated the container:

docker compose up -d --force-recreate sql1

Confirmed the environment variable inside the container:

docker exec -it sql1 bash
printenv MSSQL_AGENT_ENABLED

Expected result:

true

This enabled SQL Server Agent properly.

3.5 Distributor Metadata Registered Wrong Publisher Name
Symptoms

Running replication metadata inspection showed the publisher as LOCALHOST instead of sql1.

This caused SSMS to insist that the server had not been enabled properly as a publisher, despite previous configuration steps.

Root Cause

Early wizard-driven configuration recorded the publisher incorrectly as LOCALHOST, which did not match the actual SQL Server internal identity sql1.

Why It Happened

The SSMS wizard was operating from the host machine and mixed GUI connection identity with SQL Server internal identity. As a result, the wrong publisher name ended up in distributor metadata.

Fix

Dropped the incorrect publisher entry and added the correct one:

EXEC sp_dropdistpublisher 
    @publisher = N'LOCALHOST', 
    @no_checks = 1;
GO

Then added the correct publisher:

EXEC sp_adddistpublisher
    @publisher = N'sql1',
    @distribution_db = N'distribution',
    @security_mode = 1,
    @working_directory = N'/var/opt/mssql/ReplData';
GO

Finally enabled publishing for DDB:

EXEC sp_replicationdboption
    @dbname = N'DDB',
    @optname = N'publish',
    @value = N'true';
GO

After this, publication creation succeeded.

3.6 Subscriber Database Creation Failed Due to model Locking
Symptoms

While creating a subscription through SSMS, subscriber-side database creation failed with an error indicating that SQL Server could not obtain an exclusive lock on model.

Root Cause

The wizard attempted to create the subscriber database automatically, but model was locked by another operation or internal state.

Why It Happened

SQL Server creates a new database using model as a template. If model is not available for an exclusive lock, database creation fails.

Fix

Instead of relying on the wizard to create subscriber databases, the databases were created manually on sql2 and sql3:

IF DB_ID('DDB') IS NULL
    CREATE DATABASE DDB;
GO

This bypassed the problematic automatic creation path and simplified subscription setup.

3.7 Snapshot Agent Succeeded but Subscriber Received No Data
Symptoms

Publication creation and snapshot generation succeeded, but querying Orders on the subscriber returned no rows.

Root Cause

The subscription existed, but the Distribution Agent could not connect to the subscriber correctly.

Why It Happened

The subscription had been created using localhost,1435 as the subscriber name. That worked from the host machine, but the Distribution Agent runs inside sql1, where localhost refers to the sql1 container itself, not sql2.

This was the most important networking issue in the entire session.

Technical Explanation

There were two different network contexts:

Host Machine Context

From the host OS and SSMS:

localhost,1434 → sql1
localhost,1435 → sql2
localhost,1436 → sql3

Docker Container Context

From inside sql1:

sql2:1433 → sql2
sql3:1433 → sql3
localhost → sql1 itself

The replication agent does not run in SSMS. It runs inside the SQL Server/Agent environment. Therefore the subscriber definition had to be valid from inside Docker, not just from the host.

Verification

Connectivity from sql1 to sql2 was verified directly:

docker exec -it sql1 bash
/opt/mssql-tools18/bin/sqlcmd -S sql2 -U sa -P 'Pcuong@2411' -C -Q "SELECT @@SERVERNAME"

Expected output:

sql2

This confirmed that Docker internal networking was functioning correctly.

Incorrect Assumption Noted

A very common misunderstanding appeared during debugging:

Since SSMS sends commands to SQL Server, it should not matter whether the subscriber name is resolvable from the host.

This is only partially true. SSMS creates replication metadata, but the actual replication work is done by agent jobs. Those agent jobs run inside SQL Server/Agent context, not inside SSMS, so subscriber names must be valid from the runtime execution environment.

Fix

The subscriber should have been defined as sql2 and sql3, not localhost,1435 and localhost,1436.

However, SSMS wizard connectivity validation itself ran from the host, so entering sql2 in the GUI did not work reliably from Windows.

The practical solution was to stop relying on the GUI for subscription creation and create subscriptions directly through T-SQL.

3.8 SSMS Wizard Was Unsuitable for Subscriber Creation in This Docker Topology
Symptoms

The user could connect to subscribers from sql1 internally, but the SSMS Add Subscriber dialog could not reliably connect using container names such as sql2.

Root Cause

The SSMS wizard was validating connectivity from the host machine, while the replication agents required subscriber names that were valid from within Docker.

Why It Happened

This is a classic split-context issue:

GUI context = host Windows machine
runtime replication context = Docker container network

SSMS wizard is optimized for traditional server environments, not mixed host/container network models.

Fix

Subscription creation was moved from GUI workflow to T-SQL.

For fragment A:

USE DDB;
GO

EXEC sp_addsubscription
    @publication = N'Orders_Fragment_A',
    @subscriber = N'sql2',
    @destination_db = N'DDB',
    @subscription_type = N'Push',
    @sync_type = N'automatic',
    @article = N'all',
    @update_mode = N'read only';
GO

Then the push subscription agent:

EXEC sp_addpushsubscription_agent
    @publication = N'Orders_Fragment_A',
    @subscriber = N'sql2',
    @subscriber_db = N'DDB',
    @job_login = NULL,
    @job_password = NULL,
    @subscriber_security_mode = 0,
    @subscriber_login = N'sa',
    @subscriber_password = N'Pcuong@2411',
    @frequency_type = 64;
GO

This approach succeeded, and data was replicated to sql2.

4. Root Cause Analysis

The failures were not caused by a single bug. They were caused by an interaction of four independent factors:

4.1 Mismatch Between Host Connectivity and Runtime Connectivity

The host machine saw instances through localhost with mapped ports, but replication agents ran inside containers and required Docker hostnames.

4.2 Replication Relies on Internal SQL Server Identity

Replication is sensitive to @@SERVERNAME, distributor metadata, and publisher identity. GUI labels are not authoritative.

4.3 SQL Server Agent Is Mandatory

Without SQL Server Agent, replication metadata may partially exist, but jobs cannot run correctly.

4.4 SSMS Wizards Are Not Neutral

The wizard experience assumes a relatively consistent networking model. In this Docker setup, that assumption was false, especially for subscriber creation.

5. Solutions & Fixes
5.1 Final Working Strategy

The working approach was:

Keep SQL Server internal names as Docker hostnames:
sql1
sql2
sql3

Access servers from the host using:
localhost,1434
localhost,1435
localhost,1436

Enable SQL Server Agent explicitly with:
MSSQL_AGENT_ENABLED=true

Create replication snapshot folder in sql1:
/var/opt/mssql/ReplData

Create publications on sql1

Use GUI carefully for publication setup only

Use T-SQL to create subscriptions so that subscriber names are:
sql2
sql3

5.2 Publication Design

Fragment A publication filter:

[OrderID] <= 3

Fragment B publication filter:

[OrderID] >= 4

This design ensured future inserts were still routed into fragment B, unlike a fixed 4–6 filter.

5.3 Subscription Validation

After successful subscription creation, data was verified on subscriber nodes.

For sql2:

USE DDB;
SELECT * FROM Orders;

Expected result:

rows with OrderID <= 3

For sql3:

rows with OrderID >= 4

6. Lessons Learned
6.1 In Docker, localhost Is Almost Never the Right Replication Identity

localhost is meaningful only from the current machine or container. Replication agents running inside containers must use names resolvable within Docker networking.

6.2 SQL Server Internal Identity Matters More Than SSMS Connection Labels

For replication, @@SERVERNAME and distributor publisher metadata are authoritative. A working SSMS connection string does not prove replication metadata is correct.

6.3 SQL Server Agent Must Be Planned Up Front

On Linux/Docker SQL Server, Agent is not implicitly available. Replication setup should not begin until Agent is confirmed running.

6.4 GUI Wizards Are Helpful but Not Sufficient

Wizards are useful for understanding the replication flow, but in containerized topologies they can become misleading. T-SQL provides better control and more predictable behavior.

6.5 Manual Creation of Subscriber Databases Is Often Better

Allowing the wizard to create databases introduced avoidable issues. Precreating subscriber databases gave more control and removed one failure point.

6.6 Split-Context Debugging Is Essential

There were two environments involved at all times:

host/SSMS context
container/runtime context

Debugging became much easier once every failing step was analyzed according to which context it actually ran in.

7. Recommendations
7.1 Recommended Setup Pattern for Future Docker-Based SQL Server Replication Labs
Before Starting Replication

ensure all containers are reachable
confirm internal SQL Server names with @@SERVERNAME
keep internal names as container hostnames
verify SQL Server Agent is running
create snapshot folder inside publisher/distributor container

During Configuration

use SSMS for distributor and publication setup if desired
avoid using host-style subscriber names in final replication metadata
precreate subscriber databases manually

For Subscription Creation

prefer T-SQL over SSMS wizard
use Docker hostnames (sql2, sql3) for subscribers
validate cross-container connectivity with sqlcmd

For Troubleshooting

always distinguish:
where the GUI is running
where the replication job is running
inspect replication metadata explicitly
do not assume wizard success means runtime success

7.2 Best Practices

Keep Docker service names stable and meaningful
Avoid renaming SQL Server internal identity to host-mapped endpoints
Automate replication setup with scripts wherever possible
Record exact distributor, publisher, and subscriber names used
Verify agent jobs and connectivity before troubleshooting publication logic
Treat host networking and container networking as separate systems

8. Conclusion

The distributed database lab was ultimately successful, but only after moving away from a purely wizard-driven mindset and debugging the system as a real distributed runtime.

The major engineering insight was this:

Replication configuration is not only about SQL objects. It is also about execution context, network scope, service identity, and runtime agent behavior.

For engineers building SQL Server replication in Docker, the most important rule is simple:

Use host ports for human access, but use container hostnames for server-to-server replication.

That single principle explains most of the observed failures and most of the successful fixes.

If you want, I can turn this into a polished .docx report with headings, code blocks, and a clean submission format.