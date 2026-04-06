# Setup Guide

This guide follows the current SQL scripts exactly as they exist in the repository.

Source SQL files:

- `archive/original_sql/db1.sql`
- `archive/original_sql/db2.sql`
- `archive/original_sql/db3.sql`

The split files under `setup/` preserve the same SQL logic in smaller execution units. The original monolithic files remain preserved in `archive/original_sql/` as backup references.

## Start containers

Start the lab containers from the repository root:

```bash
docker compose -f docker/docker-compose.yml up -d
```

## Setup on db1

Run these files in order on `db1`:

1. `setup/db1/01_init_database.sql`
2. `setup/db1/02_configure_distribution.sql`
3. `setup/db1/03_enable_publication_db.sql`
4. `setup/db1/04_create_publication_north.sql`
5. `setup/db1/05_create_publication_south.sql`
6. `setup/db1/06_create_snapshot_agents.sql`
7. `setup/db1/07_create_subscription_north.sql`
8. `setup/db1/08_create_global_view.sql`
9. `setup/db1/09_create_global_procedures.sql`

What this does on `db1`:

- Creates `SchoolDB` if it does not exist.
- Recreates `dbo.Student`.
- Inserts four sample rows.
- Configures db1 as distributor and publisher.
- Enables publication on `SchoolDB`.
- Creates filtered publications for `North` and `South`.
- Creates snapshot definitions for both publications.
- Creates one explicit push subscription for `db2`.
- Creates `dbo.Student_Global`.
- Creates write procedures for insert, update, and delete.

## Setup on db2

Run these files in order on `db2`:

1. `setup/db2/01_create_destination_db.sql`
2. `setup/db2/02_create_linked_server_to_db1.sql`
3. `setup/db2/03_create_linked_server_to_db3.sql`
4. `setup/db2/04_create_global_view.sql`
5. `setup/db2/05_create_forwarding_procedures.sql`

What this does on `db2`:

- Creates `SchoolDB_North`.
- Creates `DB1_LINK` to `db1`.
- Creates `DB3_LINK` to `db3`.
- Creates `dbo.Student_Global` in `SchoolDB_North`.
- Creates forwarding procedures that call db1 procedures through `DB1_LINK`.

Implementation note for `db2`:

- The SQL scripts do not create `dbo.Student` directly on `db2`.
- The current implementation assumes the local table is available when `dbo.Student_Global` is created.

## Setup on db3

Run these files in order on `db3`:

1. `setup/db3/01_create_destination_db.sql`
2. `setup/db3/02_create_linked_server_to_db1.sql`
3. `setup/db3/03_create_linked_server_to_db2.sql`
4. `setup/db3/04_create_global_view.sql`
5. `setup/db3/05_create_forwarding_procedures.sql`

What this does on `db3`:

- Creates `SchoolDB_South`.
- Creates `DB1_LINK` to `db1`.
- Creates `DB2_LINK` to `db2`.
- Creates `dbo.Student_Global` in `SchoolDB_South`.
- Creates forwarding procedures that call db1 procedures through `DB1_LINK`.

Implementation note for `db3`:

- The SQL scripts do not create `dbo.Student` directly on `db3`.
- The current implementation assumes the local table is available when `dbo.Student_Global` is created.

## Source-of-truth note

If any older planning document differs from the current SQL files, follow the SQL files.
