defmodule KitchenSink do
  @moduledoc """
  Kitchensink demo with a cleaner, card-based layout and balanced visuals.
  """
  alias CanvasCraft.Scene, as: Scene
  require Scene
  import CanvasCraft.Scene

  @spec render(Path.t()) :: :ok | {:error, term()}
  def render(path, opts \\ []) do
    width = Keyword.get(opts, :width, 1920)
    height = Keyword.get(opts, :height, 1080)
    aa = Keyword.get(opts, :aa, 4)

    # Global font and palette
    font_path = to_string(Path.join(:code.priv_dir(:canvas_craft), "fonts/dejavu-fonts-ttf-2.37/ttf/DejaVuSans.ttf"))
    pal = %{
      bg: {28,32,38,255},
      panel: {44,48,58,255},
      panel_alt: {48,52,62,255},
      header_from: {54,58,68,255}, header_to: {44,48,58,255},
      header_text: {230,236,246,255},
      text: {230,236,246,255},
      muted: {200,210,224,255},
      faint: {120,130,144,255},
      grid: {64,70,80,255},
      blue: {120,195,255,255},
      green: {90,205,140,255},
      red: {240,96,96,255},
      accent: {26,104,214,255}
    }

    result = Scene.render width: width, height: height, path: path,
                          aa: aa,
                          background: pal.bg,
                          font: [path: font_path, size: 18] do
      # Main container
      panel x: 40, y: 40, w: width-80, h: height-80, color: pal.panel, aa: aa

      # Header
      linear_gradient_rect x: 40, y: 40, w: width-80, h: 64, vertical: true, from: pal.header_from, to: pal.header_to, aa: aa
      text x: 80, y: 56, text: "CanvasCraft Dashboard", size: 64, color: pal.header_text
      chip_y = 56
      chip x: width-80-360, y: chip_y, w: 116, h: 22, dot: pal.blue, aa: aa
      chip x: width-80-232, y: chip_y, w: 116, h: 22, dot: pal.green, aa: aa
      chip x: width-80-104, y: chip_y, w: 96,  h: 22, dot: pal.red, aa: aa

      # Left column card: Overview
      left_x = 80
      left_y = 140
      left_w = 560
      left_h = 540
      panel x: left_x, y: left_y, w: left_w, h: left_h, color: pal.panel_alt, aa: aa
      linear_gradient_rect x: left_x, y: left_y, w: left_w, h: 40, vertical: true, from: {58,62,72,255}, to: pal.panel_alt, aa: aa
      text x: left_x+24, y: left_y+24, text: "Overview", size: 18, color: {200,230,250,255}
      paragraph x: left_x+20, y: left_y+56, w: left_w-40, h: 14, lines: 3, aa: aa

      # Donut visualization
      cx = left_x + div(left_w, 2)
      cy = left_y + 260
      radial_gradient_circle cx: cx, cy: cy, r: 110, inner: {40,140,255,255}, outer: pal.accent, aa: aa
      circle cx: cx, cy: cy, r: 82, color: pal.accent, aa: aa
      donut_segment cx: cx, cy: cy, radius: 142, thickness: 22, start_deg: -30, sweep_deg: 220, color: {80,170,255,230}, aa: aa
      for ang <- -150..30//24 do
        rad = :math.pi() * ang / 180.0
        tx = cx + :math.cos(rad) * 150
        ty = cy + :math.sin(rad) * 150
        circle cx: tx, cy: ty, r: 4, color: {120,195,255,160}, aa: aa
      end

      # System card (progress)
      sys_x = 80
      sys_y = left_y + left_h + 16
      sys_w = 560
      sys_h = 140
      panel x: sys_x, y: sys_y, w: sys_w, h: sys_h, color: pal.panel_alt, aa: aa
      linear_gradient_rect x: sys_x, y: sys_y, w: sys_w, h: 32, vertical: true, from: {58,62,72,255}, to: pal.panel_alt, aa: aa
      text x: sys_x+20, y: sys_y+24, text: "System", size: 16, color: pal.muted

      cpu = 0.68
      mem = 0.42
      text x: sys_x+20, y: sys_y+58, text: "CPU", size: 14, color: pal.muted
      progress_bar x: sys_x+90, y: sys_y+54, w: sys_w-150, h: 18, pct: cpu, aa: aa
      text x: sys_x + sys_w - 54, y: sys_y+58, text: "#{round(cpu*100)}%", size: 14, color: pal.faint

      text x: sys_x+20, y: sys_y+96, text: "MEM", size: 14, color: pal.muted
      progress_bar x: sys_x+90, y: sys_y+92, w: sys_w-150, h: 18, pct: mem, aa: aa
      text x: sys_x + sys_w - 54, y: sys_y+96, text: "#{round(mem*100)}%", size: 14, color: pal.faint

      # Right column: Analytics card
      right_x = left_x + left_w + 40
      right_y = 140
      right_w = width - 80 - right_x
      right_h = height - 80 - right_y - 32
      panel x: right_x, y: right_y, w: right_w, h: right_h, color: {50,54,64,255}, aa: aa
      linear_gradient_rect x: right_x, y: right_y, w: right_w, h: 40, vertical: true, from: {60,64,74,255}, to: {50,54,64,255}, aa: aa
      text x: right_x+32, y: right_y+24, text: "Analytics", size: 18, color: pal.text

      plot_x = right_x + 28
      plot_y = right_y + 68
      plot_w = right_w - 56
      plot_h = right_h - 108
      grid x: plot_x, y: plot_y, w: plot_w, h: plot_h, rows: 8, cols: 10, color: pal.grid, aa: aa

      line_chart x: plot_x+40, y: plot_y+24, w: plot_w-80, h: 160,
                 points: Enum.map(0..20, fn i -> {i/20, 0.5 + :math.sin(i/3)/3} end), color: pal.blue, aa: aa

      candle_chart x: plot_x+60, y: plot_y+220, w: plot_w-120, h: 160,
                   candles: Enum.map(0..18, fn _ ->
                     o = 0.45 + :rand.uniform() * 0.1
                     c = 0.45 + :rand.uniform() * 0.1
                     h = max(o,c) + :rand.uniform() * 0.1
                     l = min(o,c) - :rand.uniform() * 0.1
                     {o,h,l,c}
                   end), up_color: pal.green, down_color: pal.red, aa: aa

      chip x: plot_x+40, y: plot_y+404, w: 120, h: 22, dot: pal.blue, aa: aa
      chip x: plot_x+180, y: plot_y+404, w: 120, h: 22, dot: pal.green, aa: aa

      scatter x: plot_x+120, y: plot_y+80, w: plot_w-240, h: plot_h-200, count: 100, seed: 42, aa: aa

      # Footer
      text x: 80, y: height-96, text: "Rendered with CanvasCraft (Skia)", size: 14, color: pal.faint
      text x: width-190, y: height-96, text: "#{width}x#{height} • AA#{aa}", size: 14, color: pal.faint
    end

    case result do
      {:ok, _bin} -> :ok
      other -> other
    end
  end
end
