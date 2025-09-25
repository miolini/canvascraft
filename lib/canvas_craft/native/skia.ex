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

  # Paint state (T019)
  @doc false
  def set_fill_color(_surface, _r, _g, _b, _a), do: :erlang.nif_error(:nif_not_loaded)

  @doc false
  def set_stroke_color(_surface, _r, _g, _b, _a), do: :erlang.nif_error(:nif_not_loaded)

  @doc false
  def set_stroke_width(_surface, _w), do: :erlang.nif_error(:nif_not_loaded)

  @doc false
  def set_line_cap(_surface, _cap), do: :erlang.nif_error(:nif_not_loaded)

  @doc false
  def set_line_join(_surface, _join), do: :erlang.nif_error(:nif_not_loaded)

  @doc false
  def set_miter_limit(_surface, _limit), do: :erlang.nif_error(:nif_not_loaded)

  @doc false
  def set_antialias(_surface, _bool), do: :erlang.nif_error(:nif_not_loaded)

  # Transforms (T020)
  @doc false
  def save(_surface), do: :erlang.nif_error(:nif_not_loaded)
  @doc false
  def restore(_surface), do: :erlang.nif_error(:nif_not_loaded)
  @doc false
  def translate(_surface, _tx, _ty), do: :erlang.nif_error(:nif_not_loaded)
  @doc false
  def scale(_surface, _sx, _sy), do: :erlang.nif_error(:nif_not_loaded)
  @doc false
  def rotate(_surface, _deg), do: :erlang.nif_error(:nif_not_loaded)

  # Text drawing (T021)
  @doc false
  def font_load_path(_surface, _path), do: :erlang.nif_error(:nif_not_loaded)
  @doc false
  def font_set_size(_surface, _pt), do: :erlang.nif_error(:nif_not_loaded)
  @doc false
  def draw_text(_surface, _x, _y, _utf8_binary), do: :erlang.nif_error(:nif_not_loaded)

  # Encoding (T022)
  @doc false
  def encode_webp(_surface, _opts \\ []), do: :erlang.nif_error(:nif_not_loaded)
end
