# CanvasCraft

In-memory 2D rendering with a Skia backend (via Rustler). 100% declarative Scene DSL for building charts and UI-like scenes.

## Requirements
- Elixir >= 1.16, OTP >= 26
- Rust toolchain (required)

## Quickstart (Declarative DSL)

Minimal scene:

```elixir
import CanvasCraft.Scene

render width: 128, height: 128, path: "out.webp" do
  aa 4
  clear {255, 255, 255, 255}
  rect x: 16, y: 16, w: 96, h: 96, color: {0, 128, 255, 255}
end
```

Skia backend (default):

```elixir
import CanvasCraft.Scene

render width: 256, height: 256, path: "circle.webp" do
  aa 4
  circle cx: 128, cy: 128, r: 80, color: {30, 180, 90, 255}
end
```

## Declarative DSL
See `lib/canvas_craft/scene.ex` for the Scene DSL. The examples in `examples/kitchensink` showcase:
- named properties (e.g., `rect x: 10, y: 10, w: 100, h: 40, color: {…}`)
- per-element antialiasing via `aa: 1|4|8`
- composites (grid, line_chart, candle_chart, donut_segment, progress_bar, scatter, text_bar)

## Examples
- `examples/earth_planet` – minimal scene
- `examples/kitchensink` – 1080p dashboard using the DSL

Run KitchenSink:

```sh
cd examples/kitchensink
mix deps.get
mix run -e 'KitchenSink.render("kitchen_1080p.webp")'
file kitchen_1080p.webp # should report RIFF WebP
```

Alternative (positional DSL script):

```sh
cd examples/kitchensink
mix deps.get
mix run script.exs
```

## In-Memory Binary (no path)
The DSL can return the image as a binary for streaming:

```elixir
import CanvasCraft.Scene

{:ok, webp} = render width: 320, height: 240 do
  rect x: 20, y: 20, w: 120, h: 80, color: {60, 150, 255, 255}
end
File.write!("frame.webp", webp)
```

## CI
- CI runs format, Credo, Dialyzer, tests, and a non-blocking benchmark step that emits warnings if regressions are detected.

## License
MIT
