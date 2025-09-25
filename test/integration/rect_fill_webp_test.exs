defmodule CanvasCraft.RectFillWebPTest do
  use ExUnit.Case, async: true

  alias CanvasCraft.Backends.Reference
  alias CanvasCraft.GoldenHelper

  @golden Path.expand("../../priv/goldens/rect_16x16.webp", __DIR__)

  test "rect fill WEBP matches golden" do
    {:ok, handle} = CanvasCraft.create_canvas(16, 16, backend: Reference)
    {:ok, bin} = CanvasCraft.export_png(handle, format: :webp)

    tmp = Path.join(System.tmp_dir!(), "cc_rect_16x16.webp")
    File.write!(tmp, bin)

    assert :ok = GoldenHelper.compare_png_files(tmp, @golden)
  end
end
