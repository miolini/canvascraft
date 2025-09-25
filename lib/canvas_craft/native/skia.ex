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

  # Path building (T018)
  @doc false
  def path_begin(_surface), do: :erlang.nif_error(:nif_not_loaded)

  @doc false
  def path_move_to(_surface, _x, _y), do: :erlang.nif_error(:nif_not_loaded)

  @doc false
  def path_line_to(_surface, _x, _y), do: :erlang.nif_error(:nif_not_loaded)

  @doc false
  def path_bezier_to(_surface, _cx1, _cy1, _cx2, _cy2, _x, _y), do: :erlang.nif_error(:nif_not_loaded)

  @doc false
  def path_close(_surface), do: :erlang.nif_error(:nif_not_loaded)
end
