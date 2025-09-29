Mix.ensure_application!(:benchee)

alias CanvasCraft.Backends.Skia

sizes = [16, 64, 256, 512]

Benchee.run(%{
  "export_webp/2" => fn size ->
    {:ok, surf} = Skia.new_surface(size, size, [])
    {:ok, _bin} = Skia.export_webp(surf, [])
  end,
  "export_raw/1" => fn size ->
    {:ok, surf} = Skia.new_surface(size, size, [])
    {:ok, {_w,_h,_stride,_bin}} = Skia.export_raw(surf)
  end
}, inputs: Map.new(Enum.map(sizes, &{"#{&1}x#{&1}", &1})), time: 0.5, warmup: 0.2)
