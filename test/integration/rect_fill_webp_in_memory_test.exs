defmodule CanvasCraft.RectFillWebpInMemoryTest do
  use ExUnit.Case, async: true

  alias CanvasCraft.Backends.Skia
  alias CanvasCraft.GoldenHelper

  @golden Path.expand("../../priv/goldens/rect_64x64.webp", __DIR__)

  test "rect fill in-memory WEBP" do
    {:ok, handle} = CanvasCraft.create_canvas(64, 64, backend: Skia)
    :ok = CanvasCraft.fill_rect(handle, 8, 8, 48, 48, {0, 128, 255, 255})
    {:ok, bin} = CanvasCraft.export_webp(handle)

    assert :ok = GoldenHelper.compare_binary(bin, @golden)
  end
end
