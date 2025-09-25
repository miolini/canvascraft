defmodule CanvasCraft do
  @moduledoc """
  CanvasCraft - 2D graphics drawing library facade.

  This module delegates drawing operations to a pluggable backend.
  The canvas handle is represented as `{backend_module, backend_ref}`.
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
  Export the canvas to a PNG binary via its backend.
  """
  @spec export_png(canvas_handle, keyword()) :: {:ok, binary()} | {:error, term()}
  def export_png({backend, ref}, opts \\ []) do
    if function_exported?(backend, :export_png, 2) do
      backend.export_png(ref, opts)
    else
      {:error, :backend_missing}
    end
  end

  @doc """
  Export the canvas to a WEBP binary via its backend.
  """
  @spec export_webp(canvas_handle, keyword()) :: {:ok, binary()} | {:error, term()}
  def export_webp({backend, ref}, opts \\ []) do
    if function_exported?(backend, :export_webp, 2) do
      backend.export_webp(ref, opts)
    else
      {:error, :backend_missing}
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
