defmodule EarthPlanet do
  @moduledoc """
  Procedurally draws an Earth-like planet and saves it as WEBP using CanvasCraft.

  Notes:
  - Uses the Skia backend by default. Enable NIFs with CANVAS_CRAFT_ENABLE_NIF=1.
  - Falls back gracefully if some ops are not implemented yet.
  """
  import Bitwise
  alias CanvasCraft, as: CC
  alias CanvasCraft.Backends.Skia
  alias CanvasCraft.Native.Skia, as: Native

  @type opts :: [
          {:size, pos_integer()} |
          {:backend, module()} |
          {:seed, integer()} |
          {:aa, 1 | 4 | 8 | boolean()}
        ]

  @doc "Render and save a WEBP image of a procedural Earth-like planet."
  @spec render_and_save(Path.t(), opts()) :: :ok | {:error, term()}
  def render_and_save(path, opts \\ []) do
    width = Keyword.get(opts, :width, Keyword.get(opts, :size, 256))
    height = Keyword.get(opts, :height, Keyword.get(opts, :size, 256))
    backend = Keyword.get(opts, :backend, Skia)
    seed = Keyword.get(opts, :seed, System.unique_integer([:monotonic, :positive]))
    aa = Keyword.get(opts, :aa, 4)

    case CC.create_canvas(width, height, backend: backend) do
      {:ok, {^backend, surf}} ->
        _ = CC.set_antialias({backend, surf}, aa)
        with :ok <- draw_planet({backend, surf}, seed),
             {:ok, bin} <- CC.export_webp({backend, surf}) do
          File.write(path, bin)
        end

      {:error, :backend_missing} -> {:error, :backend_missing}

      other -> other
    end
  end

  @doc false
  defp draw_planet({backend, surf}, seed) do
    :rand.seed(:exsss, {seed, seed >>> 16, seed >>> 32})

    # Work in pixel space
    {:ok, {w, h, _stride, _}} = CanvasCraft.export_raw({backend, surf})
    cx = w / 2
    cy = h / 2
    radius = min(w, h) * 0.45

    # Each call may return {:error, _} on minimal Skia; ignore and proceed.
    safe(fn -> backend.set_radial_gradient(surf, cx, cy, radius * 1.6, [
      {0.0, {0, 0, 0, 255}},
      {1.0, {0, 0, 0, 255}}
    ]) end)
    safe(fn -> backend.draw_oval(surf, cx, cy, min(w, h) * 0.5, min(w, h) * 0.5) end)

    safe(fn -> backend.set_radial_gradient(surf, cx, cy, radius, [
      {0.0, {30, 90, 200, 255}},
      {1.0, {10, 40, 120, 255}}
    ]) end)
    safe(fn -> backend.draw_oval(surf, cx, cy, radius, radius) end)

    safe(fn -> backend.save_layer(surf, alpha: 0.25) end)
    safe(fn -> backend.set_radial_gradient(surf, cx, cy, radius * 1.1, [
      {0.7, {135, 206, 235, 80}},
      {1.0, {135, 206, 235, 0}}
    ]) end)
    safe(fn -> backend.draw_oval(surf, cx, cy, radius * 1.1, radius * 1.1) end)

    safe(fn -> backend.set_blend_mode(surf, :src_over) end)
    paint_continents(backend, surf, cx, cy, radius, 200)

    safe(fn -> backend.set_radial_gradient(surf, cx, cy - radius * 0.6, radius * 0.25, [
      {0.0, {255, 255, 255, 200}},
      {1.0, {255, 255, 255, 0}}
    ]) end)
    safe(fn -> backend.draw_oval(surf, cx, cy - radius * 0.6, radius * 0.25, radius * 0.1) end)

    :ok
  end

  defp draw_planet_native(surf, seed, w, h) do
    :rand.seed(:exsss, {seed, seed >>> 16, seed >>> 32})
    cx = w / 2
    cy = h / 2
    radius = min(w, h) * 0.45

    _ = Native.set_radial_gradient(surf, cx, cy, radius, [
      {0.0, {30, 90, 200, 255}},
      {1.0, {10, 40, 120, 255}}
    ])
    _ = Native.draw_oval(surf, cx, cy, radius, radius)

    _ = Native.set_radial_gradient(surf, cx, cy, radius * 1.1, [
      {0.7, {135, 206, 235, 80}},
      {1.0, {135, 206, 235, 0}}
    ])
    _ = Native.draw_oval(surf, cx, cy, radius * 1.1, radius * 1.1)

    :ok
  end

  defp paint_continents(backend, surf, cx, cy, r, n) do
    for _ <- 1..n do
      theta = :rand.uniform() * :math.pi() * 2
      rho = :math.sqrt(:rand.uniform()) * r * 0.9
      x = cx + rho * :math.cos(theta)
      y = cy + rho * :math.sin(theta)

      if inside_globe?(cx, cy, r, x, y) do
        g1 = 20 + :rand.uniform(60) |> trunc
        g2 = 120 + :rand.uniform(80) |> trunc
        g3 = 20 + :rand.uniform(40) |> trunc
        safe(fn -> backend.set_radial_gradient(surf, x, y, r * 0.08, [
          {0.0, {g1, g2, g3, 255}},
          {1.0, {g1, g2, g3, 0}}
        ]) end)
        safe(fn -> backend.draw_oval(surf, x, y, r * 0.06, r * 0.03 + :rand.uniform() * 0.02) end)

        if :rand.uniform() < 0.15 do
          start = :rand.uniform() * 360
          sweep = (:rand.uniform() * 60) - 30
          safe(fn -> backend.draw_arc(surf, x, y, r * 0.07, start, sweep) end)
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

  defp safe(fun) do
    try do
      case fun.() do
        :ok -> :ok
        _ -> :ok
      end
    rescue
      _ -> :ok
    end
  end
end
