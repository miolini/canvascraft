defmodule CanvasCraft.Contract.Primitives.ImagesTest do
  use ExUnit.Case, async: true

  alias CanvasCraft.Backends.Reference

  setup do
    assert {:ok, surf} = Reference.new_surface(8, 8, [])
    {:ok, surf: surf}
  end

  test "load image from binary and draw", %{surf: surf} do
    assert {:ok, img} = Reference.load_image_from_binary(surf, <<1,2,3,4>>)
    assert :ok = Reference.draw_image(surf, img, 1, 2, sampling: :nearest)
  end

  test "load image from path errors on missing", %{surf: surf} do
    assert {:error, _} = Reference.load_image_from_path(surf, "/not/found.png")
  end
end
