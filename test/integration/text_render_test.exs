defmodule CanvasCraft.TextRenderTest do
  use ExUnit.Case, async: true

  alias CanvasCraft.Backends.Reference
  alias CanvasCraft.GoldenHelper

  @golden Path.expand("../../priv/goldens/text_64x24.png", __DIR__)

  test "text render with font and size matches golden" do
    font_path = CanvasCraft.Font.test_font!()
    assert File.exists?(font_path)

    {:ok, handle} = CanvasCraft.create_canvas(64, 24, backend: Reference)

    # Pass font opts (ignored by Reference backend but captured by API contract)
    {:ok, bin} = CanvasCraft.export_png(handle, format: :png, font: font_path, font_size: 14)

    tmp = Path.join(System.tmp_dir!(), "cc_text_64x24.png")
    File.write!(tmp, bin)

    assert :ok = GoldenHelper.compare_png_files(tmp, @golden)
  end
end
