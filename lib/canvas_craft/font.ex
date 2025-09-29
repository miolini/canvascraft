defmodule CanvasCraft.Font do
  @moduledoc """
  Font loader utility for CanvasCraft.
  Loads fonts from priv/fonts, with fallback to DejaVuSans.ttf.
  """

  @default_font "DejaVuSans.ttf"

  defp priv_fonts_path do
    Path.join([:code.priv_dir(:canvas_craft), "fonts"])
  end

  defp default_font_path do
    Path.join(priv_fonts_path(), @default_font)
  end

  @doc "Load a font by name from priv/fonts, fallback to default if missing."
  @spec load(String.t()) :: {:ok, binary()} | {:error, term()}
  def load(name) when is_binary(name) do
    path = Path.join(priv_fonts_path(), name)
    case File.read(path) do
      {:ok, bin} -> {:ok, bin}
      _ -> File.read(default_font_path())
    end
  end

  @doc "Return default font binary."
  @spec default() :: {:ok, binary()} | {:error, term()}
  def default, do: File.read(default_font_path())

  @doc "Return absolute path to the test/default font, raising if missing."
  @spec test_font!() :: String.t()
  def test_font! do
    path = default_font_path()
    if File.exists?(path), do: path, else: raise "default font not found at #{path}"
  end
end
