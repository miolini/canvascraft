<!--
Sync Impact Report
- Version change: N/A → 1.0.0
- Modified principles: N/A (initial adoption)
- Added sections:
  • Core Principles (5)
  • Architectural Constraints & Technology Standards
  • Development Workflow & Quality Gates
  • Governance
- Removed sections: None
- Templates requiring updates:
  ✅ .specify/templates/plan-template.md (path/version reference)
  ✅ .specify/templates/spec-template.md (aligned; no changes needed)
  ✅ .specify/templates/tasks-template.md (aligned; no changes needed)
  ⚠ README.md (absent) → add project overview referencing constitution principles
  ⚠ docs/quickstart.md (absent) → add backend setup with Skia
- Follow-up TODOs:
  • Define concrete performance targets after initial profiling (bench suite to set p95 frame/render times)
-->

# CanvasCraft Constitution

## Core Principles

### I. Idiomatic Elixir, Pure API Surfaces
All public APIs MUST be idiomatic Elixir: pure functions when feasible, immutable data,
no hidden global state. Functions MUST use typespecs and return {:ok, value} | {:error, reason}
for recoverable errors; crashes are reserved for programmer errors. Long-running or blocking
work MUST avoid scheduler starvation; NIFs, if used, MUST be dirty and respect BEAM safety.
Rationale: Ensures reliability on the BEAM, composability, and predictable failure semantics.

### II. Backend-Agnostic Rendering via Behaviours
Rendering is abstracted behind a `CanvasCraft.Renderer` behaviour with a stable contract
(surface creation, path ops, paint/text, transforms, rasterize/export). Backends MUST
implement and pass the shared conformance test suite. The MVP MUST provide a Skia backend;
additional backends MAY be added without changing the public API. Rationale: Multiple
backends with one API, enabling portability and future engines.

### III. Test-First with Conformance and Property Testing
TDD is mandatory. Contract tests define renderer behaviour; each backend MUST pass them.
Geometry and color operations SHOULD use property-based tests (e.g., stream_data) to ensure
algebraic laws (associativity, bounds, invariants). Golden-image tests MUST use tolerances
(delta/PSNR) to account for backend-level numeric differences. Rationale: Prevents regressions
and guarantees cross-backend consistency.

### IV. Performance, Determinism, and Safety
Core operations MUST be benchmarked; performance changes MUST be measured in CI. Rendering
results for the same inputs MUST be deterministic per backend. Memory ownership across NIFs
MUST be explicit; no unbounded allocations or leaks. Any unsafe operations MUST be isolated
behind well-documented modules with tests. Rationale: Graphics workloads are performance-
sensitive; determinism simplifies testing and debugging.

### V. Documentation, SemVer, and Compatibility Discipline
Public API stability follows SemVer. Breaking changes require a MAJOR bump with migration
notes. New capabilities are MINOR; fixes/clarifications are PATCH. Every release MUST update
CHANGELOG and docs with runnable examples. Deprecations MUST include warnings and a supported
replacement for at least one MINOR release. Rationale: Predictable evolution for library users.

## Architectural Constraints & Technology Standards

- Language/Runtime: Elixir (BEAM). Native code MAY be used for backends via Rust NIFs or Ports;
  NIFs MUST be dirty and carefully bounded; Ports MAY be used for isolation.
- Backends: The project MUST support multiple renderer backends. The MVP MUST include a fully
  working Skia backend capable of rasterizing to image buffers/files.
- API Surface: Primary API is a functional drawing context module; no UI frameworks included.
- Platforms: macOS and Linux targets initially; Windows support MAY follow.
- Build/Tooling: Mix project; dialyzer and formatter enabled; CI runs tests, dialyzer, formatter,
  and benchmarks (non-blocking threshold checks initially).
- Logging: Minimal and structured. Debug visuals provided via explicit API, not implicit logs.
- Security/Sandboxing: No network or filesystem writes unless explicitly requested by API.

## Development Workflow & Quality Gates

- Code Review: Two approvals required for core modules and any backend implementation.
- Static Analysis: dialyzer MUST pass; no ignored warnings without a documented waiver.
- Tests: Unit + property tests + cross-backend conformance tests MUST pass before merge.
- Benchmarks: Core benchmark suite MUST run in CI; performance deltas over thresholds REQUIRE
  investigation notes before merge.
- Docs: Public modules MUST have moduledoc and doctests with copy-pastable examples.
- Release: SemVer tagging; CHANGELOG and upgrade notes required for MINOR/MAJOR.
- Waivers: Temporary waivers MUST include owner and expiry (< 60 days) and appear in CI output.

## Governance

This Constitution supersedes other practices where conflict arises. Amendments require a PR
that updates this document, includes a migration/impact note, and increments the version per
SemVer policy below. Compliance is verified during PR review and in CI via checks that read
this document where automated enforcement exists.

Amendment & Versioning Policy:
- MAJOR: Backward-incompatible API or governance changes, or removal/redefinition of principles.
- MINOR: New principle/section added, or materially expanded guidance.
- PATCH: Clarifications, wording, or non-semantic refinements.

Compliance Review Expectations:
- Every PR description MUST include a “Constitution Check” confirming adherence or listing
  approved waivers.
- CI MUST run tests, analysis, and benchmark gates defined above.
- Non-compliant changes MUST NOT be merged without an approved, time-bound waiver.

**Version**: 1.0.0 | **Ratified**: 2025-09-25 | **Last Amended**: 2025-09-25