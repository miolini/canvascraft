defmodule CanvasCraft.Contract.Primitives.GradientsTest do
  use ExUnit.Case, async: true

  alias CanvasCraft.Backends.Reference

  setup do
    assert {:ok, surf} = Reference.new_surface(10, 10, [])
    {:ok, surf: surf}
  end

  test "set linear gradient returns :ok", %{surf: surf} do
    stops = [{0.0, {255,0,0,255}}, {1.0, {0,0,255,255}}]
    assert :ok = Reference.set_linear_gradient(surf, 0, 0, 10, 0, stops)
  end

  test "set radial gradient returns :ok", %{surf: surf} do
    stops = [{0.0, {0,255,0,255}}, {1.0, {0,0,0,0}}]
    assert :ok = Reference.set_radial_gradient(surf, 5, 5, 4, stops)
  end
end
