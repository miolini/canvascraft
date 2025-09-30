#!/usr/bin/env elixir
#
# Parallel Rendering Benchmark
#
# Compares sequential vs parallel rendering to demonstrate
# the performance benefits of dirty schedulers.
#
# Usage: mix run guides/examples/parallel_benchmark.exs

defmodule ParallelBenchmark do
  import CanvasCraft.Scene

  def run do
    IO.puts("\n" <> String.duplicate("=", 60))
    IO.puts("  CanvasCraft Parallel Rendering Benchmark")
    IO.puts(String.duplicate("=", 60) <> "\n")

    IO.puts("System Info:")
    IO.puts("  CPU Cores: #{System.schedulers_online()}")
    IO.puts("  Dirty CPU Schedulers: #{:erlang.system_info(:dirty_cpu_schedulers_online)}")
    IO.puts("  Dirty I/O Schedulers: #{:erlang.system_info(:dirty_io_schedulers)}\n")

    canvas_count = 50
    IO.puts("Rendering #{canvas_count} canvases (400x400 with AA)...\n")

    # Sequential rendering
    IO.write("Sequential: ")
    seq_time = benchmark_sequential(canvas_count)
    IO.puts("#{seq_time}ms (#{Float.round(seq_time / canvas_count, 2)}ms per canvas)")

    # Parallel rendering
    IO.write("Parallel:   ")
    par_time = benchmark_parallel(canvas_count)
    IO.puts("#{par_time}ms (#{Float.round(par_time / canvas_count, 2)}ms per canvas)")

    # Calculate speedup
    speedup = Float.round(seq_time / par_time, 2)
    efficiency = Float.round(speedup / System.schedulers_online() * 100, 1)

    IO.puts("\n" <> String.duplicate("-", 60))
    IO.puts("Results:")
    IO.puts("  Speedup: #{speedup}x")
    IO.puts("  Parallel Efficiency: #{efficiency}%")
    IO.puts("  Time Saved: #{seq_time - par_time}ms (#{Float.round((1 - par_time / seq_time) * 100, 1)}%)")
    IO.puts(String.duplicate("=", 60) <> "\n")

    print_analysis(speedup, efficiency)
  end

  defp benchmark_sequential(count) do
    {time, _result} = :timer.tc(fn ->
      Enum.each(1..count, fn i ->
        {:ok, _bin} = render_canvas(i)
      end)
    end)
    div(time, 1000)
  end

  defp benchmark_parallel(count) do
    {time, _result} = :timer.tc(fn ->
      1..count
      |> Task.async_stream(
        fn i -> render_canvas(i) end,
        max_concurrency: System.schedulers_online(),
        timeout: 30_000
      )
      |> Enum.to_list()
    end)
    div(time, 1000)
  end

  defp render_canvas(i) do
    render width: 400, height: 400, path: nil do
      # Background gradient effect
      clear({240 - i, 240, 245, 255})

      # Antialiased circles
      circle(200, 200, 150, {i * 4, 100, 200, 200}, aa: 8)
      circle(150, 150, 80, {200, i * 4, 100, 180}, aa: 8)
      circle(250, 250, 60, {100, 200, i * 4, 160}, aa: 8)

      # Some rectangles
      for x <- 0..3 do
        rect(x * 100, 0, 90, 90, {x * 60, 100, 150, 120})
      end
    end
  end

  defp print_analysis(speedup, efficiency) do
    IO.puts("Analysis:")

    cond do
      speedup > System.schedulers_online() * 0.8 ->
        IO.puts("  🌟 Excellent parallelization!")
        IO.puts("  Nearly linear speedup achieved.")

      speedup > System.schedulers_online() * 0.5 ->
        IO.puts("  ✅ Good parallelization!")
        IO.puts("  Significant performance improvement from using multiple cores.")

      speedup > 1.5 ->
        IO.puts("  ⚠️  Moderate parallelization.")
        IO.puts("  Some benefit from parallel execution, but room for improvement.")

      true ->
        IO.puts("  ⚠️  Limited parallelization benefit.")
        IO.puts("  Consider larger workloads or check for bottlenecks.")
    end

    IO.puts("\nWith dirty schedulers:")
    IO.puts("  ✓ Each render runs independently on dirty CPU schedulers")
    IO.puts("  ✓ Normal BEAM schedulers remain free for other work")
    IO.puts("  ✓ True parallelization without blocking the VM")
    IO.puts("  ✓ Scales with available CPU cores")

    if efficiency > 70 do
      IO.puts("\n💡 Efficiency > 70% indicates excellent CPU utilization!")
    end
  end
end

ParallelBenchmark.run()
