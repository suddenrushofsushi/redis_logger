use Mix.Config

config :logger,
  backends: [{RedisLogger, :redis_logger}]

config :logger, :redis_logger,
  zset: "elixir_logs",
  level: :info,
  redis_url: "redis://localhost:6379/0"
