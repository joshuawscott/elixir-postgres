defmodule Postgres.MessageTest do
  require Postgres.Message
  use ExUnit.Case

  test "Query" do
    query = "SELECT NOW() AS cur_time"
    expected = <<?Q, 0,0,0,29, query :: binary, 0>>
    assert(expected == Postgres.Message.query(query))
  end

  test "StartupMessage" do
    expected = <<0,0,0,35,0,3,0,0,"user", 0, "jdoe", 0, "database", 0, "dbname", 0, 0>>
    assert(expected == Postgres.Message.startup_message("jdoe", "dbname"))
  end


end
