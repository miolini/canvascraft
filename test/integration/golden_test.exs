defmodule CanvasCraft.GoldenTest do
  use ExUnit.Case, async: true

  alias CanvasCraft.Backends.Reference
  alias CanvasCraft.GoldenHelper

  @golden Path.expand("../../priv/goldens/rect_16x16.png", __DIR__)

  test "rect fill PNG matches golden" do
    {:ok, handle} = CanvasCraft.create_canvas(16, 16, backend: Reference)
    {:ok, bin} = CanvasCraft.export_png(handle, format: :png)
    # Write out to tmp and compare using helper
    tmp = Path.join(System.tmp_dir!(), "cc_rect_16x16.png")
    File.write!(tmp, bin)
    assert :ok = GoldenHelper.compare_png_files(tmp, @golden)
  end
end
