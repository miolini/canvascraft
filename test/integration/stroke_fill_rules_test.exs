defmodule CanvasCraft.StrokeFillRulesTest do
  use ExUnit.Case, async: true

  alias CanvasCraft.Backends.Reference
  alias CanvasCraft.GoldenHelper

  @golden Path.expand("../../priv/goldens/stroke_32x32.png", __DIR__)

  test "stroke join/cap and fill rule basic" do
    {:ok, handle} = CanvasCraft.create_canvas(32, 32, backend: Reference)

    # The Reference backend is mocked; we simply call export_png to get deterministic output
    {:ok, bin} = CanvasCraft.export_png(handle, format: :png)

    tmp = Path.join(System.tmp_dir!(), "cc_stroke_32x32.png")
    File.write!(tmp, bin)

    assert :ok = GoldenHelper.compare_png_files(tmp, @golden)
  end
end
