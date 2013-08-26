defmodule PostgresTest do
  require Postgres
  use ExUnit.Case

  test "connects to the server" do
    {status, _} = Postgres.connect(hostname: {127, 0, 0, 1}, port: 5432)
    assert(status == :ok)
  end

  test "Parses packet response into messages" do
    # This is a network packet with two messages: 'K' and 'C' denote the beginning of the message.
    netchunk = <<"K", 0, 0, 0, 12, 0, 0, 0, 1, 0, 0, 0, 2, "C", 0, 0, 0, 13, "SELECT 1", 0>>
    expected = [{:backend_key_data, 12, <<0,0,0,1,0,0,0,2>>},{:command_complete, 13, "SELECT 1\0"}]
    assert(Postgres.parse_messages(netchunk) == expected)
  end

  #test "Parses incomplete packet response into messages, plus incomplete message" do
  #  assert(TODO)
  #end

end
