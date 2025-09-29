defmodule CanvasCraft.Scene do
  @moduledoc """
  Declarative DSL for building CanvasCraft scenes.

  Example:
      import CanvasCraft.Scene
      render width: 1920, height: 1080, path: "out.webp" do
        rect 60, 60, 1800, 960, {42,46,54,255}
        circle 300, 260, 110, {35,132,252,255}
      end

  All commands are expanded to `CanvasCraft` API calls against an internal `handle`.
  """

  # Render entry macro with declarative scene-level options
  defmacro render(opts, do: block) do
    quote do
      backend = Keyword.get(unquote(opts), :backend, CanvasCraft.Backends.Skia)
      width = Keyword.fetch!(unquote(opts), :width)
      height = Keyword.fetch!(unquote(opts), :height)
      path = Keyword.get(unquote(opts), :path)
      aa_opt = Keyword.get(unquote(opts), :aa)
      bg_opt = Keyword.get(unquote(opts), :background)
      font_opt = Keyword.get(unquote(opts), :font)

      case CanvasCraft.create_canvas(width, height, backend: backend) do
        {:ok, {^backend, ref}} ->
          handle = {backend, ref}
          # apply scene-level declarative options
          if aa_opt do
            _ = CanvasCraft.set_antialias(handle, aa_opt)
            Process.put(:cc_aa, aa_opt)
          end
          if is_list(font_opt) do
            fpath = font_opt[:path] |> to_string()
            fsize = font_opt[:size]
            _ = CanvasCraft.load_font(handle, fpath)
            if fsize, do: CanvasCraft.set_font_size(handle, fsize)
            Process.put(:cc_font_default, {fpath, fsize})
          else
            Process.put(:cc_font_default, nil)
          end
          if bg_opt, do: CanvasCraft.clear(handle, bg_opt)

          CanvasCraft.Scene.__run(handle, fn -> unquote(block) end)
          case CanvasCraft.export_webp(handle) do
            {:ok, bin} ->
              if is_binary(path), do: File.write!(path, bin)
              {:ok, bin}
            other -> other
          end
        other -> other
      end
    end
  end

  @doc false
  def __run(handle, fun) when is_function(fun, 0) do
    Process.put(:cc_handle, handle)
    try do
      fun.()
    after
      Process.delete(:cc_handle)
    end
  end

  @doc false
  def handle! do
    case Process.get(:cc_handle) do
      nil -> raise "CanvasCraft.Scene commands must run inside render/2"
      h -> h
    end
  end

  @doc false
  def __with_aa(nil, fun) when is_function(fun, 0), do: fun.()
  def __with_aa(aa, fun) when is_function(fun, 0) do
    handle = handle!()
    prev = Process.get(:cc_aa)
    _ = CanvasCraft.set_antialias(handle, aa)
    Process.put(:cc_aa, aa)
    try do
      fun.()
    after
      if prev && prev != aa do
        _ = CanvasCraft.set_antialias(handle, prev)
        Process.put(:cc_aa, prev)
      end
    end
  end

  # Primitives
  defmacro aa(val) do
    quote do
      _ = CanvasCraft.set_antialias(CanvasCraft.Scene.handle!(), unquote(val))
      Process.put(:cc_aa, unquote(val))
      :ok
    end
  end

  defmacro clear(color) do
    quote do
      _ = CanvasCraft.clear(CanvasCraft.Scene.handle!(), unquote(color))
      :ok
    end
  end

  # Rect with optional opts (e.g., [aa: 8])
  defmacro rect(x, y, w, h, color) do
    quote do
      CanvasCraft.Scene.__with_aa(Process.get(:cc_aa), fn ->
        _ = CanvasCraft.fill_rect(CanvasCraft.Scene.handle!(), unquote(x), unquote(y), unquote(w), unquote(h), unquote(color))
      end)
      :ok
    end
  end
  defmacro rect(x, y, w, h, color, opts) do
    quote do
      CanvasCraft.Scene.__with_aa(Keyword.get(unquote(opts), :aa, Process.get(:cc_aa)), fn ->
        _ = CanvasCraft.fill_rect(CanvasCraft.Scene.handle!(), unquote(x), unquote(y), unquote(w), unquote(h), unquote(color))
      end)
      :ok
    end
  end

  # Circle with optional opts
  defmacro circle(cx, cy, r, color) do
    quote do
      CanvasCraft.Scene.__with_aa(Process.get(:cc_aa), fn ->
        _ = CanvasCraft.fill_circle(CanvasCraft.Scene.handle!(), unquote(cx), unquote(cy), unquote(r), unquote(color))
      end)
      :ok
    end
  end
  defmacro circle(cx, cy, r, color, opts) do
    quote do
      CanvasCraft.Scene.__with_aa(Keyword.get(unquote(opts), :aa, Process.get(:cc_aa)), fn ->
        _ = CanvasCraft.fill_circle(CanvasCraft.Scene.handle!(), unquote(cx), unquote(cy), unquote(r), unquote(color))
      end)
      :ok
    end
  end

  # Helpers
  defmacro panel(x, y, w, h, color) do
    quote do
      CanvasCraft.Scene.panel(unquote(x), unquote(y), unquote(w), unquote(h), unquote(color), [])
    end
  end
  defmacro panel(x, y, w, h, color, opts) do
    quote do
      CanvasCraft.Scene.__with_aa(Keyword.get(unquote(opts), :aa, Process.get(:cc_aa)), fn ->
        r = 24
        :ok = CanvasCraft.fill_circle(CanvasCraft.Scene.handle!(), unquote(x) + r, unquote(y) + r, r, unquote(color))
        :ok = CanvasCraft.fill_circle(CanvasCraft.Scene.handle!(), unquote(x) + unquote(w) - r, unquote(y) + r, r, unquote(color))
        :ok = CanvasCraft.fill_circle(CanvasCraft.Scene.handle!(), unquote(x) + r, unquote(y) + unquote(h) - r, r, unquote(color))
        :ok = CanvasCraft.fill_circle(CanvasCraft.Scene.handle!(), unquote(x) + unquote(w) - r, unquote(y) + unquote(h) - r, r, unquote(color))
        :ok = CanvasCraft.fill_rect(CanvasCraft.Scene.handle!(), unquote(x) + r, unquote(y), unquote(w) - 2 * r, unquote(h), unquote(color))
        :ok = CanvasCraft.fill_rect(CanvasCraft.Scene.handle!(), unquote(x), unquote(y) + r, unquote(w), unquote(h) - 2 * r, unquote(color))
      end)
      :ok
    end
  end

  # donut_segment with opts
  defmacro donut_segment(cx, cy, radius, thickness, start_deg, sweep_deg, color) do
    quote do
      CanvasCraft.Scene.donut_segment(unquote(cx), unquote(cy), unquote(radius), unquote(thickness), unquote(start_deg), unquote(sweep_deg), unquote(color), [])
    end
  end
  defmacro donut_segment(cx, cy, radius, thickness, start_deg, sweep_deg, color, opts) do
    quote do
      CanvasCraft.Scene.__with_aa(Keyword.get(unquote(opts), :aa, Process.get(:cc_aa)), fn ->
        step = max(2, trunc(unquote(thickness) * 0.9))
        for ang <- Stream.iterate(unquote(start_deg), &(&1 + step)) |> Enum.take_while(&(&1 <= unquote(start_deg) + unquote(sweep_deg))) do
          rad = :math.pi() * ang / 180.0
          x = unquote(cx) + :math.cos(rad) * (unquote(radius) - unquote(thickness) / 2)
          y = unquote(cy) + :math.sin(rad) * (unquote(radius) - unquote(thickness) / 2)
          _ = CanvasCraft.fill_circle(CanvasCraft.Scene.handle!(), x, y, unquote(thickness) / 2, unquote(color))
        end
      end)
      :ok
    end
  end

  # scatter with opts
  defmacro scatter(x, y, w, h, n, opts \\ []) do
    quote do
      seed = Keyword.get(unquote(opts), :seed, 1)
      aa_opt = Keyword.get(unquote(opts), :aa, Process.get(:cc_aa))
      :rand.seed(:exsplus, {seed, :erlang.bsl(seed, 1), :erlang.bsr(seed, 1)})
      _ = CanvasCraft.fill_rect(CanvasCraft.Scene.handle!(), unquote(x), unquote(y), unquote(w), unquote(h), {48,52,62,255})
      for _ <- 1..unquote(n) do
        CanvasCraft.Scene.__with_aa(aa_opt, fn ->
          px = unquote(x) + :rand.uniform() * (unquote(w) - 20) + 10
          py = unquote(y) + :rand.uniform() * (unquote(h) - 20) + 10
          rr = 4 + :rand.uniform() * 6
          color = if :rand.uniform() < 0.5, do: {90,205,140,255}, else: {60,150,255,255}
          _ = CanvasCraft.fill_circle(CanvasCraft.Scene.handle!(), px, py, rr, color)
        end)
      end
      :ok
    end
  end

  # text_bar/grid/line_chart/candle_chart/progress_bar already call rect/circle; allow opts pass through if needed by wrapping where relevant
  defmacro text_bar(x, y, w, h) do
    quote do
      CanvasCraft.Scene.rect(unquote(x), unquote(y), unquote(w), unquote(h), {220,226,236,255})
    end
  end
  defmacro text_bar(x, y, w, h, color) do
    quote do
      CanvasCraft.Scene.rect(unquote(x), unquote(y), unquote(w), unquote(h), unquote(color))
    end
  end

  # Grid helper
  defmacro grid(x, y, w, h, rows, cols) do
    quote do
      CanvasCraft.Scene.grid(unquote(x), unquote(y), unquote(w), unquote(h), unquote(rows), unquote(cols), {58,63,72,255})
    end
  end
  defmacro grid(x, y, w, h, rows, cols, color) do
    quote do
      cell_w = div(unquote(w), max(unquote(cols), 1))
      cell_h = div(unquote(h), max(unquote(rows), 1))
      # verticals
      for i <- 0..unquote(cols) do
        _ = CanvasCraft.fill_rect(CanvasCraft.Scene.handle!(), unquote(x) + i*cell_w, unquote(y), 1, unquote(h), unquote(color))
      end
      # horizontals
      for j <- 0..unquote(rows) do
        _ = CanvasCraft.fill_rect(CanvasCraft.Scene.handle!(), unquote(x), unquote(y) + j*cell_h, unquote(w), 1, unquote(color))
      end
      :ok
    end
  end

  # Line chart
  defmacro line_chart(x, y, w, h, points) do
    quote do
      CanvasCraft.Scene.line_chart(unquote(x), unquote(y), unquote(w), unquote(h), unquote(points), {90,205,140,255})
    end
  end
  defmacro line_chart(x, y, w, h, points, color) do
    quote do
      pts = Enum.map(unquote(points), fn {tx, ty} ->
        {unquote(x) + tx * unquote(w), unquote(y) + (1.0 - ty) * unquote(h)}
      end)
      for {px, py} <- pts do
        _ = CanvasCraft.fill_circle(CanvasCraft.Scene.handle!(), px, py, 3, unquote(color))
      end
      for [{x0,y0},{x1,y1}] <- Enum.chunk_every(pts, 2, 1, :discard) do
        dx = x1 - x0
        dy = y1 - y0
        dist = :math.sqrt(dx*dx + dy*dy)
        steps = trunc(dist / 6) |> max(1)
        for s <- 0..steps do
          t = s / max(steps, 1)
          sx = x0 + (x1 - x0) * t
          sy = y0 + (y1 - y0) * t
          _ = CanvasCraft.fill_circle(CanvasCraft.Scene.handle!(), sx, sy, 2, unquote(color))
        end
      end
      :ok
    end
  end

  # Candle chart
  defmacro candle_chart(x, y, w, h, candles) do
    quote do
      CanvasCraft.Scene.candle_chart(unquote(x), unquote(y), unquote(w), unquote(h), unquote(candles), {90,205,140,255}, {240,96,96,255})
    end
  end
  defmacro candle_chart(x, y, w, h, candles, up_color, down_color) do
    quote do
      data = unquote(candles)
      n = max(length(data), 1)
      cw = max(trunc(unquote(w) / n) - 4, 3)
      Enum.with_index(data)
      |> Enum.each(fn {{open, high, low, close}, i} ->
        cx = unquote(x) + i * (cw + 4) + 2
        fy = fn v -> unquote(y) + (1.0 - v) * unquote(h) end
        yo = fy.(open); yh = fy.(high); yl = fy.(low); yc = fy.(close)
        up? = close >= open
        body_y = if up?, do: yc, else: yo
        body_h = abs(yc - yo) |> max(2)
        color = if up?, do: unquote(up_color), else: unquote(down_color)
        # wick
        _ = CanvasCraft.fill_rect(CanvasCraft.Scene.handle!(), cx + div(cw,2), min(yh,yl), 2, abs(yh - yl), {200, 210, 220, 255})
        # body
        _ = CanvasCraft.fill_rect(CanvasCraft.Scene.handle!(), cx, body_y, cw, body_h, color)
      end)
      :ok
    end
  end

  # Progress bar
  defmacro progress_bar(x, y, w, h, pct) do
    quote do
      CanvasCraft.Scene.progress_bar(unquote(x), unquote(y), unquote(w), unquote(h), unquote(pct), [])
    end
  end
  defmacro progress_bar(x, y, w, h, pct, opts) do
    quote do
      aa_opt = Keyword.get(unquote(opts), :aa, Process.get(:cc_aa))
      CanvasCraft.Scene.__with_aa(aa_opt, fn ->
        CanvasCraft.Scene.rect(unquote(x), unquote(y), unquote(w), unquote(h), {58,63,72,255})
        CanvasCraft.Scene.rect(unquote(x), unquote(y), trunc(unquote(w) * unquote(pct)), unquote(h), {90,205,140,255})
        CanvasCraft.Scene.circle(unquote(x) + trunc(unquote(w) * unquote(pct)), unquote(y) + unquote(h) / 2, unquote(h) / 2, {225,234,246,255})
      end)
      :ok
    end
  end

  # Named-property helpers (runtime)
  def __kw_rect(props) when is_list(props) do
    x = Keyword.fetch!(props, :x)
    y = Keyword.fetch!(props, :y)
    w = Keyword.fetch!(props, :w)
    h = Keyword.fetch!(props, :h)
    color = Keyword.fetch!(props, :color)
    aa = Keyword.get(props, :aa, Process.get(:cc_aa))
    __with_aa(aa, fn ->
      _ = CanvasCraft.fill_rect(handle!(), x, y, w, h, color)
    end)
    :ok
  end

  def __kw_circle(props) when is_list(props) do
    cx = Keyword.fetch!(props, :cx)
    cy = Keyword.fetch!(props, :cy)
    r = Keyword.fetch!(props, :r)
    color = Keyword.fetch!(props, :color)
    aa = Keyword.get(props, :aa, Process.get(:cc_aa))
    __with_aa(aa, fn ->
      _ = CanvasCraft.fill_circle(handle!(), cx, cy, r, color)
    end)
    :ok
  end

  def __kw_panel(props) when is_list(props) do
    x = Keyword.fetch!(props, :x)
    y = Keyword.fetch!(props, :y)
    w = Keyword.fetch!(props, :w)
    h = Keyword.fetch!(props, :h)
    color = Keyword.fetch!(props, :color)
    aa = Keyword.get(props, :aa, Process.get(:cc_aa))
    __with_aa(aa, fn ->
      r = 24
      _ = CanvasCraft.fill_circle(handle!(), x + r, y + r, r, color)
      _ = CanvasCraft.fill_circle(handle!(), x + w - r, y + r, r, color)
      _ = CanvasCraft.fill_circle(handle!(), x + r, y + h - r, r, color)
      _ = CanvasCraft.fill_circle(handle!(), x + w - r, y + h - r, r, color)
      _ = CanvasCraft.fill_rect(handle!(), x + r, y, w - 2 * r, h, color)
      _ = CanvasCraft.fill_rect(handle!(), x, y + r, w, h - 2 * r, color)
    end)
    :ok
  end

  def __kw_donut(props) when is_list(props) do
    cx = Keyword.fetch!(props, :cx)
    cy = Keyword.fetch!(props, :cy)
    radius = Keyword.fetch!(props, :radius)
    thickness = Keyword.fetch!(props, :thickness)
    start_deg = Keyword.fetch!(props, :start_deg)
    sweep_deg = Keyword.fetch!(props, :sweep_deg)
    color = Keyword.fetch!(props, :color)
    aa = Keyword.get(props, :aa, Process.get(:cc_aa))
    __with_aa(aa, fn ->
      step = max(2, trunc(thickness * 0.9))
      for ang <- Stream.iterate(start_deg, &(&1 + step)) |> Enum.take_while(&(&1 <= start_deg + sweep_deg)) do
        rad = :math.pi() * ang / 180.0
        x = cx + :math.cos(rad) * (radius - thickness / 2)
        y = cy + :math.sin(rad) * (radius - thickness / 2)
        _ = CanvasCraft.fill_circle(handle!(), x, y, thickness / 2, color)
      end
    end)
    :ok
  end

  def __kw_grid(props) when is_list(props) do
    x = Keyword.fetch!(props, :x)
    y = Keyword.fetch!(props, :y)
    w = Keyword.fetch!(props, :w)
    h = Keyword.fetch!(props, :h)
    rows = Keyword.fetch!(props, :rows)
    cols = Keyword.fetch!(props, :cols)
    color = Keyword.get(props, :color, {58,63,72,255})
    aa = Keyword.get(props, :aa, Process.get(:cc_aa))
    __with_aa(aa, fn ->
      cell_w = div(w, max(cols, 1))
      cell_h = div(h, max(rows, 1))
      for i <- 0..cols, do: CanvasCraft.fill_rect(handle!(), x + i*cell_w, y, 1, h, color)
      for j <- 0..rows, do: CanvasCraft.fill_rect(handle!(), x, y + j*cell_h, w, 1, color)
    end)
    :ok
  end

  def __kw_scatter(props) when is_list(props) do
    x = Keyword.fetch!(props, :x)
    y = Keyword.fetch!(props, :y)
    w = Keyword.fetch!(props, :w)
    h = Keyword.fetch!(props, :h)
    n = Keyword.fetch!(props, :count)
    seed = Keyword.get(props, :seed, 1)
    aa = Keyword.get(props, :aa, Process.get(:cc_aa))
    :rand.seed(:exsplus, {seed, :erlang.bsl(seed, 1), :erlang.bsr(seed, 1)})
    _ = CanvasCraft.fill_rect(handle!(), x, y, w, h, {48,52,62,255})
    for _ <- 1..n do
      __with_aa(aa, fn ->
        px = x + :rand.uniform() * (w - 20) + 10
        py = y + :rand.uniform() * (h - 20) + 10
        rr = 4 + :rand.uniform() * 6
        color = if :rand.uniform() < 0.5, do: {90,205,140,255}, else: {60,150,255,255}
        _ = CanvasCraft.fill_circle(handle!(), px, py, rr, color)
      end)
    end
    :ok
  end

  def __kw_text_bar(props) when is_list(props) do
    x = Keyword.fetch!(props, :x)
    y = Keyword.fetch!(props, :y)
    w = Keyword.fetch!(props, :w)
    h = Keyword.fetch!(props, :h)
    color = Keyword.get(props, :color, {220,226,236,255})
    aa = Keyword.get(props, :aa, Process.get(:cc_aa))
    __kw_rect([x: x, y: y, w: w, h: h, color: color, aa: aa])
  end

  def __kw_progress_bar(props) when is_list(props) do
    x = Keyword.fetch!(props, :x)
    y = Keyword.fetch!(props, :y)
    w = Keyword.fetch!(props, :w)
    h = Keyword.fetch!(props, :h)
    pct = Keyword.fetch!(props, :pct)
    aa = Keyword.get(props, :aa, Process.get(:cc_aa))
    __with_aa(aa, fn ->
      __kw_rect([x: x, y: y, w: w, h: h, color: {58,63,72,255}])
      __kw_rect([x: x, y: y, w: trunc(w * pct), h: h, color: {90,205,140,255}])
      __kw_circle([cx: x + trunc(w * pct), cy: y + h / 2, r: h / 2, color: {225,234,246,255}])
    end)
    :ok
  end

  def __kw_line_chart(props) when is_list(props) do
    x = Keyword.fetch!(props, :x)
    y = Keyword.fetch!(props, :y)
    w = Keyword.fetch!(props, :w)
    h = Keyword.fetch!(props, :h)
    points = Keyword.fetch!(props, :points)
    color = Keyword.get(props, :color, {90,205,140,255})
    aa = Keyword.get(props, :aa, Process.get(:cc_aa))
    pts = Enum.map(points, fn {tx, ty} -> {x + tx * w, y + (1.0 - ty) * h} end)
    __with_aa(aa, fn ->
      Enum.each(pts, fn {px, py} -> _ = CanvasCraft.fill_circle(handle!(), px, py, 3, color) end)
      Enum.chunk_every(pts, 2, 1, :discard)
      |> Enum.each(fn [{x0,y0},{x1,y1}] ->
        dx = x1 - x0; dy = y1 - y0
        dist = :math.sqrt(dx*dx + dy*dy)
        steps = max(trunc(dist / 6), 1)
        for s <- 0..steps do
          t = s / max(steps, 1)
          sx = x0 + (x1 - x0) * t
          sy = y0 + (y1 - y0) * t
          _ = CanvasCraft.fill_circle(handle!(), sx, sy, 2, color)
        end
      end)
    end)
    :ok
  end

  def __kw_candle_chart(props) when is_list(props) do
    x = Keyword.fetch!(props, :x)
    y = Keyword.fetch!(props, :y)
    w = Keyword.fetch!(props, :w)
    h = Keyword.fetch!(props, :h)
    candles = Keyword.fetch!(props, :candles)
    up_color = Keyword.get(props, :up_color, {90,205,140,255})
    down_color = Keyword.get(props, :down_color, {240,96,96,255})
    aa = Keyword.get(props, :aa, Process.get(:cc_aa))
    n = max(length(candles), 1)
    cw = max(trunc(w / n) - 4, 3)
    __with_aa(aa, fn ->
      Enum.with_index(candles)
      |> Enum.each(fn {{open, high, low, close}, i} ->
        cx = x + i * (cw + 4) + 2
        fy = fn v -> y + (1.0 - v) * h end
        yo = fy.(open); yh = fy.(high); yl = fy.(low); yc = fy.(close)
        up? = close >= open
        body_y = if up?, do: yc, else: yo
        body_h = max(abs(yc - yo), 2)
        color = if up?, do: up_color, else: down_color
        # wick
        _ = CanvasCraft.fill_rect(handle!(), cx + div(cw,2), min(yh,yl), 2, abs(yh - yl), {200,210,220,255})
        # body
        _ = CanvasCraft.fill_rect(handle!(), cx, body_y, cw, body_h, color)
      end)
    end)
    :ok
  end

  # --- New gradient helpers ---
  def __kw_linear_gradient_rect(props) when is_list(props) do
    x = Keyword.fetch!(props, :x)
    y = Keyword.fetch!(props, :y)
    w = Keyword.fetch!(props, :w)
    h = Keyword.fetch!(props, :h)
    from = Keyword.fetch!(props, :from)
    to = Keyword.fetch!(props, :to)
    vertical = Keyword.get(props, :vertical, true)
    steps = Keyword.get(props, :steps, 64)
    aa = Keyword.get(props, :aa, Process.get(:cc_aa))
    __with_aa(aa, fn ->
      for i <- 0..steps do
        t = i / max(steps, 1)
        {r1,g1,b1,a1} = from
        {r2,g2,b2,a2} = to
        c = {
          trunc(r1 + (r2 - r1) * t),
          trunc(g1 + (g2 - g1) * t),
          trunc(b1 + (b2 - b1) * t),
          trunc(a1 + (a2 - a1) * t)
        }
        if vertical do
          _ = CanvasCraft.fill_rect(handle!(), x, y + round(h * t), w, max(div(h, steps+1), 1), c)
        else
          _ = CanvasCraft.fill_rect(handle!(), x + round(w * t), y, max(div(w, steps+1), 1), h, c)
        end
      end
    end)
    :ok
  end

  def __kw_radial_gradient_circle(props) when is_list(props) do
    cx = Keyword.fetch!(props, :cx)
    cy = Keyword.fetch!(props, :cy)
    r = Keyword.fetch!(props, :r)
    inner = Keyword.fetch!(props, :inner)
    outer = Keyword.fetch!(props, :outer)
    steps = Keyword.get(props, :steps, 48)
    aa = Keyword.get(props, :aa, Process.get(:cc_aa))
    __with_aa(aa, fn ->
      for i <- 0..steps do
        t = i / max(steps, 1)
        {r1,g1,b1,a1} = inner
        {r2,g2,b2,a2} = outer
        c = {
          trunc(r1 + (r2 - r1) * t),
          trunc(g1 + (g2 - g1) * t),
          trunc(b1 + (b2 - b1) * t),
          trunc(a1 + (a2 - a1) * t)
        }
        rr = r * (1.0 - t)
        _ = CanvasCraft.fill_circle(handle!(), cx, cy, rr, c)
      end
    end)
    :ok
  end

  # --- Simple text-like UI helpers (placeholders) ---
  def __kw_label(props) when is_list(props) do
    x = Keyword.fetch!(props, :x)
    y = Keyword.fetch!(props, :y)
    w = Keyword.get(props, :w, 160)
    h = Keyword.get(props, :h, 20)
    tone = Keyword.get(props, :tone, {220,226,236,255})
    aa = Keyword.get(props, :aa, Process.get(:cc_aa))
    __with_aa(aa, fn -> _ = CanvasCraft.fill_rect(handle!(), x, y, w, h, tone) end)
    :ok
  end

  def __kw_chip(props) when is_list(props) do
    x = Keyword.fetch!(props, :x)
    y = Keyword.fetch!(props, :y)
    label_w = Keyword.get(props, :w, 120)
    h = Keyword.get(props, :h, 22)
    dot = Keyword.get(props, :dot, {90,205,140,255})
    bar = Keyword.get(props, :bar, {220,226,236,255})
    aa = Keyword.get(props, :aa, Process.get(:cc_aa))
    r = div(h, 2)
    __with_aa(aa, fn ->
      _ = CanvasCraft.fill_circle(handle!(), x + r, y + r, r, {48,52,62,255})
      _ = CanvasCraft.fill_circle(handle!(), x + r + label_w, y + r, r, {48,52,62,255})
      _ = CanvasCraft.fill_rect(handle!(), x + r, y, label_w, h, {48,52,62,255})
      _ = CanvasCraft.fill_circle(handle!(), x + r, y + r, r - 6, dot)
      _ = CanvasCraft.fill_rect(handle!(), x + r + 12, y + 6, label_w - 6, h - 12, bar)
    end)
    :ok
  end

  # --- Macros for new helpers ---
  defmacro linear_gradient_rect(props) when is_list(props), do: quote do: CanvasCraft.Scene.__kw_linear_gradient_rect(unquote(props))
  defmacro radial_gradient_circle(props) when is_list(props), do: quote do: CanvasCraft.Scene.__kw_radial_gradient_circle(unquote(props))
  defmacro label(props) when is_list(props), do: quote do: CanvasCraft.Scene.__kw_label(unquote(props))
  defmacro chip(props) when is_list(props), do: quote do: CanvasCraft.Scene.__kw_chip(unquote(props))

  # --- Macros mapping named properties to runtime helpers ---
  defmacro rect(props) when is_list(props), do: quote do: CanvasCraft.Scene.__kw_rect(unquote(props))
  defmacro circle(props) when is_list(props), do: quote do: CanvasCraft.Scene.__kw_circle(unquote(props))
  defmacro panel(props) when is_list(props), do: quote do: CanvasCraft.Scene.__kw_panel(unquote(props))
  defmacro donut_segment(props) when is_list(props), do: quote do: CanvasCraft.Scene.__kw_donut(unquote(props))
  defmacro grid(props) when is_list(props), do: quote do: CanvasCraft.Scene.__kw_grid(unquote(props))
  defmacro scatter(props) when is_list(props), do: quote do: CanvasCraft.Scene.__kw_scatter(unquote(props))
  defmacro text_bar(props) when is_list(props), do: quote do: CanvasCraft.Scene.__kw_text_bar(unquote(props))
  defmacro progress_bar(props) when is_list(props), do: quote do: CanvasCraft.Scene.__kw_progress_bar(unquote(props))
  defmacro line_chart(props) when is_list(props), do: quote do: CanvasCraft.Scene.__kw_line_chart(unquote(props))
  defmacro candle_chart(props) when is_list(props), do: quote do: CanvasCraft.Scene.__kw_candle_chart(unquote(props))

  # --- Text (pixel 5x7) ---
  def __kw_text(props) when is_list(props) do
    x = Keyword.fetch!(props, :x)
    y = Keyword.fetch!(props, :y)
    str = Keyword.fetch!(props, :text)
    size = Keyword.get(props, :size)
    # Map size to pixel scale if provided (roughly 1 scale ~= 8pt)
    scale = Keyword.get(props, :scale, if(size, do: max(1, round(size / 8)), else: 2))
    color = Keyword.get(props, :color, {220,226,236,255})
    spacing = Keyword.get(props, :spacing, 1)
    Enum.reduce(String.to_charlist(str), %{x: x, y: y}, fn ch, cursor ->
      glyph = CanvasCraft.Text.Pixel5x7.glyph(ch)
      Enum.with_index(glyph)
      |> Enum.each(fn {row, r} ->
        row_chars = String.to_charlist(row)
        Enum.with_index(row_chars)
        |> Enum.each(fn {c, cidx} ->
          if c == ?1 do
            px = cursor.x + cidx * scale
            py = cursor.y + r * scale
            _ = CanvasCraft.fill_rect(handle!(), px, py, scale, scale, color)
          end
        end)
      end)
      adv = String.length(hd(glyph)) * scale + spacing * scale
      %{cursor | x: cursor.x + adv}
    end)
    :ok
  end

  # --- Real text using backend font (per-element overrides supported) ---
  def __kw_real_text(props) when is_list(props) do
    x = Keyword.fetch!(props, :x)
    y = Keyword.fetch!(props, :y)
    txt = Keyword.fetch!(props, :text)
    size = Keyword.get(props, :size)
    font_override = Keyword.get(props, :font)
    {r,g,b,a} = Keyword.get(props, :color, {230,236,246,255})

    default = Process.get(:cc_font_default)
    # apply per-element font/size
    if is_list(font_override) do
      fpath = font_override[:path]
      if fpath, do: CanvasCraft.load_font(handle!(), to_string(fpath))
      if font_override[:size], do: CanvasCraft.set_font_size(handle!(), font_override[:size])
    end
    if size && not is_list(font_override) do
      # size-only override
      CanvasCraft.set_font_size(handle!(), size)
    end

    case CanvasCraft.draw_text(handle!(), x, y, txt, {r,g,b,a}) do
      :ok -> :ok
      _ ->
        fallback_scale = Keyword.get(props, :fallback_scale, if(size, do: max(1, round(size / 8)), else: 2))
        spacing = Keyword.get(props, :spacing, 1)
        __kw_text([x: x, y: y, text: String.upcase(txt), scale: fallback_scale, spacing: spacing, color: {r,g,b,a}])
    end
    # restore default font after per-element override
    if is_list(font_override) do
      case default do
        {path, sz} when is_binary(path) ->
          _ = CanvasCraft.load_font(handle!(), path)
          if sz, do: CanvasCraft.set_font_size(handle!(), sz)
        _ -> :ok
      end
    else
      if size && match?({_, _}, default) do
        # restore default size when only size was overridden
        {_path, sz} = default
        if sz, do: CanvasCraft.set_font_size(handle!(), sz)
      end
    end
    :ok
  end

  def __kw_set_font(props) when is_list(props) do
    path = Keyword.fetch!(props, :path) |> to_string()
    size = Keyword.get(props, :size, 18)
    _ = CanvasCraft.load_font(handle!(), path)
    _ = CanvasCraft.set_font_size(handle!(), size)
    :ok
  end
  defmacro set_font(props) when is_list(props), do: quote do: CanvasCraft.Scene.__kw_set_font(unquote(props))

  # --- Paragraph helper (placeholder text rows) ---
  def __kw_paragraph(props) when is_list(props) do
    x = Keyword.fetch!(props, :x)
    y = Keyword.fetch!(props, :y)
    w = Keyword.fetch!(props, :w)
    lines = Keyword.get(props, :lines, 3)
    gap = Keyword.get(props, :gap, 10)
    h = Keyword.get(props, :h, 16)
    tone = Keyword.get(props, :tone, {58,63,72,255})
    aa = Keyword.get(props, :aa, Process.get(:cc_aa))
    Enum.each(0..(lines-1), fn i ->
      yy = y + i * (h + gap)
      __kw_rect([x: x, y: yy, w: trunc(w * (0.9 - 0.1 * rem(i, 3))), h: h, color: tone, aa: aa])
    end)
    :ok
  end

  # Export macros for paragraph and real text
  defmacro paragraph(props) when is_list(props), do: quote do: CanvasCraft.Scene.__kw_paragraph(unquote(props))
  defmacro text_real(props) when is_list(props), do: quote do: CanvasCraft.Scene.__kw_real_text(unquote(props))
  # New: main text macro maps to real text renderer
  defmacro text(props) when is_list(props), do: quote do: CanvasCraft.Scene.__kw_real_text(unquote(props))
end
