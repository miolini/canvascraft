defmodule CanvasCraft.Font do
  @moduledoc """
  Font loader utility for CanvasCraft.
  Loads fonts from priv/fonts, with fallback to DejaVuSans.ttf.
  """

  @default_font "priv/fonts/DejaVuSans.ttf"

  @doc "Load a font by name from priv/fonts, fallback to default if missing."
  @spec load(String.t()) :: {:ok, binary()} | {:error, term()}
  def load(name) when is_binary(name) do
    path = Path.join([:code.priv_dir(:canvas_craft), "fonts", name])
    case File.read(path) do
      {:ok, bin} -> {:ok, bin}
      _ -> File.read(@default_font)
    end
  end

  @doc "Return default font binary."
  @spec default() :: {:ok, binary()} | {:error, term()}
  def default, do: File.read(@default_font)
end
