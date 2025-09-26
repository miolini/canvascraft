Mix.ensure_application!(:benchee)

alias CanvasCraft.Backends.Reference

Benchee.run(%{
  "fill_rect" => fn ->
    {:ok, surf} = Reference.new_surface(32, 32, [])
    :ok = Reference.fill_rect(surf, 0, 0, 32, 32)
  end,
  "draw_text" => fn ->
    {:ok, surf} = Reference.new_surface(64, 24, [])
    :ok = Reference.draw_text(surf, 2, 12, "Hello")
  end
}, time: 0.5, warmup: 0.2)
