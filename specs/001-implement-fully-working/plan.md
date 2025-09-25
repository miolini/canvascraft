# Implementation Plan: MVP: Fully Working Skia Backend

**Branch**: `001-implement-fully-working` | **Date**: 2025-09-25 | **Spec**: /Users/mio/work/canvas_craft/specs/001-implement-fully-working/spec.md
**Input**: Feature specification from `/specs/001-implement-fully-working/spec.md`

## Execution Flow (/plan command scope)
```
1. Load feature spec from Input path
   → If not found: ERROR "No feature spec at {path}"
2. Fill Technical Context (scan for NEEDS CLARIFICATION)
   → Detect Project Type from file system structure or context (web=frontend+backend, mobile=app+api)
   → Set Structure Decision based on project type
3. Fill the Constitution Check section based on the content of the constitution document.
4. Evaluate Constitution Check section below
   → If violations exist: Document in Complexity Tracking
   → If no justification possible: ERROR "Simplify approach first"
   → Update Progress Tracking: Initial Constitution Check
5. Execute Phase 0 → research.md
   → If NEEDS CLARIFICATION remain: ERROR "Resolve unknowns"
6. Execute Phase 1 → contracts, data-model.md, quickstart.md, agent-specific template file (e.g., `CLAUDE.md` for Claude Code, `.github/copilot-instructions.md` for GitHub Copilot, `GEMINI.md` for Gemini CLI, `QWEN.md` for Qwen Code or `AGENTS.md` for opencode).
7. Re-evaluate Constitution Check section
   → If new violations: Refactor design, return to Phase 1
   → Update Progress Tracking: Post-Design Constitution Check
8. Plan Phase 2 → Describe task generation approach (DO NOT create tasks.md)
9. STOP - Ready for /tasks command
```

**IMPORTANT**: The /plan command STOPS at step 7. Phases 2-4 are executed by other commands:
- Phase 2: /tasks command creates tasks.md
- Phase 3-4: Implementation execution (manual or via tools)

## Summary
Deliver a backend-agnostic 2D drawing library API for Elixir with a fully working Skia backend
for the MVP. Provide canvas creation, path drawing, fills/strokes, text rendering, transforms,
and PNG export. Ensure conformance tests and deterministic results per backend.

## Technical Context
**Language/Version**: Elixir [NEEDS CLARIFICATION: min version, e.g., >= 1.16]; OTP [NEEDS CLARIFICATION: >= 26]
**Primary Dependencies**: Skia backend via Rust NIF (Rustler) [NEEDS CLARIFICATION: crate choice, e.g., skia-safe]; ExUnit; StreamData (property testing) [proposed]; Benchee (benchmarks) [proposed]
**Storage**: N/A (in-memory rendering; file export to PNG only)
**Testing**: ExUnit + property testing (StreamData) + golden-image diff with tolerance [NEEDS CLARIFICATION: thresholds]
**Target Platform**: macOS and Linux CI [NEEDS CLARIFICATION]
**Project Type**: single library (Mix project)
**Performance Goals**: Deterministic renders; sample scenes render under [NEEDS CLARIFICATION: target ms] on CI
**Constraints**: Backend-agnostic behaviour; dirty NIFs only; avoid scheduler starvation; explicit memory ownership; no implicit filesystem/network I/O
**Scale/Scope**: MVP features only: canvas, paths, fills/strokes, text, transforms, PNG export; 1 backend (Skia)

## Constitution Check
*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- P1 Idiomatic Elixir, Pure API Surfaces → Plan uses functional API, typespecs, {:ok|:error} tuples. PASS
- P2 Backend-Agnostic Rendering via Behaviours → Define `CanvasCraft.Renderer` behaviour; Skia implements and must pass conformance tests. PASS
- P3 Test-First with Conformance/Property Tests → Conformance suite, property tests for geometry, golden tests with tolerance. PASS
- P4 Performance, Determinism, Safety → Use dirty NIFs; CI benchmarks; deterministic outputs; explicit memory rules. PASS
- P5 Documentation, SemVer, Compatibility → Doctests, examples, CHANGELOG; SemVer adherence. PASS
- Open Items Blocking Gate: Min Elixir/OTP, font baseline, tolerance thresholds, CI platforms → [NEEDS CLARIFICATION]

Result: Initial Constitution Check = FAIL until clarifications are resolved.

## Project Structure

### Documentation (this feature)
```
specs/001-implement-fully-working/
├── plan.md              # This file (/plan command output)
├── research.md          # Phase 0 output (/plan command)
├── data-model.md        # Phase 1 output (/plan command)
├── quickstart.md        # Phase 1 output (/plan command)
└── contracts/           # Phase 1 output (/plan command)
    └── renderer-contract.md
```

