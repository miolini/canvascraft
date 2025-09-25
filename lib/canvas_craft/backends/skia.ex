defmodule CanvasCraft.Backends.Skia do
  @moduledoc """
  Skia backend module.

  Skia NIF integration is introduced in later tasks; until then this module
  reports the backend as unavailable.
  """

  @behaviour CanvasCraft.Renderer

  alias CanvasCraft.Native.Skia, as: Native

  @on_load :load_nif
  def load_nif do
    Application.ensure_all_started(:rustler)

    case :erlang.whereis(Native) do
      :undefined ->
        # Attempt to load; ignore failures in non-dev envs for now
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
  def new_surface(_w, _h, _opts) do
    {:error, :backend_unavailable}
  end

  @impl true
  def export_png(_surface, _opts) do
    {:error, :backend_unavailable}
  end

  @impl true
  def export_raw(_surface) do
    {:error, :backend_unavailable}
  end
end
