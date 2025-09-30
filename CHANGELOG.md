# Changelog

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog and this project adheres to Semantic Versioning.

## [0.2.1] - 2025-09-29
### Added
- **Dirty scheduler support** for all CPU-intensive and I/O-bound NIFs, enabling true parallel rendering across multiple cores.
- Parallelization guide (`guides/PARALLELIZATION.md`) with examples and performance considerations.
- Integration tests for parallel rendering scenarios.

### Changed
- All rendering NIFs now use `DirtyCpu` scheduler: `encode_webp`, `fill_rect`, `fill_circle`, `draw_oval`, `draw_text`, `clear`, `get_rgba_buffer`.
- Font loading uses `DirtyIo` scheduler for file system operations.
- Normal Erlang schedulers are no longer blocked during rendering, improving system responsiveness.

### Performance
- ✅ Multiple canvases can now render in parallel without blocking each other
- ✅ Batch rendering operations scale with available CPU cores
- ✅ Other Erlang processes maintain responsiveness during heavy rendering workloads

## [0.2.0] - 2025-09-28
### Added
- Scene-level options in `render/2` (aa/background/font) and per-element `aa:` support across helpers.
- New UI helpers: `linear_gradient_rect`, `radial_gradient_circle`, `chip`, `paragraph`, and real `text` with font loading.
- Kitchensink example refactor: palette, balanced header, system meters with percentages, and split analytics into non-overlapping subplots (trend, scatter, OHLC).

### Fixed
- Anti-aliasing now works for circles (Rust NIF `fill_circle` uses MSAA samples); visuals are smoother.
- Consistent AA pass-through in named-property helpers (grid/line_chart/candle_chart/etc.).

### Changed
- README updated with accurate run commands and Hex badge.

## [0.1.0] - 2025-09-28
### Added
- Minimal, fully working Skia backend via Rustler NIF producing real WEBP binaries (in-memory, zero-FS path).
- Public API facade (`CanvasCraft`) with `create_canvas/2-3`, `export_webp/1-2`, and `export_raw/1`.
- Declarative DSL (`CanvasCraft.Scene`) with positional and named properties, including per-element antialiasing.
- Shapes and primitives: clear, rect, circle, panel, donut segment, grid, scatter, progress bar.
- Chart helpers: line chart and candle chart; text helpers: `text_bar`.
- Capability discovery (`CanvasCraft.Capabilities`).
- Reference backend for fast tests and benchmarks.
- Examples: `earth_planet` and `kitchensink` (1080p dashboard) using the declarative DSL.
- Benchmarks for draw ops, images/filters, and in-memory encoding.

### Changed
- CI runs formatting, Credo, Dialyzer, tests, and non-blocking benchmarks.

### Notes
- Requires Rust toolchain for building the NIF.
