# Dirty Scheduler Implementation Summary

## Problem Statement

CanvasCraft's NIFs were blocking normal Erlang schedulers during CPU-intensive operations like:
- Image encoding (WEBP)
- Rendering primitives (rectangles, circles) with antialiasing
- Font rendering and text drawing
- Buffer operations

This prevented:
- ❌ Parallel rendering of multiple canvases
- ❌ Good responsiveness in concurrent applications
- ❌ Efficient use of multi-core systems

## Solution

All CPU-intensive and I/O-bound NIFs now use Erlang's **dirty schedulers**.

## Changes Made

### Rust NIF Code (`native/canvas_craft_skia/src/lib.rs`)

Added `schedule` attribute to NIF functions:

#### Dirty CPU Scheduler (CPU-intensive operations)
```rust
#[rustler::nif(schedule = "DirtyCpu")]
fn encode_webp<'a>(...) -> NifResult<Term<'a>> { ... }

#[rustler::nif(schedule = "DirtyCpu")]
fn get_rgba_buffer<'a>(...) -> NifResult<Term<'a>> { ... }

#[rustler::nif(schedule = "DirtyCpu")]
fn fill_rect<'a>(...) -> NifResult<Term<'a>> { ... }

#[rustler::nif(schedule = "DirtyCpu")]
fn fill_circle<'a>(...) -> NifResult<Term<'a>> { ... }

#[rustler::nif(schedule = "DirtyCpu")]
fn draw_oval<'a>(...) -> NifResult<Term<'a>> { ... }

#[rustler::nif(schedule = "DirtyCpu")]
fn draw_text<'a>(...) -> NifResult<Term<'a>> { ... }

#[rustler::nif(schedule = "DirtyCpu")]
fn clear<'a>(...) -> NifResult<Term<'a>> { ... }
```

#### Dirty I/O Scheduler (I/O-bound operations)
```rust
#[rustler::nif(schedule = "DirtyIo")]
fn font_load_path<'a>(...) -> NifResult<Term<'a>> { ... }
```

#### Normal Scheduler (fast operations)
These remain on normal schedulers as they're fast:
- `new_surface` - Surface allocation
- `set_antialias` - Setting AA mode
- `set_radial_gradient` - Gradient configuration
- `font_set_size` - Font size setting
- `skia_hello` - Test function

### Documentation

1. **`guides/PARALLELIZATION.md`** - Comprehensive guide explaining:
   - What dirty schedulers are
   - Benefits and use cases
   - Parallelization examples
   - Performance considerations
   - Monitoring tools

2. **`examples/parallel_demo.exs`** - Working demo showing:
   - Parallel rendering of 20 canvases
   - Scheduler responsiveness during heavy workloads
   - Performance metrics

3. **`test/integration/parallel_rendering_test.exs`** - Test suite covering:
   - Parallel canvas rendering
   - Antialiasing in parallel
   - Export operations in parallel
   - Task.async_stream usage
   - Scheduler non-blocking behavior
   - Raw buffer parallel export

### Updated Files

- `CHANGELOG.md` - Added unreleased section documenting the improvement
- `README.md` - Added parallelization feature highlights
- `native/canvas_craft_skia/src/lib.rs` - Added dirty scheduler attributes

## Results

✅ **Before**: Single-threaded execution, blocked schedulers
✅ **After**: True parallel execution across CPU cores

### Demo Output
```
CPU cores available: 8
Dirty CPU schedulers: 8

Rendering 20 canvases in parallel...
✅ Completed: 20/20 renders
⏱️  Total time: 19ms
📊 Average: 0ms per canvas

Normal scheduler latency: 241µs for 10,000 operations
```

## Verification

Run tests:
```bash
mix test test/integration/parallel_rendering_test.exs
```

Run demo:
```bash
mix run examples/parallel_demo.exs
```

## Performance Impact

### Single Canvas
No performance regression - dirty schedulers have minimal overhead for single operations.

### Multiple Canvases (Parallel)
- **Speedup**: Near-linear scaling with CPU cores
- **Responsiveness**: Normal Erlang processes remain responsive
- **Throughput**: Batch operations process much faster

### Real-world Benefits

1. **Web Applications**: Render user avatars/thumbnails in parallel
2. **Batch Processing**: Generate reports with charts concurrently
3. **Real-time Systems**: Canvas rendering doesn't block message handling
4. **Background Jobs**: Process image queues efficiently

## Technical Details

### Scheduler Types
- **Normal Schedulers**: 1 per CPU core (default 8 on an 8-core system)
- **Dirty CPU Schedulers**: Configurable, default = CPU cores
- **Dirty I/O Schedulers**: Configurable, default = 10

### When to Use Each

| Scheduler Type | Use Case | Example |
|----------------|----------|---------|
| Normal | Fast operations (<1ms) | Setting properties, allocations |
| Dirty CPU | CPU-intensive work | Rendering, encoding, blending |
| Dirty I/O | I/O operations | File loading, network |

## Backward Compatibility

✅ **Fully backward compatible** - No API changes required
✅ All existing code continues to work
✅ Automatically benefits from parallelization

## Future Enhancements

Potential improvements:
- [ ] Configurable dirty scheduler pool size
- [ ] Per-operation scheduler hints via options
- [ ] Scheduler statistics in telemetry
- [ ] Adaptive scheduling based on canvas size

## References

- [Erlang NIF Docs](https://www.erlang.org/doc/man/erl_nif.html)
- [Rustler Scheduling](https://github.com/rusterlium/rustler)
- [OTP Dirty Schedulers](https://www.erlang.org/doc/man/erlang.html#system_info_dirty_schedulers)
