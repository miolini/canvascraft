# Changelog

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog and this project adheres to Semantic Versioning.

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
