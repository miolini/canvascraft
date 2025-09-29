defmodule CanvasCraft.Native.Skia do
  @moduledoc false

  use Rustler, otp_app: :canvas_craft, crate: :canvas_craft_skia

  def skia_hello, do: :erlang.nif_error(:nif_not_loaded)

  @doc false
  def new_surface(_w, _h, _opts \\ []), do: :erlang.nif_error(:nif_not_loaded)

  @doc false
  def get_raw(_surface), do: :erlang.nif_error(:nif_not_loaded)

  @doc false
  def get_rgba_buffer(_surface), do: :erlang.nif_error(:nif_not_loaded)

  # Text
  @doc false
  def font_load_path(_surface, _path), do: :erlang.nif_error(:nif_not_loaded)
  @doc false
  def font_set_size(_surface, _pt), do: :erlang.nif_error(:nif_not_loaded)
  @doc false
  def draw_text(_surface, _x, _y, _utf8, _r, _g, _b, _a), do: :erlang.nif_error(:nif_not_loaded)

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

  # Encoding (T022)
  @doc false
  def encode_webp(_surface, _opts \\ []), do: :erlang.nif_error(:nif_not_loaded)

  # Extended primitives (Phase 3.3b)
  # Images
  @doc false
  def load_image_from_path(_surface, _path), do: :erlang.nif_error(:nif_not_loaded)
  @doc false
  def load_image_from_binary(_surface, _data), do: :erlang.nif_error(:nif_not_loaded)
  @doc false
  def draw_image(_surface, _image_ref, _x, _y, _opts \\ []), do: :erlang.nif_error(:nif_not_loaded)

  # Gradients
  @doc false
  def set_linear_gradient(_surface, _x0, _y0, _x1, _y1, _stops), do: :erlang.nif_error(:nif_not_loaded)
  @doc false
  def set_radial_gradient(_surface, _cx, _cy, _r, _stops), do: :erlang.nif_error(:nif_not_loaded)

  # Filters
  @doc false
  def set_color_filter(_surface, _filter), do: :erlang.nif_error(:nif_not_loaded)
  @doc false
  def set_image_filter(_surface, _filter), do: :erlang.nif_error(:nif_not_loaded)

  # Blending and save layers
  @doc false
  def set_blend_mode(_surface, _mode), do: :erlang.nif_error(:nif_not_loaded)
  @doc false
  def save_layer(_surface, _opts \\ []), do: :erlang.nif_error(:nif_not_loaded)

  # Clipping
  @doc false
  def clip_rect(_surface, _x, _y, _w, _h, _mode), do: :erlang.nif_error(:nif_not_loaded)

  # Shapes
  @doc false
  def draw_round_rect(_surface, _x, _y, _w, _h, _rx, _ry), do: :erlang.nif_error(:nif_not_loaded)
  @doc false
  def draw_oval(_surface, _cx, _cy, _rx, _ry), do: :erlang.nif_error(:nif_not_loaded)
  @doc false
  def draw_arc(_surface, _cx, _cy, _r, _start_deg, _sweep_deg), do: :erlang.nif_error(:nif_not_loaded)

  # Path effects
  @doc false
  def set_path_effect(_surface, _effect), do: :erlang.nif_error(:nif_not_loaded)
  @doc false
  def clear(_surface, _r, _g, _b, _a), do: :erlang.nif_error(:nif_not_loaded)
  @doc false
  def fill_rect(_surface, _x, _y, _w, _h, _r, _g, _b, _a), do: :erlang.nif_error(:nif_not_loaded)
  @doc false
  def fill_circle(_surface, _cx, _cy, _radius, _r, _g, _b, _a), do: :erlang.nif_error(:nif_not_loaded)
end
