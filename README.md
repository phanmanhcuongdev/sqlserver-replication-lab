# SQL Server Distributed Database Lab

This repository contains a three-node SQL Server lab implemented with Docker Compose and SQL scripts.

The split scripts under `setup/` are the main readable execution structure for the current implementation. The original monolithic scripts are preserved under `archive/original_sql/` as backup references.

## Implemented nodes

- `db1` hosts `SchoolDB`, keeps the full `dbo.Student` table, seeds the initial data set, and acts as distributor and publisher.
- `db2` hosts `SchoolDB_North`, receives the North fragment through the subscription defined in the current SQL, exposes a global read view, and forwards writes to `db1`.
- `db3` hosts `SchoolDB_South`, exposes a global read view, and forwards writes to `db1`.

## Implemented data flow

- Replication is configured on `db1` with two filtered publications:
  - `StudentPublication_North`
  - `StudentPublication_South`
- The current SQL creates one push subscription explicitly:
  - `StudentPublication_North` to `db2`
- `db2` and `db3` use linked servers plus `dbo.Student_Global` to query full logical data across fragment nodes.
- `db2` and `db3` use stored procedures to forward insert, update, and delete requests to `db1`.

## Repository layout

- `sql/`
  - Original monolithic SQL scripts preserved as backup references.
- `setup/db1/`
  - Split db1 setup scripts in execution order.
- `setup/db2/`
  - Split db2 setup scripts in execution order.
- `setup/db3/`
  - Split db3 setup scripts in execution order.
- `archive/original_sql/`
  - Original monolithic SQL scripts preserved for reference.
- `docs/`
  - Documentation aligned to the actual SQL scripts.

## How to start containers

From the repository root:

```bash
docker compose -f docker/docker-compose.yml up -d
```

## Setup documentation

- `docs/SETUP_GUIDE.md`
- `docs/EXECUTION_ORDER.md`
- `docs/ARCHITECTURE.md`
- `docs/DEMO_FLOW.md`

## Fidelity note

If any older note in the repository differs from the SQL scripts, follow the SQL scripts.
