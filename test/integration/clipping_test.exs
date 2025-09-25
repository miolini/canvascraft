defmodule CanvasCraft.Integration.ClippingTest do
  use ExUnit.Case, async: true
  alias CanvasCraft.Backends.Reference

  test "clip then export" do
    {:ok, surf} = Reference.new_surface(10, 10, [])
    :ok = Reference.clip_rect(surf, 2, 2, 6, 6, :intersect)
    {:ok, ":png:10x10"} = Reference.export_png(surf, [])
  end
end
