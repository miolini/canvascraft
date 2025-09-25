defmodule CanvasCraft.GeometryPropTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias CanvasCraft.Backends.Reference

  property "raw buffer dimensions and size are consistent" do
    check all w <- StreamData.integer(1..64),
              h <- StreamData.integer(1..64) do
      {:ok, handle} = CanvasCraft.create_canvas(w, h, backend: Reference)
      {:ok, {rw, rh, stride, bin}} = CanvasCraft.export_raw(handle)

      assert rw == w
      assert rh == h
      assert stride == w * 4
      assert byte_size(bin) == stride * h
    end
  end

  property "exported encodings reflect dimensions" do
    check all w <- StreamData.integer(1..64),
              h <- StreamData.integer(1..64) do
      {:ok, handle} = CanvasCraft.create_canvas(w, h, backend: Reference)

      {:ok, png} = CanvasCraft.export_png(handle, format: :png)
      {:ok, webp} = CanvasCraft.export_png(handle, format: :webp)

      assert png == ":png:#{w}x#{h}"
      assert webp == ":webp:#{w}x#{h}"
    end
  end
end
