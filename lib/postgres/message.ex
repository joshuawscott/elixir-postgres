defmodule Postgres.Message do
  @moduledoc "Defines the messages that can be sent to the PG server.  Use Postgres.send/2 to send these to the server."

  @doc "Query"
  def query(query_string) do
    <<"Q", String.length(query_string) + 5 :: 32, cstring(query_string) :: binary >>
  end

  @doc "StartupMessage"
  def startup_message(user, database) do
    message = <<cstring("user") :: binary,
      cstring(user) :: binary,
      cstring("database") :: binary,
      cstring(database) :: binary,
      "\0" >>
    << String.length(message) + 8 :: 32, 196608 :: 32, message :: binary >>
  end

  defp cstring(string), do: <<string :: binary, 0>>

end

