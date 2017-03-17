# RedisLogger [![Build Status](https://travis-ci.org/suddenrushofsushi/redis_logger.svg?branch=master)](https://travis-ci.org/suddenrushofsushi/redis_logger)

A Redis based backend for Logger which pushes to a SortedSet.

## Configuration

In your config.exs, add redis_logger as a backend:

```
config :logger,
  backends: [{RedisLogger, :redis_logger}]
```

You'll need to pass your redis connection url along with the name of the sorted set key where messages will be pushed.

```
config :logger, :redis_logger,
  zset: "elixir_logs",
  level: :info,
  redis_url: "redis://localhost:6379/0"
```

## Usage

You know what to do.

## Todo

- [ ] Expiration of log items

## Tests or Contributions

- `mix test`
- Fork, Branch, PR


## Credit

Thanks to Joshua Schniper for publishing [GelfLogger](https://github.com/jschniper/gelf_logger), the giant on whose shoulders this project stands.
