defmodule RedisLogger do
  @moduledoc ~S"""
  """

  use GenEvent

  @default_zset "elixir_logs"
  @epoch :calendar.datetime_to_gregorian_seconds({{1970, 1, 1}, {0, 0, 0}})

  def init({__MODULE__, name}) do
    if user = Process.whereis(:user) do
      Process.group_leader(self(), user)
      {:ok, configure(name, [])}
    else
      {:error, :ignore}
    end
  end

  def handle_call({:configure, options}, state) do
    {:ok, :ok, configure(state[:name], options)}
  end

  def handle_event({_level, gl, _event}, state) when node(gl) != node() do
    {:ok, state}
  end

  def handle_event({level, _gl, {Logger, msg, ts, md}}, %{level: min_level} = state) do
    if is_nil(min_level) or Logger.compare_levels(level, min_level) != :lt do
      log_event(level, msg, ts, md, state)
    end
    {:ok, state}
  end

  defp configure(name, options) do
    config = Keyword.merge(Application.get_env(:logger, name, []), options)
    Application.put_env(:logger, name, config)

    zset            = Keyword.get(config, :zset, @default_zset)
    redis_url       = Keyword.get(config, :redis_url)
    level           = Keyword.get(config, :level)
    metadata        = Keyword.get(config, :metadata, [])
    {:ok, redis}    = Redix.start_link(redis_url)

    %{name: name, zset: zset, redis_url: redis_url,
      redis: redis, metadata: metadata, level: level}
  end

  defp log_event(level, msg, ts, md, state) do
    fields = md
    |> Keyword.take(state[:metadata])
    |> Map.new(fn({k,v}) -> {"_#{k}", to_string(v)} end)

    {{year, month, day}, {hour, min, sec, milli}} = ts
    epoch_seconds = :calendar.datetime_to_gregorian_seconds({{year, month, day}, {hour, min, sec}}) - @epoch
    {timestamp, _remainder} = "#{epoch_seconds}.#{milli}" |> Float.parse

    message = %{
      message:      to_string(msg),
      level:        level,
      timestamp:    round(timestamp)
    } |> Map.merge(fields)

    data = Poison.encode!(message)
    command = ~w(ZADD #{state[:zset]} #{round(timestamp)} #{data})
    Redix.command(state[:redis], command)
  end
end
