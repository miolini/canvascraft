defmodule CanvasCraft.Contract.Primitives.ClippingTest do
  use ExUnit.Case, async: true

  alias CanvasCraft.Backends.Reference

  setup do
    assert {:ok, surf} = Reference.new_surface(20, 20, [])
    {:ok, surf: surf}
  end

  test "clip rect", %{surf: surf} do
    assert :ok = Reference.clip_rect(surf, 2, 2, 10, 10, :intersect)
  end
end
