defmodule LogstashLoggerBackend.MixProject do
  use Mix.Project

  def project do
    [
      app: :logstash_logger_backend,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      description: description(),
      deps: deps(),
      package: package(),
      source_url: "https://github.com/ThanhDev2703/logstash_logger_backend"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.8"},
      {:poison, "~> 4.0"},
      {:ex_doc, "~> 0.23", only: :dev, runtime: false}
    ]
  end

  defp description do
    """
      Collect and send log to Logstash over HTTP.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Marcelo Gornstein"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/ThanhDev2703/logstash_logger_backend"
      }
    ]
  end
end
