defmodule RedisLogger.Mixfile do
  use Mix.Project

  def project do
    [
      app: :redis_logger,
      version: "0.1.0",
      elixir: "~> 1.4",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      name: "Redis Logger Backend",
      source_url: "https://github.com/suddenrushofsushi/redis_logger",
      docs: [
        main: "RedisLogger",
        extras: ["README.md"]
      ]
   ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:redix, ">= 0.0.0"},
      {:poison, ">= 3.0.0"},
      {:credo, "~> 0.4", only: [:dev, :test]},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE" ],
      maintainers: ["Craig Waterman"],
      licenses: ["MIT"],
      links: %{"Github": "https://github.com/suddenrushofsushi/redis_logger"}
    ]
  end

  defp description do
    """
      A Redis based backend for Logger which pushes to a SortedSet.
    """
  end

end
