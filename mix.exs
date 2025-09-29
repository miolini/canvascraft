defmodule CanvasCraft.MixProject do
  use Mix.Project

  @version "0.2.0"
  @source_url "https://github.com/miolini/canvascraft"

  def project do
    [
      app: :canvas_craft,
      version: @version,
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      description: "In-memory 2D rendering with a Skia (Rustler) backend and declarative DSL",
      dialyzer: [
        plt_add_apps: [:mix],
        ignore_warnings: "dialyzer.ignore"
      ],
      preferred_cli_env: [
        credo: :test,
        dialyzer: :dev,
        docs: :dev
      ],
      rustler_crates: [
        canvas_craft_skia: [
          path: "native/canvas_craft_skia",
          mode: :release
        ]
      ],
      deps: deps(),
      package: package(),
      source_url: @source_url,
      homepage_url: @source_url,
      docs: [
        main: "readme",
        extras: ["README.md", "CHANGELOG.md"],
        source_url: @source_url,
        source_ref: "v#{@version}"
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      maintainers: ["Artem Andreenko"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Changelog" => @source_url <> "/blob/main/CHANGELOG.md"
      },
      files: [
        "lib",
        "native/canvas_craft_skia/src",
        "native/canvas_craft_skia/Cargo.toml",
        "priv/fonts/DejaVuSans.ttf",
        "mix.exs",
        "README.md",
        "CHANGELOG.md",
        "LICENSE"
      ]
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
end
