defmodule CanvasCraft.Integration.ImagesTest do
  use ExUnit.Case, async: true
  alias CanvasCraft.Backends.Reference
  alias CanvasCraft.GoldenHelper

  @tag :images
  test "draw image then export webp" do
    {:ok, surf} = Reference.new_surface(16, 16, [])
    {:ok, img} = Reference.load_image_from_binary(surf, <<1,2,3,4,5>>)
    :ok = Reference.draw_image(surf, img, 0, 0, sampling: :nearest)
    {:ok, ":webp:16x16"} = Reference.export_webp(surf, [])
  end
end
