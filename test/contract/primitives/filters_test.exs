defmodule CanvasCraft.Contract.Primitives.FiltersTest do
  use ExUnit.Case, async: true

  alias CanvasCraft.Backends.Reference

  setup do
    assert {:ok, surf} = Reference.new_surface(12, 12, [])
    {:ok, surf: surf}
  end

  test "set color filter", %{surf: surf} do
    assert :ok = Reference.set_color_filter(surf, {:matrix, [1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1]})
  end

  test "set image filter", %{surf: surf} do
    assert :ok = Reference.set_image_filter(surf, {:blur, 3.0, 3.0})
  end
end
