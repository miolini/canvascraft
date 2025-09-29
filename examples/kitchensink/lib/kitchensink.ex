defmodule KitchenSink do
  @moduledoc """
  KitchenSink: showcase of CanvasCraft declarative DSL with shapes, panels, charts, gradients and UI chips.
  """
  alias CanvasCraft.Scene, as: Scene
  require Scene

  @width 1920
  @height 1080

  @spec render(Path.t()) :: :ok | {:error, term()}
  def render(path) do
    result = Scene.render width: @width, height: @height, path: path do
      Scene.aa 8
      Scene.clear {30,34,40,255}

      # backdrop panel with subtle vertical gradient header
      Scene.panel x: 60, y: 60, w: @width-120, h: @height-120, color: {42,46,54,255}
      Scene.linear_gradient_rect x: 60, y: 60, w: @width-120, h: 64, vertical: true, from: {52,56,66,255}, to: {42,46,54,255}

      # header chips and labels
      Scene.chip x: 84, y: 76, w: 160, h: 24, dot: {120,195,255,255}
      Scene.chip x: 264, y: 76, w: 140, h: 24, dot: {90,205,140,255}
      Scene.label x: 430, y: 80, w: 160, h: 20
      Scene.label x: 600, y: 80, w: 120, h: 20

      # left donut with radial gradient fill
      Scene.radial_gradient_circle cx: 300, cy: 260, r: 110, inner: {35,132,252,255}, outer: {26,104,214,255}
      Scene.circle cx: 300, cy: 260, r: 80,  color: {26,104,214,255}
      Scene.donut_segment cx: 300, cy: 260, radius: 140, thickness: 22, start_deg: -40, sweep_deg: 220, color: {80,170,255,255}
      Scene.circle cx: 300, cy: 140, r: 18, color: {225,234,246,255}
      Scene.circle cx: 300, cy: 380, r: 18, color: {225,234,246,255}

      # text rows
      Scene.text_bar x: 140, y: 400, w: 320, h: 22, color: {58,63,72,255}
      Scene.text_bar x: 140, y: 434, w: 260, h: 22, color: {58,63,72,255}
      Scene.text_bar x: 140, y: 468, w: 300, h: 22, color: {58,63,72,255}

      # tiny histogram
      for {i, h} <- Enum.with_index([320,480,260,520,400,300,460,380]) do
        Scene.rect x: 600 + i*70, y: 900 - h, w: 40, h: h, color: {90,205,140,255}, aa: 4
        Scene.rect x: 600 + i*70 + 44, y: 900 - div(h,2), w: 22, h: div(h,2), color: {60,150,255,255}, aa: 4
      end

      # right card with grid and charts
      Scene.panel x: 1160, y: 200, w: 700, h: 560, color: {48,52,62,255}
      Scene.grid x: 1180, y: 220, w: 660, h: 520, rows: 8, cols: 10, color: {58,63,72,255}
      Scene.line_chart x: 1180+30, y: 220+30, w: 660-60, h: 520-60,
                 points: Enum.map(0..20, fn i -> {i/20, 0.5 + :math.sin(i/3)/3} end), color: {120,195,255,255}
      Scene.candle_chart x: 1180+60, y: 220+60, w: 660-120, h: 520-120,
                   candles: Enum.map(0..18, fn _ ->
                     o = 0.45 + :rand.uniform() * 0.1
                     c = 0.45 + :rand.uniform() * 0.1
                     h = max(o,c) + :rand.uniform() * 0.1
                     l = min(o,c) - :rand.uniform() * 0.1
                     {o,h,l,c}
                   end), up_color: {90,205,140,255}, down_color: {240,96,96,255}

      Scene.scatter x: 1320, y: 260, w: 480, h: 420, count: 180, seed: 42

      # progress
      Scene.progress_bar x: 140, y: 760, w: 520, h: 20, pct: 0.75, aa: 8
      Scene.progress_bar x: 140, y: 800, w: 520, h: 20, pct: 0.45, aa: 8
    end

    case result do
      {:ok, _bin} -> :ok
      other -> other
    end
  end
end
