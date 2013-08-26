# elixir-postgres

## PostgreSQL Database adapter for Elixir

Implements a low-level connector for Postgres.  This is intended to use as the underlying library for higher-level applications
that will actually respond to incoming messages as desired. 

## Example

See `lib/pg_query.ex` for an example implementation.  Using that:

    {:ok, sock, startup_messages} = PGQuery.connect
    message_list = PGQuery.query(sock, "SELECT NOW()")

The row descriptions and row data still need to be parsed
