defmodule PostgresTest do
  require Postgres
  use ExUnit.Case

  test "connects to the server" do
    {status, _} = Postgres.connect(hostname: {127, 0, 0, 1}, port: 5432)
    assert(status == :ok)
  end

end
