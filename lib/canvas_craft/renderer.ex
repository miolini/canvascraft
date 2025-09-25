defmodule CanvasCraft.Renderer do
  @moduledoc """
  Behaviour defining the backend-agnostic rendering contract for CanvasCraft.
  Backends implement these callbacks; the facade delegates to them.

  This minimal contract supports:
  - Creating a surface of given width/height
  - Exporting to PNG/WEBP encodings
  - Exporting the raw RGBA buffer (stride-aligned)

  Expanded primitive families and capability discovery:
  - Images (load/draw, sampling)
  - Gradients & shaders
  - Color/image filters
  - Blending (blend modes) and save layers
  - Clipping (rect/path)
  - Shapes (round rect, oval/circle, arc)
  """

  @typedoc "Opaque backend surface handle"
  @type surface :: term()

  @typedoc "Canvas width in pixels"
  @type width :: pos_integer()

  @typedoc "Canvas height in pixels"
  @type height :: pos_integer()

  @typedoc "Bytes per row in the raw RGBA buffer (>= width*4)"
  @type stride :: non_neg_integer()

  @typedoc "Raw export tuple: {width, height, stride, rgba_binary}"
  @type raw_export :: {width, height, stride, binary()}

  @typedoc "Feature atoms for capability discovery"
  @type feature ::
          :images
          | :gradients
          | :filters
          | :blending
          | :clipping
          | :effects

  @doc """
  Capability discovery: return a set of supported features.
  """
  @callback capabilities() :: MapSet.t(feature())

  @doc """
  Create a new drawing surface.

  Expected to allocate any necessary backend resources to draw into a
  width×height canvas. Options are backend-specific.
  """
  @callback new_surface(width :: width(), height :: height(), opts :: keyword()) ::
              {:ok, surface} | {:error, term()}

  @doc """
  Export the current surface as a PNG (or PNG-like) binary.
  """
  @callback export_png(surface, opts :: keyword()) :: {:ok, binary()} | {:error, term()}

  @doc """
  Export the current surface as a WEBP (or WEBP-like) binary.
  """
  @callback export_webp(surface, opts :: keyword()) :: {:ok, binary()} | {:error, term()}

  @doc """
  Export the raw RGBA buffer from the surface.

  Returns {width, height, stride, rgba_binary} where rgba_binary is
  8-bit per channel, premultiplied or straight depending on backend.
  """
  @callback export_raw(surface) ::
              {:ok, raw_export()} | {:error, term()}

  # Representative callbacks for primitive families (backends may ignore when unsupported)

  # Images
  @callback load_image_from_path(surface, path :: String.t()) :: {:ok, term()} | {:error, term()}
  @callback load_image_from_binary(surface, data :: binary()) :: {:ok, term()} | {:error, term()}
  @callback draw_image(surface, image_ref :: term(), x :: number(), y :: number(), opts :: keyword()) :: :ok | {:error, term()}

  # Gradients
  @callback set_linear_gradient(surface, x0 :: number(), y0 :: number(), x1 :: number(), y1 :: number(), stops :: list()) :: :ok | {:error, term()}
  @callback set_radial_gradient(surface, cx :: number(), cy :: number(), r :: number(), stops :: list()) :: :ok | {:error, term()}

  # Filters
  @callback set_color_filter(surface, filter :: term()) :: :ok | {:error, term()}
  @callback set_image_filter(surface, filter :: term()) :: :ok | {:error, term()}

  # Blending and save layers
  @callback set_blend_mode(surface, mode :: atom()) :: :ok | {:error, term()}
  @callback save_layer(surface, opts :: keyword()) :: :ok | {:error, term()}

  # Clipping
  @callback clip_rect(surface, x :: number(), y :: number(), w :: number(), h :: number(), mode :: atom()) :: :ok | {:error, term()}

  # Shapes
  @callback draw_round_rect(surface, x :: number(), y :: number(), w :: number(), h :: number(), rx :: number(), ry :: number()) :: :ok | {:error, term()}
  @callback draw_oval(surface, cx :: number(), cy :: number(), rx :: number(), ry :: number()) :: :ok | {:error, term()}
  @callback draw_arc(surface, cx :: number(), cy :: number(), r :: number(), start_deg :: number(), sweep_deg :: number()) :: :ok | {:error, term()}
end
