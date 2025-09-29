defmodule KitchenSink do
  @moduledoc """
  KitchenSink: showcase of CanvasCraft declarative DSL with shapes, panels, charts and AA.
  """
  import CanvasCraft.Scene

  @width 1920
  @height 1080

  @spec render(Path.t()) :: :ok | {:error, term()}
  def render(path) do
    result = render width: @width, height: @height, path: path do
      clear {30,34,40,255}

      panel x: 60, y: 60, w: @width-120, h: @height-120, color: {42,46,54,255}

      text_bar x: 100, y: 80, w: 220, h: 28
      text_bar x: 340, y: 80, w: 160, h: 28, color: {200,210,224,255}

      circle cx: 300, cy: 260, r: 110, color: {35,132,252,255}
      circle cx: 300, cy: 260, r: 80,  color: {26,104,214,255}
      donut_segment cx: 300, cy: 260, radius: 140, thickness: 22, start_deg: -40, sweep_deg: 220, color: {80,170,255,255}
      circle cx: 300, cy: 140, r: 18, color: {225,234,246,255}
      circle cx: 300, cy: 380, r: 18, color: {225,234,246,255}

      text_bar x: 140, y: 400, w: 320, h: 22, color: {58,63,72,255}
      text_bar x: 140, y: 434, w: 260, h: 22, color: {58,63,72,255}
      text_bar x: 140, y: 468, w: 300, h: 22, color: {58,63,72,255}

      for {i, h} <- Enum.with_index([320,480,260,520,400,300,460,380]) do
        rect x: 600 + i*70, y: 900 - h, w: 40, h: h, color: {90,205,140,255}, aa: 4
        rect x: 600 + i*70 + 44, y: 900 - div(h,2), w: 22, h: div(h,2), color: {60,150,255,255}, aa: 4
      end

      rect x: 1180, y: 220, w: 660, h: 520, color: {48,52,62,255}
      grid x: 1180, y: 220, w: 660, h: 520, rows: 8, cols: 10, color: {58,63,72,255}
      line_chart x: 1180+30, y: 220+30, w: 660-60, h: 520-60,
                 points: Enum.map(0..20, fn i -> {i/20, 0.5 + :math.sin(i/3)/3} end), color: {120,195,255,255}
      candle_chart x: 1180+60, y: 220+60, w: 660-120, h: 520-120,
                   candles: Enum.map(0..18, fn _ ->
                     o = 0.45 + :rand.uniform() * 0.1
                     c = 0.45 + :rand.uniform() * 0.1
                     h = max(o,c) + :rand.uniform() * 0.1
                     l = min(o,c) - :rand.uniform() * 0.1
                     {o,h,l,c}
                   end), up_color: {90,205,140,255}, down_color: {240,96,96,255}

      scatter x: 1320, y: 260, w: 480, h: 420, count: 180, seed: 42

      progress_bar x: 140, y: 760, w: 520, h: 20, pct: 0.75, aa: 8
      progress_bar x: 140, y: 800, w: 520, h: 20, pct: 0.45, aa: 8
    end

    case result do
      {:ok, _bin} -> :ok
      other -> other
    end
  end
end
