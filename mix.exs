defmodule ExNar.MixProject do
  use Mix.Project

  @source_url "https://github.com/ajbt200128/ex_nar"
  def project do
    [
      app: :ex_nar,
      version: "0.3.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Hex
      description: "A simple Nix Archive Library for Elixir",
      package: package(),

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
       {:ex_doc, "~> 0.27", only: :dev, runtime: false}
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
      main: "ExNar",
      source_url: @source_url,
      extras: ["README.md"]
    ]
  end
end
