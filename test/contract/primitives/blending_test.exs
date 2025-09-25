defmodule CanvasCraft.Contract.Primitives.BlendingTest do
  use ExUnit.Case, async: true

  alias CanvasCraft.Backends.Reference

  setup do
    assert {:ok, surf} = Reference.new_surface(16, 16, [])
    {:ok, surf: surf}
  end

  test "set blend mode", %{surf: surf} do
    assert :ok = Reference.set_blend_mode(surf, :multiply)
  end

  test "save layer with paint opts", %{surf: surf} do
    assert :ok = Reference.save_layer(surf, alpha: 0.5)
  end
end
