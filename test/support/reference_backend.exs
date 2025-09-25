defmodule CanvasCraft.Backends.Reference do
  @moduledoc """
  Minimal in-memory reference backend to validate the renderer behaviour contract in tests.
  Produces deterministic WEBP/PNG-like binaries (mocked) for conformance tests.
  """
  @behaviour CanvasCraft.Renderer

  @impl true
  def capabilities, do: MapSet.new([:images, :gradients, :filters, :blending, :clipping, :effects])

  defmodule Surf do
    @moduledoc false
    defstruct [:w, :h, state: %{}]
  end

  @impl true
  def new_surface(w, h, _opts) when is_integer(w) and w > 0 and is_integer(h) and h > 0 do
    {:ok, %Surf{w: w, h: h}}
  end

  def new_surface(_, _, _), do: {:error, :invalid_dimensions}

  @impl true
  def export_png(%Surf{w: w, h: h}, _opts) do
    {:ok, ":png:#{w}x#{h}"}
  end

  @impl true
  def export_webp(%Surf{w: w, h: h}, _opts) do
    {:ok, ":webp:#{w}x#{h}"}
  end

  @impl true
  def export_raw(%Surf{w: w, h: h}) do
    stride = w * 4
    {:ok, {w, h, stride, :binary.copy(<<0>>, stride * h)}}
  end

  # T027 Gradients
  @impl true
  def set_linear_gradient(%Surf{} = _s, _x0, _y0, _x1, _y1, stops) when is_list(stops), do: :ok

  @impl true
  def set_radial_gradient(%Surf{} = _s, _cx, _cy, _r, stops) when is_list(stops), do: :ok
  # Images
  @impl true
  def load_image_from_path(%Surf{} = _s, path) when is_binary(path) do
    if File.exists?(path), do: {:ok, {:img, :from_path, path}}, else: {:error, :enoent}
  end

  @impl true
  def load_image_from_binary(%Surf{} = _s, data) when is_binary(data) and byte_size(data) > 0 do
    {:ok, {:img, :from_bin, byte_size(data)}}
  end

  @impl true
  def draw_image(%Surf{} = _s, {:img, _, _}, _x, _y, _opts), do: :ok

  # Filters
  @impl true
  def set_color_filter(%Surf{} = _s, _filter), do: :ok

  @impl true
  def set_image_filter(%Surf{} = _s, _filter), do: :ok

  # Blending & save layer
  @impl true
  def set_blend_mode(%Surf{} = _s, _mode), do: :ok

  @impl true
  def save_layer(%Surf{} = _s, _opts), do: :ok

  # Clipping
  @impl true
  def clip_rect(%Surf{} = _s, _x, _y, _w, _h, _mode), do: :ok

  # Shapes
  @impl true
  def draw_round_rect(%Surf{} = _s, _x, _y, _w, _h, _rx, _ry), do: :ok

  @impl true
  def draw_oval(%Surf{} = _s, _cx, _cy, _rx, _ry), do: :ok

  @impl true
  def draw_arc(%Surf{} = _s, _cx, _cy, _r, _start_deg, _sweep_deg), do: :ok

  @impl true
  def set_path_effect(%Surf{} = _s, _effect), do: :ok
end
