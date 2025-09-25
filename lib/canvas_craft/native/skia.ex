defmodule CanvasCraft.Native.Skia do
  @moduledoc false

  if Mix.env() == :prod do
    use Rustler, otp_app: :canvas_craft, crate: :canvas_craft_skia
  end

  # NIF entry points (populated by Rustler in prod). Fallback raises when NIF not loaded.
  def load, do: :ok

  def skia_hello, do: :erlang.nif_error(:nif_not_loaded)

  @doc false
  def new_surface(_w, _h, _opts \\ []), do: :erlang.nif_error(:nif_not_loaded)

  @doc false
  def get_raw(_surface), do: :erlang.nif_error(:nif_not_loaded)
end
