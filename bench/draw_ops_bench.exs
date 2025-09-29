Mix.ensure_application!(:benchee)

alias CanvasCraft.Backends.Skia

Benchee.run(%{
  "stroke+fill" => fn ->
    {:ok, surf} = Skia.new_surface(32, 32, [])
    :ok = Skia.fill_rect(surf, 0, 0, 32, 32, {255,255,255,255})
    :ok = Skia.draw_oval(surf, 16, 16, 10, 6)
  end
}, time: 0.5, warmup: 0.2)
