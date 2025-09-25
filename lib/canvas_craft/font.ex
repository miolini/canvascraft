defmodule CanvasCraft.Font do
  @moduledoc """
  Utilities for deterministic font loading for tests and examples.
  """

  @doc """
  Return an absolute path to the bundled deterministic test font.
  Raises if the font is not found.
  """
  @spec test_font!() :: String.t()
  def test_font! do
    base = :code.priv_dir(:canvas_craft) |> to_string()
    path = Path.join([base, "fonts", "DejaVuSans.ttf"])

    case File.stat(path) do
      {:ok, %File.Stat{type: :regular}} -> path
      _ -> raise "Bundled test font missing at #{path}"
    end
  end
end
