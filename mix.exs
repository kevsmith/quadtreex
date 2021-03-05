defmodule Quadtreex.MixProject do
  use Mix.Project

  def project do
    [
      aliases: aliases(),
      app: :quadtreex,
      consolidate_protocols: Mix.env() != :dev,
      deps: deps(),
      description: "Pure Elixir quadtree",
      elixir: "~> 1.11",
      elixirc_options: [warnings_as_errors: true],
      package: [licenses: ["MIT"], links: %{}],
      source_url: "https://github.com/kevsmith/quadtreex",
      start_permanent: Mix.env() == :prod,
      version: "0.1.0"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def deps do
    [
      {:credo, "~> 1.5.5", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.1.0", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp aliases() do
    [c: ["credo", "compile", "dialyzer"]]
  end
end
