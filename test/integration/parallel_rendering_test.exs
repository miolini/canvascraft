defmodule CanvasCraft.ParallelRenderingTest do
  use ExUnit.Case, async: true

  @moduletag :integration

  describe "parallel rendering with dirty schedulers" do
    test "multiple canvases can render in parallel" do
      # Create multiple rendering tasks
      tasks = 1..8
      |> Enum.map(fn i ->
        Task.async(fn ->
          {:ok, handle} = CanvasCraft.create_canvas(200, 200)
          :ok = CanvasCraft.fill_rect(handle, 10 + i * 5, 10 + i * 5, 100, 100, {255, i * 30, 0, 255})
          :ok = CanvasCraft.fill_circle(handle, 100, 100, 50, {0, 0, 255, 200})
          {:ok, bin} = CanvasCraft.export_webp(handle)
          {i, byte_size(bin)}
        end)
      end)

      # Wait for all tasks to complete
      results = Task.await_many(tasks, 5000)

      # All tasks should complete successfully
      assert length(results) == 8
      Enum.each(results, fn {_i, size} ->
        assert size > 0, "Expected non-empty WEBP binary"
      end)
    end

    test "parallel rendering with antialiasing" do
      # Test that AA works correctly in parallel (uses more CPU)
      tasks = 1..4
      |> Enum.map(fn i ->
        Task.async(fn ->
          {:ok, handle} = CanvasCraft.create_canvas(400, 400)
          :ok = CanvasCraft.set_antialias(handle, 8)
          :ok = CanvasCraft.fill_circle(handle, 200, 200, 150, {255, 0, 0, 255})
          {:ok, bin} = CanvasCraft.export_webp(handle)
          {i, byte_size(bin)}
        end)
      end)

      results = Task.await_many(tasks, 10000)
      assert length(results) == 4
      Enum.each(results, fn {_i, size} ->
        assert size > 100, "Expected reasonably sized WEBP binary"
      end)
    end

    test "parallel export operations" do
      # Create one canvas and export it multiple times in parallel
      {:ok, handle} = CanvasCraft.create_canvas(300, 300)
      :ok = CanvasCraft.fill_rect(handle, 50, 50, 200, 200, {100, 150, 200, 255})

      # Parallel export operations
      tasks = 1..5
      |> Enum.map(fn _i ->
        Task.async(fn ->
          {:ok, bin} = CanvasCraft.export_webp(handle)
          byte_size(bin)
        end)
      end)

      results = Task.await_many(tasks, 5000)
      assert length(results) == 5

      # All exports should produce the same size
      [first | rest] = results
      Enum.each(rest, fn size ->
        assert size == first, "All exports should produce identical output"
      end)
    end

    test "parallel with Task.async_stream" do
      # More realistic batch rendering scenario
      results = 1..10
      |> Task.async_stream(
        fn i ->
          import CanvasCraft.Scene

          render width: 100, height: 100, path: nil do
            clear({255, 255, 255, 255})
            rect(10, 10, 80, 80, {i * 20, 100, 200, 255})
            circle(50, 50, 30, {255, 0, 0, 200})
          end
        end,
        max_concurrency: System.schedulers_online(),
        timeout: 5000
      )
      |> Enum.to_list()

      # Check all succeeded
      assert length(results) == 10
      Enum.each(results, fn result ->
        assert {:ok, {:ok, _bin}} = result
      end)
    end

    test "dirty schedulers don't block normal scheduler" do
      # Start a long-running rendering task
      task = Task.async(fn ->
        {:ok, handle} = CanvasCraft.create_canvas(1000, 1000)
        :ok = CanvasCraft.set_antialias(handle, 8)

        # Lots of rendering operations
        for x <- 0..19, y <- 0..19 do
          :ok = CanvasCraft.fill_circle(handle, x * 50, y * 50, 20, {x * 12, y * 12, 128, 255})
        end

        {:ok, _bin} = CanvasCraft.export_webp(handle)
        :rendering_complete
      end)

      # While rendering is happening, normal Erlang operations should be fast
      start = System.monotonic_time(:millisecond)

      # Do some lightweight Erlang work
      results = for _ <- 1..1000 do
        :erlang.pid_to_list(self())
        |> length()
      end

      elapsed = System.monotonic_time(:millisecond) - start

      # These lightweight operations should complete quickly
      # even while heavy rendering is in progress
      assert length(results) == 1000
      assert elapsed < 100, "Normal scheduler should not be blocked (took #{elapsed}ms)"

      # Wait for rendering to complete
      assert Task.await(task, 30000) == :rendering_complete
    end
  end

  describe "raw buffer operations" do
    test "parallel raw buffer export" do
      {:ok, handle} = CanvasCraft.create_canvas(200, 200)
      :ok = CanvasCraft.fill_rect(handle, 0, 0, 200, 200, {255, 128, 64, 255})

      # Export raw buffer in parallel
      tasks = 1..3
      |> Enum.map(fn _i ->
        Task.async(fn ->
          {:ok, {w, h, stride, bin}} = CanvasCraft.export_raw(handle)
          {w, h, stride, byte_size(bin)}
        end)
      end)

      results = Task.await_many(tasks, 5000)
      assert length(results) == 3

      # All should return same dimensions
      [{w, h, stride, size} | rest] = results
      assert w == 200
      assert h == 200
      assert stride >= 800
      assert size == 200 * 200 * 4

      Enum.each(rest, fn result ->
        assert result == {w, h, stride, size}
      end)
    end
  end
end