### Source Code (repository root)
```
# Single Mix project (library)
lib/
├── canvas_craft.ex                  # Public API entry (canvas creation, draw ops facade)
├── canvas_craft/renderer.ex         # Behaviour: backend contract
├── canvas_craft/canvas.ex           # Canvas struct + pure ops
├── canvas_craft/path.ex             # Path DSL/data
├── canvas_craft/paint.ex            # Fill/Stroke styles
├── canvas_craft/text_spec.ex        # Text parameters
└── canvas_craft/backends/
    └── skia.ex                      # Skia backend adapter (calls into native/port)

native/                               # If Rustler NIF selected
└── canvas_craft_skia/
    ├── Cargo.toml
    └── src/lib.rs

port/                                 # If external process approach selected (alternative)
└── skia_port/
    └── README.md

priv/
├── fonts/DejaVuSans.ttf             # [NEEDS CLARIFICATION] Bundled test font for determinism
└── golden/                          # Expected images for golden tests

test/
├── conformance/                      # Backend-agnostic tests (run for Skia)
├── property/
├── integration/
└── unit/
```

**Structure Decision**: Single Mix library. Backends live under `lib/canvas_craft/backends/` with
native integration in `native/` (Rustler) or `port/` as an alternative (choose during research).
Tests organized by type; golden assets in `priv/golden`.

## Phase 0: Outline & Research
1. **Extract unknowns from Technical Context** above:
   - Min supported Elixir/OTP → compatibility matrix
   - Backend integration method → Rustler NIF vs. Port (trade-offs: safety, performance)
   - Skia binding choice → skia-safe vs. custom bindings
   - Font baseline → system vs bundled font for deterministic text rendering
   - Golden-test thresholds → per-channel Δ vs PSNR criteria
   - CI platforms → macOS vs macOS+Linux; installing Skia in CI
2. **Generate and dispatch research agents**:
   ```
   Task: "Research Rustler dirty NIF requirements and scheduler safety for Skia drawing"
   Task: "Evaluate skia-safe vs custom bindings for MVP scope"
   Task: "Decide test font strategy for deterministic text output"
   Task: "Define golden image tolerance metrics suitable for Skia"
   Task: "Document CI setup for Skia on macOS/Linux"
   ```
3. **Consolidate findings** in `research.md` using format:
   - Decision, Rationale, Alternatives considered, Open Questions (if any)

**Output**: research.md created with open questions marked [NEEDS CLARIFICATION]

## Phase 1: Design & Contracts
*Prerequisites: research.md complete*

1. **Extract entities from feature spec** → `data-model.md`:
   - Canvas, Path, Paint, TextSpec, Image
2. **Generate API contracts** from functional requirements:
   - Define `CanvasCraft.Renderer` behaviour contract (functions, typespecs)
   - Document backend selection and configuration keys
   - Output conformance checklist to `/contracts/renderer-contract.md`
3. **Generate contract tests** from contracts:
   - Conformance tests per capability: clear, rects, paths, text, transforms, export
   - Golden-image tests with tolerance gates
   - Property tests for geometry invariants
   - Tests MUST fail initially (no implementation)
4. **Extract test scenarios** from user stories:
   - Integration tests for example scenes
   - Quickstart example validation
5. **Update agent file incrementally** (O(1) operation):
   - Run `.specify/scripts/bash/update-agent-context.sh copilot`
   - Add only NEW tech: Rustler, Skia, StreamData, Benchee (if selected)

**Output**: data-model.md, /contracts/renderer-contract.md, failing tests, quickstart.md

## Phase 2: Task Planning Approach
*This section describes what the /tasks command will do - DO NOT execute during /plan*

**Task Generation Strategy**:
- Load `.specify/templates/tasks-template.md` as base
- Generate tasks from Phase 1 design docs (contracts, data model, quickstart)
- Each contract → conformance test task [P]
- Each entity → module skeleton task [P]
- Each scenario → integration test task
- Implementation tasks to make tests pass

**Ordering Strategy**:
- TDD order: Tests before implementation 
- Dependency order: Core data structures → behaviour → backend adapter → native layer
- Mark [P] for parallel execution (independent files)

**Estimated Output**: 25-30 numbered, ordered tasks in tasks.md

**IMPORTANT**: This phase is executed by the /tasks command, NOT by /plan

## Phase 3+: Future Implementation
*These phases are beyond the scope of the /plan command*

**Phase 3**: Task execution (/tasks command creates tasks.md)  
**Phase 4**: Implementation (execute tasks.md following constitutional principles)  
**Phase 5**: Validation (run tests, execute quickstart.md, performance validation)

## Complexity Tracking
*Fill ONLY if Constitution Check has violations that must be justified*

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| — | — | — |

## Progress Tracking
*This checklist is updated during execution flow*

**Phase Status**:
- [ ] Phase 0: Research complete (/plan command)
- [ ] Phase 1: Design complete (/plan command)
- [ ] Phase 2: Task planning complete (/plan command - describe approach only)
- [ ] Phase 3: Tasks generated (/tasks command)
- [ ] Phase 4: Implementation complete
- [ ] Phase 5: Validation passed

**Gate Status**:
- [ ] Initial Constitution Check: PASS
- [ ] Post-Design Constitution Check: PASS
- [ ] All NEEDS CLARIFICATION resolved
- [ ] Complexity deviations documented

---
*Based on Constitution v1.0.0 - See `.specify/memory/constitution.md`*
