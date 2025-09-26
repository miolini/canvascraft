# CanvasCraft

In-memory 2D rendering with a Skia backend (via Rustler).

## Quickstart (In-Memory API)

```elixir
{:ok, handle} = CanvasCraft.create_canvas(128, 128)
{:ok, webp} = CanvasCraft.export_webp(handle)
:ok = File.write("out.webp", webp)
```

See `guides/examples/` for more.
