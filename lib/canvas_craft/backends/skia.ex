defmodule CanvasCraft.Backends.Skia do
  @moduledoc """
  Skia backend module.

  Skia NIF integration is introduced in later tasks; until then this module
  reports the backend as unavailable.
  """

  @behaviour CanvasCraft.Renderer

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
