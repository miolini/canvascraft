defmodule KitchenSink do
  @moduledoc """
  Kitchensink demo with a cleaner, card-based layout and balanced visuals.
  """
  alias CanvasCraft.Scene, as: Scene
  require Scene
  import CanvasCraft.Scene

  @width 1920
  @height 1080

  @spec render(Path.t()) :: :ok | {:error, term()}
  def render(path, opts \\ []) do
    width = Keyword.get(opts, :width, @width)
    height = Keyword.get(opts, :height, @height)

    font_path = to_string(Path.join(:code.priv_dir(:canvas_craft), "fonts/dejavu-fonts-ttf-2.37/ttf/DejaVuSans.ttf"))

    result = Scene.render width: width, height: height, path: path,
                          aa: 4,
                          background: {28,32,38,255} do
      # Main container
      panel x: 40, y: 40, w: width-80, h: height-80, color: {44,48,58,255}

      # Header
      linear_gradient_rect x: 40, y: 40, w: width-80, h: 64, vertical: true, from: {54,58,68,255}, to: {44,48,58,255}
      text x: 80, y: 56, text: "CanvasCraft Dashboard", font: [path: font_path, size: 26], color: {230,236,246,255}
      chip_y = 56
      chip x: width-80-360, y: chip_y, w: 116, h: 22, dot: {120,195,255,255}
      chip x: width-80-232, y: chip_y, w: 116, h: 22, dot: {90,205,140,255}
      chip x: width-80-104, y: chip_y, w: 96,  h: 22, dot: {240,96,96,255}

      # Left column card: Overview
      left_x = 80
      left_y = 140
      left_w = 560
      left_h = 540
      panel x: left_x, y: left_y, w: left_w, h: left_h, color: {48,52,62,255}
      linear_gradient_rect x: left_x, y: left_y, w: left_w, h: 40, vertical: true, from: {58,62,72,255}, to: {48,52,62,255}
      text x: left_x+24, y: left_y+24, text: "Overview", font: [path: font_path, size: 18], color: {200,230,250,255}
      paragraph x: left_x+20, y: left_y+56, w: left_w-40, h: 14, lines: 3

      # Donut visualization
      cx = left_x + div(left_w, 2)
      cy = left_y + 260
      radial_gradient_circle cx: cx, cy: cy, r: 110, inner: {40,140,255,255}, outer: {26,104,214,255}
      circle cx: cx, cy: cy, r: 82, color: {26,104,214,255}
      donut_segment cx: cx, cy: cy, radius: 142, thickness: 22, start_deg: -30, sweep_deg: 220, color: {80,170,255,230}
      for ang <- -150..30//24 do
        rad = :math.pi() * ang / 180.0
        tx = cx + :math.cos(rad) * 150
        ty = cy + :math.sin(rad) * 150
        circle cx: tx, cy: ty, r: 4, color: {120,195,255,160}
      end

      # System card (progress)
      sys_x = 80
      sys_y = left_y + left_h + 16
      sys_w = 560
      sys_h = 140
      panel x: sys_x, y: sys_y, w: sys_w, h: sys_h, color: {48,52,62,255}
      linear_gradient_rect x: sys_x, y: sys_y, w: sys_w, h: 32, vertical: true, from: {58,62,72,255}, to: {48,52,62,255}
      text x: sys_x+20, y: sys_y+24, text: "System", size: 16, color: {200,210,224,255}
      text x: sys_x+20, y: sys_y+58, text: "CPU", size: 14, color: {200,210,224,255}
      progress_bar x: sys_x+90, y: sys_y+54, w: sys_w-150, h: 18, pct: 0.68, aa: 8
      text x: sys_x+20, y: sys_y+96, text: "MEM", size: 14, color: {200,210,224,255}
      progress_bar x: sys_x+90, y: sys_y+92, w: sys_w-150, h: 18, pct: 0.42, aa: 8

      # Right column: Analytics card
      right_x = left_x + left_w + 40
      right_y = 140
      right_w = width - 80 - right_x
      right_h = height - 80 - right_y - 32
      panel x: right_x, y: right_y, w: right_w, h: right_h, color: {50,54,64,255}
      linear_gradient_rect x: right_x, y: right_y, w: right_w, h: 40, vertical: true, from: {60,64,74,255}, to: {50,54,64,255}
      text x: right_x+32, y: right_y+24, text: "Analytics", size: 18, color: {230,236,246,255}

      plot_x = right_x + 28
      plot_y = right_y + 68
      plot_w = right_w - 56
      plot_h = right_h - 108
      grid x: plot_x, y: plot_y, w: plot_w, h: plot_h, rows: 8, cols: 10, color: {64,70,80,255}

      line_chart x: plot_x+40, y: plot_y+24, w: plot_w-80, h: 160,
                 points: Enum.map(0..20, fn i -> {i/20, 0.5 + :math.sin(i/3)/3} end), color: {120,195,255,255}

      candle_chart x: plot_x+60, y: plot_y+220, w: plot_w-120, h: 160,
                   candles: Enum.map(0..18, fn _ ->
                     o = 0.45 + :rand.uniform() * 0.1
                     c = 0.45 + :rand.uniform() * 0.1
                     h = max(o,c) + :rand.uniform() * 0.1
                     l = min(o,c) - :rand.uniform() * 0.1
                     {o,h,l,c}
                   end), up_color: {90,205,140,255}, down_color: {240,96,96,255}

      chip x: plot_x+40, y: plot_y+404, w: 120, h: 22, dot: {120,195,255,255}
      chip x: plot_x+180, y: plot_y+404, w: 120, h: 22, dot: {90,205,140,255}

      scatter x: plot_x+120, y: plot_y+80, w: plot_w-240, h: plot_h-200, count: 100, seed: 42

      text x: 80, y: height-96, text: "Rendered with CanvasCraft (Skia)", size: 14, color: {120,130,144,255}
    end

    case result do
      {:ok, _bin} -> :ok
      other -> other
    end
  end
end
