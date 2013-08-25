defmodule Postgres do
  require Postgres.Message
  @doc """
  takes a list of optional keywords:
    hostname: string or atom of host name, or IP address as Tuple.  default: 127.0.0.1
    port: integer port number. default: 5432
    tcp_options: List of tcp_options (see Erlang's gen_tcp:connect/4) - options include :inet, :inet6.  default: [:binary, {:active, false}]
    timeout: timeout in milliseconds for the TCP connection. default: 5000

  Returns {:ok, socket} or {:error, reason}
  """
  def connect(opts) do
    opts = normalize_connect_opts(opts)
    tcp_connect(opts[:hostname], opts[:port], opts[:tcp_options], opts[:timeout])
  end

  @doc "convenience function to call connect/1 with all defaults"
  def connect, do: connect([])

  @doc """
  takes a socket and a string to send.
  ## Example:

      {:ok, socket} = Postgres.connect
      :ok = Postgres.send(socket, Postgres.Message.startup_message("elixir_test_user", "elixir_test"))
      {:ok, response} = Postgres.recv(socket)

  """
  def send(socket, message), do: :gen_tcp.send(socket, message)

  @doc """
  Receives network messages
  Returns {:ok, binary} or {:error, reason}
  see Postgres.send for example
  """
  def recv(socket, timeout // :infinity), do: :gen_tcp.recv(socket, 0, timeout)

  defp normalize_connect_opts(opts) do
    default_opts = [
      hostname: {127, 0, 0, 1},
      port: 5432,
      tcp_options: [:binary, {:active, false}],
      timeout: 5000]
    Keyword.merge(opts, default_opts,
      fn(_k, opt, _defaultopt) -> opt
      end)
  end

  defp tcp_connect(address, port, options, timeout // 5000) do
    :gen_tcp.connect(address, port, options, timeout)
  end

  def parse_messages(binary) do
    binary_to_message_list(binary, [])
  end

  def binary_to_message_list("", list), do: list
  def binary_to_message_list(<<a,b,c,d,e,rest :: binary>>, list) do
    type = type_from_id_char(a)
    length = b * 4096 + c * 256 + d * 16 + e
    body = String.slice(rest, 0, length - 4)
    remainder = String.slice(rest, length - 4, String.length(rest))
    binary_to_message_list(remainder, list ++ [{type, length, body}])
  end

  # Convert from a single char to the atom that matches the message name
  @doc """
  takes a char and gives a snake_cased atom that matches the message name.
  example:

    "1" (actually 49) is ParseComplete, so it returns: :parse_complete

  :unknown is returned if the char is not known.  This shouldn't happen unless
  PostgreSQL implements new message types.
  """
  def type_from_id_char(?1), do: :parse_complete
  def type_from_id_char(?2), do: :bind_complete
  def type_from_id_char(?3), do: :close_complete
  def type_from_id_char(?A), do: :notification_response
  def type_from_id_char(?C), do: :command_complete
  def type_from_id_char(?c), do: :copy_done
  def type_from_id_char(?D), do: :data_row
  def type_from_id_char(?d), do: :copy_data
  def type_from_id_char(?E), do: :error_response
  def type_from_id_char(?G), do: :copy_in_response
  def type_from_id_char(?H), do: :copy_out_response
  def type_from_id_char(?I), do: :empty_query_response
  def type_from_id_char(?K), do: :backend_key_data
  def type_from_id_char(?N), do: :notice_response
  def type_from_id_char(?n), do: :no_data
  def type_from_id_char(?R), do: :authentication_message
  def type_from_id_char(?S), do: :parameter_status
  def type_from_id_char(?s), do: :portal_suspended
  def type_from_id_char(?T), do: :row_description
  def type_from_id_char(?t), do: :parameter_description
  def type_from_id_char(?V), do: :function_call_response
  def type_from_id_char(?W), do: :copy_both_response
  def type_from_id_char(?Z), do: :ready_for_query
  def type_from_id_char(_other_val), do: :unknown


end
