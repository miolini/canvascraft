defmodule CanvasCraft.Native.Skia do
  @moduledoc false

  if Mix.env() == :prod do
    use Rustler, otp_app: :canvas_craft, crate: :canvas_craft_skia
  end

  # Fallbacks and default implementations when NIF not loaded or in non-prod envs
  def load, do: :ok
  def skia_hello, do: :erlang.nif_error(:nif_not_loaded)
end
