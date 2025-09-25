defmodule CanvasCraft.Integration.FiltersTest do
  use ExUnit.Case, async: true
  alias CanvasCraft.Backends.Reference

  test "set filters and export" do
    {:ok, surf} = Reference.new_surface(12, 12, [])
    :ok = Reference.set_color_filter(surf, {:matrix, [1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1]})
    :ok = Reference.set_image_filter(surf, {:blur, 2.0, 2.0})
    {:ok, ":png:12x12"} = Reference.export_png(surf, [])
  end
end
