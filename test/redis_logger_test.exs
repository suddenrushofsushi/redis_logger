defmodule RedisLoggerTest do
  require Logger
  use ExUnit.Case

  Logger.add_backend({RedisLogger, :default})

  setup_all do
    {:ok, conn} = Redix.start_link("redis://localhost:6379/0")
    Redix.command(conn, ~w(del elixir_logs))
    [conn: conn]
  end

  test "logs to the default key", %{conn: conn} do
    Logger.warn "Testing"
    :timer.sleep(100)
    {:ok, [result]} = Redix.command(conn, ~w(zrange elixir_logs 0 -1))
    expected = result |> Poison.decode! |> Map.get("message")
    assert expected == "Testing"
  end

end
