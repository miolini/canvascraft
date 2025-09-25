# Examples for gradients usage
alias CanvasCraft.Backends.Reference
{:ok, surf} = Reference.new_surface(100, 40, [])
:ok = Reference.set_linear_gradient(surf, 0, 0, 100, 0, [{0.0,{255,0,0,255}}, {1.0,{0,0,255,255}}])
{:ok, ":png:100x40"} = Reference.export_png(surf, [])
