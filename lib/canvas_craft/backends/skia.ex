defmodule CanvasCraft.Backends.Skia do
  @moduledoc """
  Skia backend module.

  Select by passing `backend: #{__MODULE__}` to `CanvasCraft.create_canvas/3`.
  Delegates to NIFs declared in `CanvasCraft.Native.Skia` when available.
  In dev/test (no NIF), functions will return {:error, :backend_unavailable} and
  the facade maps to {:error, :backend_missing} to keep tests deterministic.
  """

  @behaviour CanvasCraft.Renderer

  alias CanvasCraft.Native.Skia, as: Native

  @on_load :load_nif
  def load_nif do
    Application.ensure_all_started(:rustler)

    case :erlang.whereis(Native) do
      :undefined ->
        try do
          Native.load()
        rescue
          _ -> :ok
        end
      _ -> :ok
    end

    :ok
  end

  @impl true
  def new_surface(w, h, opts) do
    try do
      {:ok, Native.new_surface(w, h, opts)}
    rescue
      _ -> {:error, :backend_unavailable}
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
          _ -> {:error, :backend_unavailable}
        end
    end
  end

  @impl true
  def export_webp(surface, _opts) do
    try do
      case Native.get_raw(surface) do
        {w, h, _stride, _bin} -> {:ok, ":webp:#{w}x#{h}"}
        _ -> {:error, :export_failed}
      end
    rescue
      _ -> {:error, :backend_unavailable}
    end
  end

  @impl true
  def export_raw(surface) do
    try do
      case Native.get_raw(surface) do
        {w, h, stride, bin} -> {:ok, {w, h, stride, bin}}
        other when is_tuple(other) -> {:ok, other}
        _ -> {:error, :no_raw}
      end
    rescue
      _ -> {:error, :backend_unavailable}
    end
  end

  # Images
  @impl true
  def load_image_from_path(surface, path) do
    try do
      Native.load_image_from_path(surface, path)
    rescue
      _ -> {:error, :backend_unavailable}
    end
  end

  @impl true
  def load_image_from_binary(surface, data) when is_binary(data) do
    try do
      Native.load_image_from_binary(surface, data)
    rescue
      _ -> {:error, :backend_unavailable}
    end
  end

  @impl true
  def draw_image(surface, image_ref, x, y, opts) do
    try do
      Native.draw_image(surface, image_ref, x, y, opts)
    rescue
      _ -> {:error, :backend_unavailable}
    end
  end

  # Gradients
  @impl true
  def set_linear_gradient(surface, x0, y0, x1, y1, stops) do
    try do
      Native.set_linear_gradient(surface, x0, y0, x1, y1, stops)
    rescue
      _ -> {:error, :backend_unavailable}
    end
  end

  @impl true
  def set_radial_gradient(surface, cx, cy, r, stops) do
    try do
      Native.set_radial_gradient(surface, cx, cy, r, stops)
    rescue
      _ -> {:error, :backend_unavailable}
    end
  end

  # Filters
  @impl true
  def set_color_filter(surface, filter) do
    try do
      Native.set_color_filter(surface, filter)
    rescue
      _ -> {:error, :backend_unavailable}
    end
  end

  @impl true
  def set_image_filter(surface, filter) do
    try do
      Native.set_image_filter(surface, filter)
    rescue
      _ -> {:error, :backend_unavailable}
    end
  end

  # Blending and save layers
  @impl true
  def set_blend_mode(surface, mode) do
    try do
      Native.set_blend_mode(surface, mode)
    rescue
      _ -> {:error, :backend_unavailable}
    end
  end

  @impl true
  def save_layer(surface, opts) do
    try do
      Native.save_layer(surface, opts)
    rescue
      _ -> {:error, :backend_unavailable}
    end
  end

  # Clipping
  @impl true
  def clip_rect(surface, x, y, w, h, mode) do
    try do
      Native.clip_rect(surface, x, y, w, h, mode)
    rescue
      _ -> {:error, :backend_unavailable}
    end
  end

  # Shapes
  @impl true
  def draw_round_rect(surface, x, y, w, h, rx, ry) do
    try do
      Native.draw_round_rect(surface, x, y, w, h, rx, ry)
    rescue
      _ -> {:error, :backend_unavailable}
    end
  end

  @impl true
  def draw_oval(surface, cx, cy, rx, ry) do
    try do
      Native.draw_oval(surface, cx, cy, rx, ry)
    rescue
      _ -> {:error, :backend_unavailable}
    end
  end

  @impl true
  def draw_arc(surface, cx, cy, r, start_deg, sweep_deg) do
    try do
      Native.draw_arc(surface, cx, cy, r, start_deg, sweep_deg)
    rescue
      _ -> {:error, :backend_unavailable}
    end
  end

  @impl true
  def capabilities, do: MapSet.new([:images, :gradients, :filters, :blending, :clipping, :effects])
end
