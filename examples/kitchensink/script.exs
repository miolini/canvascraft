import CanvasCraft.Scene

IO.inspect(
  render width: 1920, height: 1080, backend: CanvasCraft.Backends.Skia, path: "kitchen_1080p.webp" do
    aa 8
    clear {30,34,40,255}
    panel 60, 60, 1920-120, 1080-120, {42,46,54,255}
    circle 300, 260, 110, {35,132,252,255}
    circle 300, 260, 80,  {26,104,214,255}
    donut_segment 300, 260, 140, 22, -40, 220, {80,170,255,255}
    progress_bar 140, 760, 520, 20, 0.75
    progress_bar 140, 800, 520, 20, 0.45
    scatter 1320, 260, 480, 420, 180, [seed: 42]
    for {i, h} <- Enum.with_index([320,480,260,520,400,300,460,380]) do
      rect 600 + i*70, 900 - h, 40, h, {90,205,140,255}
      rect 600 + i*70 + 44, 900 - div(h,2), 22, div(h,2), {60,150,255,255}
    end
  end
)
