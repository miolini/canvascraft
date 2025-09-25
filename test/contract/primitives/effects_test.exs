defmodule CanvasCraft.Contract.Primitives.EffectsTest do
  use ExUnit.Case, async: true

  alias CanvasCraft.Backends.Reference

  setup do
    assert {:ok, surf} = Reference.new_surface(24, 24, [])
    {:ok, surf: surf}
  end

  test "draw round rect", %{surf: surf} do
    assert :ok = Reference.draw_round_rect(surf, 1, 2, 10, 8, 2, 2)
  end

  test "draw oval", %{surf: surf} do
    assert :ok = Reference.draw_oval(surf, 12, 12, 6, 4)
  end

  test "draw arc", %{surf: surf} do
    assert :ok = Reference.draw_arc(surf, 12, 12, 10, 0, 90)
  end
end
