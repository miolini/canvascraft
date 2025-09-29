Mix.ensure_application!(:benchee)

alias CanvasCraft.Backends.Skia

Benchee.run(%{
  "fill_rect" => fn ->
    {:ok, surf} = Skia.new_surface(32, 32, [])
    :ok = Skia.fill_rect(surf, 0, 0, 32, 32, {255,255,255,255})
  end,
  "draw_text" => fn ->
    {:ok, surf} = Skia.new_surface(64, 24, [])
    :ok = Skia.draw_oval(surf, 32, 12, 10, 6)
  end
}, time: 0.5, warmup: 0.2)
