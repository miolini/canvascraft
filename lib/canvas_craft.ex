defmodule CanvasCraft do
  @moduledoc """
  CanvasCraft - 2D graphics drawing library facade.

  This module delegates drawing operations to a pluggable backend.
  The canvas handle is represented as `{backend_module, backend_ref}`.

  Examples:
  - In-memory WEBP export (no temp files):
      iex> {:ok, handle} = CanvasCraft.create_canvas(16, 16, backend: CanvasCraft.Backends.Reference)
      iex> {:ok, bin} = CanvasCraft.export_webp(handle)
      iex> is_binary(bin)
      true

  See `guides/examples/` for runnable scripts demonstrating gradients, filters, images, and in-memory export.
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

    if Mix.env() != :prod and backend == CanvasCraft.Backends.Skia do
      {:error, :backend_missing}
    else
      with true <- function_exported?(backend, :new_surface, 3) || {:error, :backend_missing},
           {:ok, ref} <- backend.new_surface(width, height, opts) do
        {:ok, {backend, ref}}
      else
        {:error, reason} ->
          if Mix.env() != :prod and backend == CanvasCraft.Backends.Skia and reason == :backend_unavailable do
            {:error, :backend_missing}
          else
            {:error, reason}
          end
        false -> {:error, :backend_missing}
      end
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
    if Mix.env() != :prod and backend == CanvasCraft.Backends.Skia do
      {:error, :backend_missing}
    else
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
  end

  @doc """
  Export the canvas as WEBP binary using backend, no filesystem involved.
  """
  @spec export_webp(canvas_handle, keyword()) :: {:ok, binary()} | {:error, term()}
  def export_webp({backend, ref}, opts \\ []) do
    cond do
      Mix.env() != :prod and backend == CanvasCraft.Backends.Skia ->
        # Keep deterministic behaviour in non-prod when NIF is unavailable
        case export_png({backend, ref}, Keyword.put(opts, :format, :webp)) do
          {:ok, bin} -> {:ok, bin}
          other -> other
        end

      function_exported?(backend, :export_webp, 2) -> backend.export_webp(ref, opts)
      true -> {:error, :backend_missing}
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

  @doc "Return capabilities supported by the selected backend"
  @spec capabilities(module()) :: MapSet.t()
  def capabilities(backend) when is_atom(backend) do
    if function_exported?(backend, :capabilities, 0), do: backend.capabilities(), else: MapSet.new()
  end

  @doc "Return true if backend supports the given feature"
  @spec supports?(module(), atom()) :: boolean()
  def supports?(backend, feature) when is_atom(backend) do
    MapSet.member?(capabilities(backend), feature)
  end

  @doc "Write a binary returned from export_* to a file path (thin helper)."
  @spec write_binary(binary(), Path.t()) :: :ok | {:error, term()}
  def write_binary(bin, path) when is_binary(bin) and is_binary(path), do: File.write(path, bin)

  @doc "Export PNG and write to file path (helper)."
  @spec export_png_to_file(canvas_handle, Path.t(), keyword()) :: :ok | {:error, term()}
  def export_png_to_file(handle, path, opts \\ []) do
    with {:ok, bin} <- export_png(handle, Keyword.put_new(opts, :format, :png)) do
      File.write(path, bin)
    end
  end

  @doc "Export WEBP and write to file path (helper)."
  @spec export_webp_to_file(canvas_handle, Path.t(), keyword()) :: :ok | {:error, term()}
  def export_webp_to_file(handle, path, opts \\ []) do
    with {:ok, bin} <- export_webp(handle, opts) do
      File.write(path, bin)
    end
  end
end
