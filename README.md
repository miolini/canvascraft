# CanvasCraft

In-memory 2D rendering with a Skia backend (via Rustler). Declarative DSL for building charts and UI-like scenes, plus a pure-Elixir reference backend for tests and CI.

## Requirements
- Elixir >= 1.16, OTP >= 26
- Rust toolchain (for the Skia NIF)
- To use the Skia backend, run with environment variable `CANVAS_CRAFT_ENABLE_NIF=1`

## Quickstart (Reference backend, no native build)

```elixir
{:ok, handle} = CanvasCraft.create_canvas(128, 128, backend: CanvasCraft.Backends.Reference)
:ok = CanvasCraft.clear(handle, {255, 255, 255, 255})
:ok = CanvasCraft.fill_rect(handle, 16, 16, 96, 96, {0, 128, 255, 255})
{:ok, webp} = CanvasCraft.export_webp(handle)
File.write!("out.webp", webp)
```

## Quickstart (Skia backend, real WEBP, in-memory)

- Ensure Rust toolchain is installed.
- Run with `CANVAS_CRAFT_ENABLE_NIF=1` to enable the Skia NIF at runtime.

```elixir
{:ok, handle} = CanvasCraft.create_canvas(256, 256) # defaults to Skia backend
:ok = CanvasCraft.set_antialias(handle, 4)
:ok = CanvasCraft.fill_circle(handle, 128, 128, 80, {30, 180, 90, 255})
{:ok, bin} = CanvasCraft.export_webp(handle)
File.write!("circle.webp", bin)
```

zsh one-liner to render an example with Skia:

```sh
env CANVAS_CRAFT_ENABLE_NIF=1 mix run -e 'File.write!("/tmp/kitchen.webp", (KitchenSink.render("/tmp/kitchen.webp") && File.read!("/tmp/kitchen.webp")))'
```

## Declarative DSL
See `lib/canvas_craft/scene.ex` for the Scene DSL. The examples in `examples/kitchensink` showcase:
- named properties (e.g., `rect x: 10, y: 10, w: 100, h: 40, color: {…}`)
- per-element antialiasing via `aa: 1|4|8`
- composites (grid, line_chart, candle_chart, donut_segment, progress_bar, scatter, text_bar)

## Examples
- `examples/earth_planet` – minimal scene
- `examples/kitchensink` – 1080p dashboard using the DSL

Run an example (Skia):

```sh
cd examples/kitchensink
env CANVAS_CRAFT_ENABLE_NIF=1 mix run -e 'KitchenSink.render("kitchen_1080p.webp")'
file kitchen_1080p.webp # should report RIFF WebP
```

## In-Memory Workflow
All exports return binaries so you can decide how/where to persist:

```elixir
{:ok, handle} = CanvasCraft.create_canvas(1920, 1080)
{:ok, webp} = CanvasCraft.export_webp(handle)
# stream to HTTP response or save to disk
:ok = File.write("dashboard.webp", webp)
```

## CI
- CI runs format, Credo, Dialyzer, tests, and a non-blocking benchmark step that emits warnings if regressions are detected.
- Skia NIF is not required for CI and is disabled by default there.

## License
MIT
