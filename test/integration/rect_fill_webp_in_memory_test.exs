defmodule CanvasCraft.RectFillWebPInMemoryTest do
  use ExUnit.Case, async: true

  alias CanvasCraft.Backends.Reference
  alias CanvasCraft.GoldenHelper

  @golden Path.expand("../../priv/goldens/rect_16x16.webp", __DIR__)

  test "export_webp returns binary and matches golden via helper (no temp files)" do
    {:ok, handle} = CanvasCraft.create_canvas(16, 16, backend: Reference)
    assert {:ok, bin} = CanvasCraft.export_png(handle, format: :webp)
    assert is_binary(bin)
    assert :ok = GoldenHelper.compare_webp_binary(bin, @golden)
  end
end
