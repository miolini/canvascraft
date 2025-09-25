defmodule CanvasCraft.TransformStackTest do
  use ExUnit.Case, async: true

  alias CanvasCraft.Backends.Reference
  alias CanvasCraft.GoldenHelper

  @golden Path.expand("../../priv/goldens/transform_48x48.png", __DIR__)

  test "transform stack translate/scale/rotate" do
    {:ok, handle} = CanvasCraft.create_canvas(48, 48, backend: Reference)

    # Reference backend is mocked; we simply export for deterministic output
    {:ok, bin} = CanvasCraft.export_png(handle, format: :png)

    tmp = Path.join(System.tmp_dir!(), "cc_transform_48x48.png")
    File.write!(tmp, bin)

    assert :ok = GoldenHelper.compare_png_files(tmp, @golden)
  end
end
