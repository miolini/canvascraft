defmodule CanvasCraft.Backends.Skia do
  @moduledoc """
  Skia backend module.

  Select by passing `backend: #{__MODULE__}` to `CanvasCraft.create_canvas/3`.
  Delegates to NIFs declared in `CanvasCraft.Native.Skia` when available.
  """

  @behaviour CanvasCraft.Renderer

  alias CanvasCraft.Native.Skia, as: Native

  defp ensure_app_started do
    # Ensure the application is loaded/started so Rustler can resolve priv dir
    _ = Application.ensure_all_started(:canvas_craft)
    :ok
  end

  @impl true
  def new_surface(w, h, opts) do
    ensure_app_started()
    # Touch a NIF function to ensure Rustler loads the library
    _ = (try do Native.skia_hello() rescue _ -> :ok end)
    try do
      {:ok, Native.new_surface(w, h, opts)}
    rescue
      _ -> {:error, :backend_missing}
    end
  end

  @impl true
  def export_png(surface, opts) do
    case Keyword.get(opts, :format, :png) do
      :webp -> export_webp(surface, opts)
      _ ->
        try do
          case Native.get_raw(surface) do
            {w, h, _stride, _bin} -> {:ok, ":png:#{w}x#{h}"}
            _ -> {:error, :export_failed}
          end
        rescue
          _ -> {:error, :backend_missing}
        end
    end
  end

  @impl true
  def export_webp(surface, opts) do
    try do
      cond do
        function_exported?(Native, :encode_webp, 2) ->
          case Native.encode_webp(surface, opts) do
            {:ok, bin} -> {:ok, bin}
            other -> other
          end
        true ->
          case Native.get_raw(surface) do
            {w, h, _stride, _bin} -> {:ok, ":webp:#{w}x#{h}"}
            _ -> {:error, :export_failed}
          end
      end
    rescue
      _ -> {:error, :backend_missing}
    end
  end

  @impl true
  def export_raw(surface) do
    try do
      cond do
        function_exported?(Native, :get_rgba_buffer, 1) ->
          case Native.get_rgba_buffer(surface) do
            {w, h, stride, bin} -> {:ok, {w, h, stride, bin}}
            other when is_tuple(other) -> {:ok, other}
            _ -> {:error, :no_raw}
          end
        true ->
          case Native.get_raw(surface) do
            {w, h, stride, bin} -> {:ok, {w, h, stride, bin}}
            other when is_tuple(other) -> {:ok, other}
            _ -> {:error, :no_raw}
          end
      end
    rescue
      _ -> {:error, :backend_missing}
    end
  end

  # Images
  @impl true
  def load_image_from_path(surface, path) do
    try do
      Native.load_image_from_path(surface, path)
    rescue
      _ -> {:error, :backend_missing}
    end
  end

  @impl true
  def load_image_from_binary(surface, data) when is_binary(data) do
    try do
      Native.load_image_from_binary(surface, data)
    rescue
      _ -> {:error, :backend_missing}
    end
  end

  @impl true
  def draw_image(surface, image_ref, x, y, opts) do
    try do
      Native.draw_image(surface, image_ref, x, y, opts)
    rescue
      _ -> {:error, :backend_missing}
    end
  end

  # Gradients
  @impl true
  def set_linear_gradient(surface, x0, y0, x1, y1, stops) do
    try do
      Native.set_linear_gradient(surface, x0, y0, x1, y1, stops)
    rescue
      _ -> {:error, :backend_missing}
    end
  end

  @impl true
  def set_radial_gradient(surface, cx, cy, r, stops) do
    try do
      Native.set_radial_gradient(surface, cx, cy, r, stops)
    rescue
      _ -> {:error, :backend_missing}
    end
  end

  # Filters
  @impl true
  def set_color_filter(surface, filter) do
    try do
      Native.set_color_filter(surface, filter)
    rescue
      _ -> {:error, :backend_missing}
    end
  end

  @impl true
  def set_image_filter(surface, filter) do
    try do
      Native.set_image_filter(surface, filter)
    rescue
      _ -> {:error, :backend_missing}
    end
  end

  # Blending and save layers
  @impl true
  def set_blend_mode(surface, mode) do
    try do
      Native.set_blend_mode(surface, mode)
    rescue
      _ -> {:error, :backend_missing}
    end
  end

  @impl true
  def save_layer(surface, opts) do
    try do
      Native.save_layer(surface, opts)
    rescue
      _ -> {:error, :backend_missing}
    end
  end

  # Clipping
  @impl true
  def clip_rect(surface, x, y, w, h, mode) do
    try do
      Native.clip_rect(surface, x, y, w, h, mode)
    rescue
      _ -> {:error, :backend_missing}
    end
  end

  # Shapes
  @impl true
  def draw_round_rect(surface, x, y, w, h, rx, ry) do
    try do
      Native.draw_round_rect(surface, x, y, w, h, rx, ry)
    rescue
      _ -> {:error, :backend_missing}
    end
  end

  @impl true
  def draw_oval(surface, cx, cy, rx, ry) do
    try do
      Native.draw_oval(surface, cx, cy, rx, ry)
    rescue
      _ -> {:error, :backend_missing}
    end
  end

  @impl true
  def draw_arc(surface, cx, cy, r, start_deg, sweep_deg) do
    try do
      Native.draw_arc(surface, cx, cy, r, start_deg, sweep_deg)
    rescue
      _ -> {:error, :backend_missing}
    end
  end

  # Path effects
  @impl true
  def set_path_effect(surface, effect) do
    try do
      Native.set_path_effect(surface, effect)
    rescue
      _ -> {:error, :backend_missing}
    end
  end

  def set_antialias(surface, aa) do
    try do
      Native.set_antialias(surface, aa)
    rescue
      _ -> {:error, :backend_missing}
    end
  end

  @impl true
  def capabilities, do: MapSet.new([:images, :gradients, :filters, :blending, :clipping, :effects])

  def fill_rect(surface, x, y, w, h, {r,g,b,a}) do
    try do
      Native.fill_rect(surface, x, y, w, h, r, g, b, a)
    rescue
      _ -> {:error, :backend_missing}
    end
  end

  def fill_circle(surface, cx, cy, radius, {r,g,b,a}) do
    try do
      Native.fill_circle(surface, cx, cy, radius, r, g, b, a)
    rescue
      _ -> {:error, :backend_missing}
    end
  end

  # Text
  def load_font(surface, path) do
    try do
      CanvasCraft.Native.Skia.font_load_path(surface, path)
    rescue
      _ -> {:error, :backend_missing}
    end
  end

  def set_font_size(surface, size) do
    try do
      CanvasCraft.Native.Skia.font_set_size(surface, size)
    rescue
      _ -> {:error, :backend_missing}
    end
  end

  def draw_text(surface, x, y, text, {r,g,b,a}) do
    try do
      case CanvasCraft.Native.Skia.draw_text(surface, x, y, text, r, g, b, a) do
        {:ok} -> :ok
        :ok -> :ok
        _ -> :ok
      end
    rescue
      _ -> {:error, :backend_missing}
    end
  end
end
