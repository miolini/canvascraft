defmodule CanvasCraft.Integration.BlendingTest do
  use ExUnit.Case, async: true
  alias CanvasCraft.Backends.Reference

  test "set blend and save layer" do
    {:ok, surf} = Reference.new_surface(18, 18, [])
    :ok = Reference.set_blend_mode(surf, :multiply)
    :ok = Reference.save_layer(surf, alpha: 0.8)
    {:ok, ":webp:18x18"} = Reference.export_webp(surf, [])
  end
end
