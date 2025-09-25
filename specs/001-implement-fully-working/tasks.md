# Tasks: MVP: Fully Working Skia Backend

**Input**: Design documents from `/specs/001-implement-fully-working/`
**Prerequisites**: plan.md (required), research.md, data-model.md, contracts/
**Notes**: always write fully working code without stubs or comments 'not implemented yet'

## Execution Flow (main)
```
1. Load plan.md from feature directory
   → If not found: ERROR "No implementation plan found"
   → Extract: tech stack, libraries, structure
2. Load optional design documents:
   → data-model.md: Extract entities → model tasks
   → contracts/: Each file → contract test task
   → research.md: Extract decisions → setup tasks
   → quickstart.md: Extract scenarios → integration tests
3. Generate tasks by category:
   → Setup, Tests (TDD), Core, Integration, Polish
4. Apply rules: Different files = [P] parallel; same file = sequential
5. Number tasks sequentially (T001, T002...)
6. Generate dependency graph and parallel groups
7. Return: SUCCESS (tasks ready for execution)
```

## Path Conventions (Elixir library)
- Source: `lib/`
- NIF/Native: `native/`
- Tests: `test/` with subfolders `contract/`, `integration/`, `unit/`
- Assets: `priv/` (e.g., fonts)

## Phase 3.1: Setup
- [x] T001 Initialize Mix project at repo root as library `canvas_craft`
      - Files: mix.exs, lib/canvas_craft.ex, test/test_helper.exs
- [x] T002 Add dependencies in mix.exs
      - :rustler (~> 0.34), :ex_doc, :dialyxir, :stream_data, :benchee, :mox, :credo
- [x] T003 Configure tooling
      - .formatter.exs, .credo.exs, dialyzer PLT in dialyzer.ignore, ci settings
- [x] T004 [P] Create base module layout
      - lib/canvas_craft.ex (public API façade)
      - lib/canvas_craft/renderer.ex (behaviour: callbacks for surface, path ops, paint, text, transform, export)
      - lib/canvas_craft/backends/skia.ex (backend module stub)
- [x] T005 [P] Create project skeleton for native Skia backend via Rustler
      - native/canvas_craft_skia/Cargo.toml
      - native/canvas_craft_skia/src/lib.rs
      - configure Rustler NIF in mix.exs and application
      - Add Skia as a git submodule under `third_party/skia` for compilation purposes
      - Wire native build scripts to use local `third_party/skia` sources (document platform toolchains)
      - Document submodule init/update in README and developer setup
- [x] T006 Add deterministic test font
      - priv/fonts/DejaVuSans.ttf (open license) and loader utility
- [x] T007 Setup CI
      - .github/workflows/ci.yml (macOS + Ubuntu) → run format, credo, dialyzer, tests, benchmarks (non-blocking)
      - Ensure checkout includes submodules (recursive) so Skia sources are available during native builds

## Phase 3.2: Tests First (TDD) ⚠️ MUST COMPLETE BEFORE 3.3
- [x] T008 Define renderer conformance spec (failing first)
      - test/contract/renderer_conformance_test.exs: shared tests for callbacks and invariants
- [x] T009 [P] Golden image harness with tolerance
      - test/integration/golden_test.exs + test/support/golden_helper.ex
      - Implement per-channel Δ≤2 OR PSNR≥40 dB comparator (configurable)
- [x] T010 [P] Integration test: rectangle fill + save WEBP
      - test/integration/rect_fill_webp_test.exs (writes tmp file, compares golden)
- [x] T011 [P] Integration test: stroke joins/caps and fill rules
      - test/integration/stroke_fill_rules_test.exs
- [x] T012 [P] Integration test: text draw with font/size
      - test/integration/text_render_test.exs
- [x] T013 [P] Integration test: transform stack (translate/scale/rotate)
      - test/integration/transform_stack_test.exs
- [x] T014 Property tests for geometry invariants
      - test/unit/geometry_prop_test.exs (StreamData generators)

## Phase 3.3: Core Implementation (ONLY after tests are failing)
- [x] T015 Implement behaviour `CanvasCraft.Renderer`
      - lib/canvas_craft/renderer.ex (typespecs, docs for all callbacks)
- [x] T016 Implement public API façade `CanvasCraft`
      - lib/canvas_craft.ex (create_canvas/2, clear/2, fill_rect/…, path ops, text, export_webp)
- [x] T017 Skia NIF: surface creation and RGBA buffer
      - native/canvas_craft_skia/src/lib.rs (init, canvas creation)
- [x] T018 Skia NIF: path building (move_to, line_to, bezier_to, close_path)
- [x] T019 Skia NIF: paint state (fill, stroke, width, cap, join, miter, aa)
- [ ] T020 Skia NIF: transforms (save/restore, translate/scale/rotate)
- [ ] T021 Skia NIF: text drawing (font load, layout, draw)
- [ ] T022 Skia NIF: WEBP encode and file write (return {:ok, binary})
- [ ] T023 Backend module `CanvasCraft.Backends.Skia`
      - lib/canvas_craft/backends/skia.ex (delegates public API to NIF; select via opts)

