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
end
