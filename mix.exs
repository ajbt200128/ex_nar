defmodule ExNar.MixProject do
  use Mix.Project

  @source_url "https://github.com/ajbt200128/ex_nar"
  def project do
    [
      app: :ex_nar,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()

      # Hex
      description: "A simple Nix Archive Library for Elixir",
      paclage: package(),

      # Docs
      name: "ExNar",
      docs: docs()
    ]

  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
    ]
  end

  defp package do
    [
      maintainers: ["Austin Theriault"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp docs do
    [
      source_url: @source_url
    ]
  end
end
