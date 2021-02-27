defmodule Quadtreex.MixProject do
  use Mix.Project

  def project do
    [
      app: :quadtreex,
      description: "Pure Elixir quadtree",
      version: "0.5.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      package: [licenses: ["MIT"], links: %{}],
      deps: [],
      source_url: "https://github.com/kevsmith/quadtreex"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end
end
