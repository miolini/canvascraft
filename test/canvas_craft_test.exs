defmodule CanvasCraftTest do
  use ExUnit.Case, async: true

  test "hello" do
    assert CanvasCraft.hello() == :world
  end

  test "create_canvas with unavailable backend returns error" do
    assert {:error, :backend_missing} = CanvasCraft.create_canvas(10, 10)
  end

  test "export functions report missing/unsupported before canvas exists" do
    # simulate handle to hit guards cleanly
    handle = {CanvasCraft.Backends.Skia, :surf}
    assert {:error, :backend_missing} = CanvasCraft.export_png(handle)
    assert {:error, :unsupported} = CanvasCraft.export_raw({Module.concat([:Unknown]), :surf})
  end
end
