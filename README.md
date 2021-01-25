# LogstashLoggerBackend
LogstashLoggerBackend is elixir log backend that collect and send log to LogStash

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `logstash_logger_backend` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:logstash_logger_backend, "~> 0.1.0"}
  ]
end
```

## Configuration Examples
```elixir
config :logger,
  backends: [
    {LogstashLoggerBackend, :logstash_info},
  ]

config :logger, :logstash_info,
  level: :info,
  url: "http://some.host.com",
  username: "logstash",
  password: "logstashpassword",
  batch_size: 500,
  more_info: %{app: "DemoApp"}
```