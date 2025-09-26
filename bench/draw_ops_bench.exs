Mix.ensure_application!(:benchee)

alias CanvasCraft.Backends.Reference

Benchee.run(%{
  "stroke+fill" => fn ->
    {:ok, surf} = Reference.new_surface(32, 32, [])
    :ok = Reference.fill_rect(surf, 0, 0, 32, 32)
    :ok = Reference.set_stroke_width(surf, 2)
    :ok = Reference.set_stroke_color(surf, 0, 0, 0, 255)
  end
}, time: 0.5, warmup: 0.2)
