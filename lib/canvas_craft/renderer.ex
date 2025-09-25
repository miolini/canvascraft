defmodule CanvasCraft.Renderer do
  @moduledoc """
  Behaviour defining the backend-agnostic rendering contract for CanvasCraft.
  Backends implement these callbacks; the facade delegates to them.

  This minimal contract supports:
  - Creating a surface of given width/height
  - Exporting to PNG/WEBP encodings
  - Exporting the raw RGBA buffer (stride-aligned)
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
end
