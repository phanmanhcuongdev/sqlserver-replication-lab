# Execution Order

This execution order is derived from the current SQL scripts preserved in `archive/original_sql/` and organized under `setup/`.

## db1

1. `setup/db1/01_init_database.sql`
2. `setup/db1/02_configure_distribution.sql`
3. `setup/db1/03_enable_publication_db.sql`
4. `setup/db1/04_create_publication_north.sql`
5. `setup/db1/05_create_publication_south.sql`
6. `setup/db1/06_create_snapshot_agents.sql`
7. `setup/db1/07_create_subscription_north.sql`
8. `setup/db1/08_create_global_view.sql`
9. `setup/db1/09_create_global_procedures.sql`

## db2

1. `setup/db2/01_create_destination_db.sql`
2. `setup/db2/02_create_linked_server_to_db1.sql`
3. `setup/db2/03_create_linked_server_to_db3.sql`
4. `setup/db2/04_create_global_view.sql`
5. `setup/db2/05_create_forwarding_procedures.sql`

## db3

1. `setup/db3/01_create_destination_db.sql`
2. `setup/db3/02_create_linked_server_to_db1.sql`
3. `setup/db3/03_create_linked_server_to_db2.sql`
4. `setup/db3/04_create_global_view.sql`
5. `setup/db3/05_create_forwarding_procedures.sql`

## Cross-node behavior

- `db1` is the direct write node in the current SQL implementation.
- `db2` and `db3` forward writes to `db1` through linked-server procedure calls.
- `db2` and `db3` expose a logical full-data read through `dbo.Student_Global`.

## Current implementation limits

- The current SQL explicitly creates a North subscription to `db2`.
- The current SQL does not include a South subscription creation step for `db3`.
