defmodule Postgres.Message do
  @moduledoc "Defines the messages that can be sent to the PG server.  Use Postgres.send/2 to send these to the server."

  @doc "StartupMessage"
  def startup_message(user, database) do
    message = cstring("user") <> cstring(user) <> cstring("database") <> cstring(database) <> "\0"
    int_to_string(32, String.length(message) + 8) <> int_to_string(32, 196608) <> message
  end

  defp cstring(string), do: <<string :: binary, 0>>

  defp int_to_string(32, num) when num < 2147483648 do
    num |>
      integer_to_binary(16) |>
      String.rjust(8, ?0) |> 
      binary_to_intstring
  end

  defp binary_to_intstring(str), do: binary_to_intstring("", str)
  defp binary_to_intstring(str, ""), do: str
  defp binary_to_intstring(str, <<a, b, t :: binary>>) do
    num = binary_to_integer(<<a, b>>, 16)
    <<str :: binary, num>> |> binary_to_intstring(t)
  end


end

