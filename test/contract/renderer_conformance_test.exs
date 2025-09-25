defmodule CanvasCraft.RendererConformanceTest do
  use ExUnit.Case, async: true

  alias CanvasCraft.Backends.Reference

  test "new_surface returns a surface with positive dims" do
    assert {:ok, {Reference, _ref}} = CanvasCraft.create_canvas(10, 20, backend: Reference)
  end

  test "export_webp returns deterministic binary" do
    {:ok, handle} = CanvasCraft.create_canvas(16, 16, backend: Reference)
    assert {:ok, ":webp:16x16"} = CanvasCraft.export_png(handle, format: :webp)
  end

  test "export_raw returns correct buffer size" do
    {:ok, handle} = CanvasCraft.create_canvas(4, 2, backend: Reference)
    assert {:ok, {4, 2, 16, bin}} = CanvasCraft.export_raw(handle)
    assert byte_size(bin) == 32
  end
end
