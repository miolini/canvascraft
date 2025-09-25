defmodule CanvasCraft.CapabilitiesTest do
  use ExUnit.Case, async: true

  alias CanvasCraft.Backends.Reference

  test "backend reports capabilities" do
    caps = CanvasCraft.capabilities(Reference)
    assert MapSet.member?(caps, :images)
    assert CanvasCraft.supports?(Reference, :gradients)
  end
end
