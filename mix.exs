defmodule CanvasCraft.MixProject do
  use Mix.Project

  def project do
    [
      app: :canvas_craft,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      dialyzer: [
        plt_add_apps: [:mix],
        ignore_warnings: "dialyzer.ignore"
      ],
      preferred_cli_env: [
        credo: :test,
        dialyzer: :dev
      ],
      rustler_crates: rustler_crates(),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:rustler, "~> 0.34"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev], runtime: false},
      {:stream_data, "~> 1.1", only: :test},
      {:benchee, "~> 1.3", only: [:dev, :test]},
      {:mox, "~> 1.1", only: :test},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
    ]
  end

  defp rustler_crates do
    if Mix.env() == :prod do
      [
        canvas_craft_skia: [
          path: "native/canvas_craft_skia",
          mode: :release
        ]
      ]
    else
      []
    end
  end
end
