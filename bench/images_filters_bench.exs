Mix.ensure_application!(:benchee)

alias CanvasCraft.Backends.Reference

inputs = %{
  "small" => 16,
  "medium" => 64,
  "large" => 256
}

Benchee.run(%{
  "export_png" => fn size ->
    {:ok, surf} = Reference.new_surface(size, size, [])
    {:ok, _} = Reference.export_png(surf, [])
  end,
  "filters+export" => fn size ->
    {:ok, surf} = Reference.new_surface(size, size, [])
    :ok = Reference.set_image_filter(surf, {:blur, 2.0, 2.0})
    {:ok, _} = Reference.export_webp(surf, [])
  end
},
  inputs: inputs,
  time: 0.5,
  warmup: 0.2
)
