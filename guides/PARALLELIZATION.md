# Parallelization and Dirty Schedulers

## Overview

As of version 0.2.1, CanvasCraft uses Erlang's **dirty schedulers** for CPU-intensive and I/O-bound operations. This enables true parallel execution of rendering tasks without blocking the normal Erlang schedulers.

## What are Dirty Schedulers?

The Erlang VM has two types of schedulers:

1. **Normal Schedulers**: Handle lightweight, fast operations that shouldn't block for long periods
2. **Dirty Schedulers**: Handle operations that may take significant time
   - **Dirty CPU Schedulers**: For CPU-intensive work (rendering, encoding, etc.)
   - **Dirty I/O Schedulers**: For I/O operations (file loading, network, etc.)

## Benefits

### Before (without dirty schedulers)
- NIFs blocked normal schedulers
- Limited parallelization
- Poor responsiveness when rendering multiple canvases
- Other processes could be starved

### After (with dirty schedulers)
- ✅ True parallel rendering across multiple cores
- ✅ Non-blocking: other Erlang processes run smoothly
- ✅ Better throughput for batch rendering
- ✅ Improved responsiveness in web applications

## Which Operations Use Dirty Schedulers?

### Dirty CPU (CPU-intensive)
- `encode_webp/2` - WEBP encoding
- `get_rgba_buffer/1` - Large buffer copy
- `fill_rect/6` - Rectangle rendering with blending
- `fill_circle/5` - Circle rendering with MSAA antialiasing
- `draw_oval/5` - Oval rendering with gradient and MSAA
- `draw_text/5` - Text rendering with font rasterization
- `clear/5` - Bulk pixel operations

### Dirty I/O (I/O-bound)
- `font_load_path/2` - Font file loading from disk

### Normal Scheduler (fast operations)
- `new_surface/3` - Surface allocation
- `set_antialias/2` - Setting AA mode
- `set_radial_gradient/5` - Gradient configuration
- `font_set_size/2` - Font size setting

## Parallelization Example

```elixir
# Render multiple canvases in parallel using Task.async_stream
images = 1..10
|> Task.async_stream(
  fn i ->
    import CanvasCraft.Scene
    
    render width: 800, height: 600, path: "output_#{i}.webp" do
      clear({255, 255, 255, 255})
      circle(400, 300, 100 + i * 10, {255, 0, 0, 255})
    end
  end,
  max_concurrency: System.schedulers_online()
)
|> Enum.to_list()

# Each render runs on a dirty CPU scheduler
# Normal Erlang processes continue unaffected
```

## Performance Considerations

1. **Batch Processing**: Use `Task.async_stream/3` for rendering multiple images
2. **Concurrency Limit**: Set `max_concurrency` to match your CPU cores
3. **Memory**: Each surface allocates a buffer (width × height × 4 bytes)
4. **Overhead**: Very small canvases may not benefit from parallelization

## Monitoring

You can check dirty scheduler usage with:

```elixir
# In IEx
:erlang.system_info(:dirty_cpu_schedulers)
:erlang.system_info(:dirty_cpu_schedulers_online)
:erlang.statistics(:scheduler_wall_time)
```

## Technical Details

The dirty scheduler annotations are in the Rust NIF code:

```rust
#[rustler::nif(schedule = "DirtyCpu")]
fn encode_webp<'a>(...) -> NifResult<Term<'a>> {
    // CPU-intensive encoding work
}

#[rustler::nif(schedule = "DirtyIo")]
fn font_load_path<'a>(...) -> NifResult<Term<'a>> {
    // File system I/O
}
```

## References

- [Erlang NIF Documentation](https://www.erlang.org/doc/man/erl_nif.html)
- [Rustler Scheduling](https://github.com/rusterlium/rustler#scheduling)
- [OTP Dirty Schedulers](https://www.erlang.org/doc/man/erlang.html#system_info_dirty_schedulers)
