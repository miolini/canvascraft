defmodule EarthPlanet do
  @moduledoc """
  Procedurally draws an Earth-like planet and saves it as WEBP using CanvasCraft.

  Notes:
  - Uses the Reference backend by default for portability; switch to Skia by passing backend: CanvasCraft.Backends.Skia when available.
  - The Reference backend is a stub for drawing but this example demonstrates intended API usage.
  """
  alias CanvasCraft, as: CC
  alias CanvasCraft.Backends.Reference

  @type opts :: [
          {:size, pos_integer()} |
          {:backend, module()} |
          {:seed, integer()}
        ]

  @doc "Render and save a WEBP image of a procedural Earth-like planet."
  @spec render_and_save(Path.t(), opts()) :: :ok | {:error, term()}
  def render_and_save(path, opts \\ []) do
    size = Keyword.get(opts, :size, 256)
    backend = Keyword.get(opts, :backend, Reference)
    seed = Keyword.get(opts, :seed, System.unique_integer([:monotonic, :positive]))

    with {:ok, {^backend, surf}} <- CC.create_canvas(size, size, backend: backend),
         :ok <- draw_planet({backend, surf}, seed),
         {:ok, bin} <- CC.export_webp({backend, surf}) do
      File.write(path, bin)
    end
  end

  @doc false
  defp draw_planet({backend, surf}, seed) do
    :rand.seed(:exsss, {seed, seed >>> 16, seed >>> 32})

    # Planet circle parameters
    cx = cy = 0.5
    radius = 0.45

    # Background (space): dark radial gradient
    _ = backend.set_radial_gradient(surf, 0.0, 0.0, 0.7, [
      {0.0, {0, 0, 0, 255}},
      {1.0, {0, 0, 0, 255}}
    ])
    :ok = backend.draw_oval(surf, cx, cy, 0.5, 0.5)

    # Ocean gradient
    :ok = backend.set_radial_gradient(surf, cx, cy, radius, [
      {0.0, {30, 90, 200, 255}},
      {1.0, {10, 40, 120, 255}}
    ])
    :ok = backend.draw_oval(surf, cx, cy, radius, radius)

    # Atmosphere glow (save layer with alpha)
    _ = backend.save_layer(surf, alpha: 0.25)
    :ok = backend.set_radial_gradient(surf, cx, cy, radius * 1.1, [
      {0.7, {135, 206, 235, 80}},
      {1.0, {135, 206, 235, 0}}
    ])
    :ok = backend.draw_oval(surf, cx, cy, radius * 1.1, radius * 1.1)

    # Continents: pseudo-noise via arcs and small ovals
    :ok = backend.set_blend_mode(surf, :src_over)
    paint_continents(backend, surf, cx, cy, radius, 400)

    # Polar caps
    :ok = backend.set_radial_gradient(surf, cx, cy - radius * 0.6, radius * 0.25, [
      {0.0, {255, 255, 255, 200}},
      {1.0, {255, 255, 255, 0}}
    ])
    :ok = backend.draw_oval(surf, cx, cy - radius * 0.6, radius * 0.25, radius * 0.1)

    :ok
  end

  defp paint_continents(backend, surf, cx, cy, r, n) do
    for _ <- 1..n do
      theta = :rand.uniform() * :math.pi() * 2
      rho = :math.sqrt(:rand.uniform()) * r * 0.9
      x = cx + rho * :math.cos(theta)
      y = cy + rho * :math.sin(theta)

      if inside_globe?(cx, cy, r, x, y) do
        green = {20 + :rand.uniform(60), 120 + :rand.uniform(80) |> trunc, 20 + :rand.uniform(40) |> trunc, 255}
        :ok = backend.set_radial_gradient(surf, x, y, r * 0.08, [
          {0.0, {elem(green, 0), elem(green, 1), elem(green, 2), 255}},
          {1.0, {elem(green, 0), elem(green, 1), elem(green, 2), 0}}
        ])
        :ok = backend.draw_oval(surf, x, y, r * 0.06, r * 0.03 + :rand.uniform() * 0.02)

        # occasional arc strokes to form coastlines
        if :rand.uniform() < 0.15 do
          start = :rand.uniform() * 360
          sweep = (:rand.uniform() * 60) - 30
          :ok = backend.draw_arc(surf, x, y, r * 0.07, start, sweep)
        end
      end
    end

    :ok
  end

  defp inside_globe?(cx, cy, r, x, y) do
    dx = x - cx
    dy = y - cy
    dx * dx + dy * dy <= r * r
  end
end
