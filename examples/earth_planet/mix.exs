defmodule EarthPlanet.MixProject do
  use Mix.Project

  def project do
    [
      app: :earth_planet,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:canvas_craft, path: "../.."}
    ]
  end

  defp elixirc_paths(_), do: ["lib"]
end
