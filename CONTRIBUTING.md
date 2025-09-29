# Contributing to CanvasCraft

Thanks for your interest in contributing!

## Code of Conduct
This project follows a standard open-source code of conduct. Be respectful and inclusive.

## Development Setup
- Elixir >= 1.16, OTP >= 26
- Rust toolchain if you want to build the Skia NIF
- Run `mix deps.get`
- Tests: `mix test`
- Lint: `mix credo --strict`
- Types: `mix dialyzer`

## Commit Guidelines
- Use conventional commits (feat:, fix:, docs:, refactor:, chore:, test:)
- Keep commits small and focused
- Update docs when changing public APIs

## Pull Request Checklist
- [ ] Format passes: `mix format --check-formatted`
- [ ] Credo passes: `mix credo --strict`
- [ ] Dialyzer passes: `mix dialyzer`
- [ ] Tests pass: `mix test`
- [ ] If touching performance sensitive code, run the benches locally

## CI Gates
Our CI runs: format, Credo, Dialyzer, unit+integration tests, and a non-blocking benchmark step. PRs should be green on all required checks.

## Skia NIF
- By default, CI and local builds do NOT require the native library.
- To enable the NIF locally: `CANVAS_CRAFT_ENABLE_NIF=1 mix test` or when running examples.

## Issue Reports
Please include:
- Elixir/OTP versions and OS
- Steps to reproduce
- Expected vs actual behavior
- If rendering related, attach a minimal scene and, if possible, an output image
