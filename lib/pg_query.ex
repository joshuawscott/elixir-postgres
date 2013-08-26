defmodule PGQuery do

  def connect do
    {:ok, socket} = Postgres.connect
    :ok = Postgres.send socket, Postgres.Message.startup_message("joshua", "joshua")
    {:ok, response} = Postgres.recv socket
    message_list = Postgres.parse_messages response
    {:ok, socket, message_list}
  end

  def query(socket, query) do
    :ok = Postgres.send(socket, Postgres.Message.query(query))
    {:ok, response} = Postgres.recv(socket)
    Postgres.parse_messages response
  end

end
