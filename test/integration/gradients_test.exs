defmodule CanvasCraft.Integration.GradientsTest do
  use ExUnit.Case, async: true
  alias CanvasCraft.Backends.Reference

  test "apply gradients and export" do
    {:ok, surf} = Reference.new_surface(20, 10, [])
    :ok = Reference.set_linear_gradient(surf, 0, 0, 20, 0, [{0.0,{255,0,0,255}},{1.0,{0,0,255,255}}])
    {:ok, ":png:20x10"} = Reference.export_png(surf, [])
  end
end
