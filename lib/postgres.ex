defmodule Postgres do
  require Postgres.Message
  @doc """
  takes a list of optional keywords:
  hostname: string or atom of host name, or IP address as Tuple.  default: 127.0.0.1
  port: integer port number. default: 5432
  tcp_options: List of tcp_options (see Erlang's gen_tcp:connect/4) - options include :inet, :inet6.  default: [:binary, {:active, false}]
  timeout: timeout in milliseconds for the TCP connection. default: 5000

  Returns a TCP socket
  """
  def connect(opts) do
    opts = normalize_connect_opts(opts)
    tcp_connect(opts[:hostname], opts[:port], opts[:tcp_options], opts[:timeout])
  end

  @doc "convenience function to call connect/1 with all defaults"
  def connect, do: connect([])

  @doc """
  takes a socket and a string to send.
  Example:
  {:ok, socket} = Postgres.connect
  :ok = Postgres.send(socket, Postgres.Message.startup_message("user", "dbname"))
  {:ok, response} = Postgres.recv(socket)
  """
  def send(socket, message), do: :gen_tcp.send(socket, message)

  @doc "receives network messages"
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

end
