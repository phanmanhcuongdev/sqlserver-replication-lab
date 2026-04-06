# Demo Flow

This demo flow is based on the current SQL scripts in the repository, with the readable execution layout under `setup/` and the original monolithic references under `archive/original_sql/`.

## 1. Start the containers

Start the environment:

```bash
docker compose -f docker/docker-compose.yml up -d
```

## 2. Initialize db1

Run the db1 setup files in the documented execution order.

Validate on `db1`:

- `SchoolDB` exists.
- `dbo.Student` exists.
- The four seed rows exist.
- `dbo.Student_Global` exists.
- `dbo.sp_GlobalInsertStudent` exists.
- `dbo.sp_GlobalUpdateStudent` exists.
- `dbo.sp_GlobalDeleteStudent` exists.
- `StudentPublication_North` exists.
- `StudentPublication_South` exists.

## 3. Initialize db2

Run the db2 setup files in the documented execution order.

Validate on `db2`:

- `SchoolDB_North` exists.
- `DB1_LINK` exists.
- `DB3_LINK` exists.
- `dbo.Student_Global` exists.
- `dbo.sp_GlobalInsertStudent` exists.
- `dbo.sp_GlobalUpdateStudent` exists.
- `dbo.sp_GlobalDeleteStudent` exists.

## 4. Initialize db3

Run the db3 setup files in the documented execution order.

Validate on `db3`:

- `SchoolDB_South` exists.
- `DB1_LINK` exists.
- `DB2_LINK` exists.
- `dbo.Student_Global` exists.
- `dbo.sp_GlobalInsertStudent` exists.
- `dbo.sp_GlobalUpdateStudent` exists.
- `dbo.sp_GlobalDeleteStudent` exists.

## 5. Validate select behavior

On `db1`:

- Query `dbo.Student_Global`.
- The view reads directly from local `dbo.Student`.

On `db2`:

- Query `dbo.Student_Global`.
- The view reads local `dbo.Student` and remote rows from `db3` through `OPENQUERY(DB3_LINK, ...)`.

On `db3`:

- Query `dbo.Student_Global`.
- The view reads local `dbo.Student` and remote rows from `db2` through `OPENQUERY(DB2_LINK, ...)`.

## 6. Validate write behavior

On `db1`:

- Execute `dbo.sp_GlobalInsertStudent`.
- Execute `dbo.sp_GlobalUpdateStudent`.
- Execute `dbo.sp_GlobalDeleteStudent`.

On `db2`:

- Execute `dbo.sp_GlobalInsertStudent`.
- Execute `dbo.sp_GlobalUpdateStudent`.
- Execute `dbo.sp_GlobalDeleteStudent`.
- Each procedure forwards to `db1` through `DB1_LINK`.

On `db3`:

- Execute `dbo.sp_GlobalInsertStudent`.
- Execute `dbo.sp_GlobalUpdateStudent`.
- Execute `dbo.sp_GlobalDeleteStudent`.
- Each procedure forwards to `db1` through `DB1_LINK`.

## 7. Scope note

- The current SQL includes an explicit North subscription setup.
- The current SQL does not include an explicit South subscription setup.