## Phase 3.3b: Skia Primitive Coverage & Behaviour Expansion
- [ ] T024 Expand `CanvasCraft.Renderer` behaviour to cover Skia primitive families
      - Add callbacks and types for:
        • Images (load from binary/path, draw_image, sampling options)
        • Gradients (linear, radial, sweep) and shaders
        • Color filters and image filters (e.g., blur, color matrix)
        • Blenders/compose operations and blend modes
        • Clipping (rect/path; intersect, difference)
        • Mask filters and path effects (e.g., dash)
        • SaveLayer with paint; draw_round_rect, draw_oval/circle, draw_arc
        • Capability discovery (e.g., capabilities/0 or supports?(:feature))
      - Files: lib/canvas_craft/renderer.ex, lib/canvas_craft/types.ex
- [ ] T025 Define `CanvasCraft.Capabilities` and enums/typespecs for features above
      - Files: lib/canvas_craft/capabilities.ex
- [ ] T026 Add conformance tests per primitive group (failing first)
      - Files: test/contract/primitives/*.exs (images_test.exs, gradients_test.exs, filters_test.exs, blending_test.exs, clipping_test.exs, effects_test.exs)
- [ ] T027 Skia NIF: gradients & shaders bindings
      - Files: native/canvas_craft_skia/src/lib.rs (modules), lib/canvas_craft/backends/skia.ex
- [ ] T028 Skia NIF: color filters & image filters bindings
- [ ] T029 Skia NIF: image decoding/encoding and draw_image with sampling
- [ ] T030 Skia NIF: blenders/compose + save_layer with paint
- [ ] T031 Skia NIF: clipping, mask filters, path effects
- [ ] T032 Backend delegation & capability negotiation
      - Implement capability reporting; gracefully error {:error, :unsupported} for missing features in other backends
- [ ] T033 Integration tests (golden): images, gradients, filters, blend modes, clipping
      - Files: test/integration/images_test.exs, gradients_test.exs, filters_test.exs, blending_test.exs, clipping_test.exs
- [ ] T034 Docs & examples covering all primitive groups
      - @moduledoc with examples; guides/examples/*.exs; README sections
- [ ] T035 Benchmarks for images and filters
      - bench/images_filters_bench.exs

## Phase 3.3c: In-Memory Rendering (Zero-FS Path)
- [ ] T036 [P] Golden harness: support comparing from in-memory binaries
      - Update test/support/golden_helper.ex to accept WEBP binary or build-in Skia support as input (no temp files)
- [ ] T037 [P] Integration test: in-memory WEBP generation returns binary only
      - test/integration/rect_fill_webp_in_memory_test.exs (assert is_binary, compare via helper)
- [ ] T038 Public API: expose in-memory export and raw buffer
      - lib/canvas_craft.ex: export_webp/2 returns {:ok, binary}; export_raw/1 returns {:ok, {w,h,stride,binary}}
      - typespecs and docs; file-writing helpers become thin wrappers around binary path
- [ ] T039 Skia NIF: zero-FS encode and raw buffer access
      - native/canvas_craft_skia/src/lib.rs: WEBP encode to memory; get_rgba_buffer/1 without touching FS
- [ ] T040 Docs: quickstart and examples using in-memory API
      - README sections + doctests show binary workflow and optional file save wrapper
- [ ] T041 Benchmarks: in-memory encode and buffer copy costs
      - bench/in_memory_encode_bench.exs

## Phase 3.4: Integration
- [ ] T042 Plug tolerance config into test env
      - config/test.exs (golden comparator thresholds)
- [ ] T043 Font resource management
      - priv/fonts loader, fallback strategy, docs
- [ ] T044 Benchmarks for core ops
      - bench/bench_helper.exs, bench/draw_ops_bench.exs (Benchee)
- [ ] T045 Dialyzer success (no ignored warnings without waiver)
- [ ] T046 Structured docs and doctests
      - @moduledoc and examples; mix docs builds with examples

## Phase 3.5: Polish
- [ ] T047 [P] Add CHANGELOG.md and SemVer notes
- [ ] T048 [P] Add README.md with quickstart and Skia backend selection
- [ ] T049 [P] Add CONTRIBUTING.md with Constitution summary and CI gates
- [ ] T050 [P] Finalize CI to mark benchmark regressions as warnings
- [ ] T051 Release 0.1.0 (MVP) tag when all tests pass

## Dependencies
- Setup (T001–T007) before Tests (T008–T014)
- Tests (T008–T014) must fail before Core (T015–T023)
- T015/T016 before NIF tasks T017–T023 wiring
- Behaviour expansion (T024–T026) before extended NIF bindings (T027–T031)
- Extended NIF bindings (T027–T031) before primitive integration tests (T033)
- In-memory tests (T036–T037) before in-memory implementation (T038–T039)
- Submodule checkout/availability (T005/T007) before native build tasks (T017–T023, T027–T031, T039)
- Integration (T042–T046) after core/behaviour expansion; primitive golden tests (T033) after extended NIF
- Polish (T047–T051) last (docs may also be updated by T034, T040)

## Parallel Example
```
# Launch test creation in parallel:
Task: "Golden image harness" (T009)
Task: "Rect fill WEBP test" (T010)
Task: "Stroke/fill rules test" (T011)
Task: "Text render test" (T012)
Task: "Transform stack test" (T013)
```

## Validation Checklist
- [ ] Each task has exact file paths
- [ ] Tests precede implementation (TDD)
- [ ] Behaviour contract defined and enforced
- [ ] Behaviour expanded to reflect Skia primitive families
- [ ] Capability discovery implemented and documented
- [ ] In-memory rendering path does not touch filesystem
- [ ] Golden comparator thresholds configurable
- [ ] CI runs format, credo, dialyzer, tests, benches
- [ ] Docs and examples render successfully
- [ ] CI checks out git submodules (Skia) successfully
