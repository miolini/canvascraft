defmodule CanvasCraft do
  @moduledoc """
  CanvasCraft - 2D graphics drawing library facade.

  This module delegates drawing operations to a pluggable backend.
  The canvas handle is represented as `{backend_module, backend_ref}`.

  Drawing API (incremental; delegated to backends when available):
  - create_canvas/3
  - clear/2
  - fill_rect/5 (x, y, w, h)
  - export_png/2, export_raw/1
  """

  @typedoc "Backend-qualified canvas handle"
  @type canvas_handle :: {module(), term()}

  @doc """
  Return a simple atom for smoke tests.
  """
  @spec hello() :: :world
  def hello, do: :world

  @doc """
  Create a new canvas using the selected backend.

  Options:
  - :backend - backend module (default: CanvasCraft.Backends.Skia)
  - other backend-specific options
  """
  @spec create_canvas(pos_integer(), pos_integer(), keyword()) ::
          {:ok, canvas_handle} | {:error, term()}
  def create_canvas(width, height, opts \\ []) when width > 0 and height > 0 do
    backend = Keyword.get(opts, :backend, CanvasCraft.Backends.Skia)

    with true <- function_exported?(backend, :new_surface, 3) || {:error, :backend_missing},
         {:ok, ref} <- backend.new_surface(width, height, opts) do
      {:ok, {backend, ref}}
    else
      {:error, reason} -> {:error, reason}
      false -> {:error, :backend_missing}
    end
  end

  @doc """
  Clear the canvas to a given RGBA color (tuple {r,g,b,a}, 0..255).
  No-op for backends that don't support it yet.
  """
  @spec clear(canvas_handle, {0..255, 0..255, 0..255, 0..255}) :: :ok | {:error, term()}
  def clear({_backend, _ref}, _rgba), do: :ok

  @doc """
  Fill an axis-aligned rectangle.
  No-op for backends that don't support it yet; implemented later.
  """
  @spec fill_rect(canvas_handle, number(), number(), number(), number()) :: :ok | {:error, term()}
  def fill_rect({_backend, _ref}, _x, _y, _w, _h), do: :ok

  @doc """
  Export the canvas using backend. Defaults to PNG; if opts[:format] == :webp
  and the backend implements export_webp/2, that path is used.
  """
  @spec export_png(canvas_handle, keyword()) :: {:ok, binary()} | {:error, term()}
  def export_png({backend, ref}, opts \\ []) do
    case Keyword.get(opts, :format, :png) do
      :png ->
        if function_exported?(backend, :export_png, 2) do
          backend.export_png(ref, opts)
        else
          {:error, :backend_missing}
        end

      :webp ->
        cond do
          function_exported?(backend, :export_webp, 2) -> backend.export_webp(ref, opts)
          function_exported?(backend, :export_png, 2) -> backend.export_png(ref, Keyword.put(opts, :format, :webp))
          true -> {:error, :backend_missing}
        end

      _ -> {:error, :unsupported_format}
    end
  end

  @doc """
  Export the raw RGBA buffer from the backend, if supported.
  """
  @spec export_raw(canvas_handle) :: {:ok, {non_neg_integer(), non_neg_integer(), non_neg_integer(), binary()}} | {:error, term()}
  def export_raw({backend, ref}) do
    if function_exported?(backend, :export_raw, 1) do
      backend.export_raw(ref)
    else
      {:error, :unsupported}
    end
  end
end
