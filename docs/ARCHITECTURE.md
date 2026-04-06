# Architecture

This document reflects the current implementation preserved in `archive/original_sql/db1.sql`, `archive/original_sql/db2.sql`, and `archive/original_sql/db3.sql`, and organized for execution under `setup/`.

If any older note in the repository differs from the SQL scripts, follow the SQL scripts.

## Node roles

### db1

- Hosts `SchoolDB`.
- Creates and owns `dbo.Student`.
- Inserts the initial sample data.
- Configures distribution on the same server.
- Enables publication on `SchoolDB`.
- Creates two filtered publications:
  - `StudentPublication_North`
  - `StudentPublication_South`
- Creates snapshot definitions for both publications.
- Creates one explicit push subscription in the current SQL:
  - `StudentPublication_North` to `db2` into `SchoolDB_North`
- Exposes `dbo.Student_Global` as a local view over `dbo.Student`.
- Exposes direct write procedures:
  - `dbo.sp_GlobalInsertStudent`
  - `dbo.sp_GlobalUpdateStudent`
  - `dbo.sp_GlobalDeleteStudent`

### db2

- Hosts `SchoolDB_North`.
- Creates linked server `DB3_LINK` to `db3`.
- Creates linked server `DB1_LINK` to `db1`.
- Exposes `dbo.Student_Global` as:
  - local `dbo.Student`
  - `UNION ALL`
  - remote rows from `SchoolDB_South.dbo.Student` through `OPENQUERY(DB3_LINK, ...)`
- Exposes forwarding procedures:
  - `dbo.sp_GlobalInsertStudent`
  - `dbo.sp_GlobalUpdateStudent`
  - `dbo.sp_GlobalDeleteStudent`
- Each forwarding procedure calls the matching procedure on `db1` through `DB1_LINK`.

### db3

- Hosts `SchoolDB_South`.
- Creates linked server `DB2_LINK` to `db2`.
- Creates linked server `DB1_LINK` to `db1`.
- Exposes `dbo.Student_Global` as:
  - local `dbo.Student`
  - `UNION ALL`
  - remote rows from `SchoolDB_North.dbo.Student` through `OPENQUERY(DB2_LINK, ...)`
- Exposes forwarding procedures:
  - `dbo.sp_GlobalInsertStudent`
  - `dbo.sp_GlobalUpdateStudent`
  - `dbo.sp_GlobalDeleteStudent`
- Each forwarding procedure calls the matching procedure on `db1` through `DB1_LINK`.

## Read path

### Read on db1

- `dbo.Student_Global` reads directly from `dbo.Student`.

### Read on db2

- `dbo.Student_Global` reads local `dbo.Student`.
- `dbo.Student_Global` reads remote data from `db3` through `OPENQUERY(DB3_LINK, ...)`.
- The final result is assembled with `UNION ALL`.

### Read on db3

- `dbo.Student_Global` reads local `dbo.Student`.
- `dbo.Student_Global` reads remote data from `db2` through `OPENQUERY(DB2_LINK, ...)`.
- The final result is assembled with `UNION ALL`.

## Write path

### Write on db1

- `dbo.sp_GlobalInsertStudent` inserts into `dbo.Student`.
- `dbo.sp_GlobalUpdateStudent` updates `dbo.Student`.
- `dbo.sp_GlobalDeleteStudent` deletes from `dbo.Student`.

### Write on db2

- `dbo.sp_GlobalInsertStudent` executes `DB1_LINK.SchoolDB.dbo.sp_GlobalInsertStudent`.
- `dbo.sp_GlobalUpdateStudent` executes `DB1_LINK.SchoolDB.dbo.sp_GlobalUpdateStudent`.
- `dbo.sp_GlobalDeleteStudent` executes `DB1_LINK.SchoolDB.dbo.sp_GlobalDeleteStudent`.

### Write on db3

- `dbo.sp_GlobalInsertStudent` executes `DB1_LINK.SchoolDB.dbo.sp_GlobalInsertStudent`.
- `dbo.sp_GlobalUpdateStudent` executes `DB1_LINK.SchoolDB.dbo.sp_GlobalUpdateStudent`.
- `dbo.sp_GlobalDeleteStudent` executes `DB1_LINK.SchoolDB.dbo.sp_GlobalDeleteStudent`.

## Replication scope currently implemented

- `db1` creates `StudentPublication_North`.
- `db1` creates `StudentPublication_South`.
- `db1` creates snapshot definitions for both publications.
- `db1` creates one explicit push subscription for the North publication to `db2`.

## Implementation notes

- The current SQL does not include a South subscription creation step for `db3`.
- The current SQL does not implement trigger-based distributed DML.
- The current SQL does not implement multi-master replication.
- The current SQL does not show direct table DML on `db2` or `db3` as the distributed write entry point.
- The current SQL does not show `db2` or `db3` storing full physical data sets.
