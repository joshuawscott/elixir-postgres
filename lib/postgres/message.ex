defmodule Postgres.Message do
  @moduledoc "Defines the messages that can be sent to the PG server.  Use Postgres.send/2 to send these to the server."

  @doc "Query"
  def query(query_string) do
    "Q" <> int_to_string(32, String.length(query_string) + 5) <> cstring(query_string)
  end

  @doc "StartupMessage"
  def startup_message(user, database) do
    message = cstring("user") <> cstring(user) <> cstring("database") <> cstring(database) <> "\0"
    int_to_string(32, String.length(message) + 8) <> int_to_string(32, 196608) <> message
  end

  defp cstring(string), do: <<string :: binary, 0>>

  defp int_to_string(32, num) when num <= 2147483647, do: do_int_to_string(8, num)
  defp int_to_string(16, num) when num <= 32767, do: do_int_to_string(4, num)
  defp int_to_string(8, num) when num <= 127, do: do_int_to_string(2, num)
  defp int_to_string(bits, _num) when bits == 32 or bits == 16 or bits == 8, do: ArgumentError[message: "Length too large"]
  defp int_to_string(_bits, _num), do: ArgumentError[message: "Bad bitsize"]

  defp do_int_to_string(size, num) do
    num |>
      integer_to_binary(16) |>
      String.rjust(size, ?0) |> 
      binary_to_intstring
  end

  defp binary_to_intstring(str), do: binary_to_intstring("", str)
  defp binary_to_intstring(str, ""), do: str
  defp binary_to_intstring(str, <<a, b, t :: binary>>) do
    num = binary_to_integer(<<a, b>>, 16)
    <<str :: binary, num>> |> binary_to_intstring(t)
  end


end

