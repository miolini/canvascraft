defmodule CanvasCraft.Backends.Reference do
  @moduledoc """
  Minimal in-memory reference backend to validate the renderer behaviour contract in tests.
  Produces deterministic WEBP/PNG-like binaries (mocked) for conformance tests.
  """
  @behaviour CanvasCraft.Renderer

  defmodule Surf do
    @moduledoc false
    defstruct [:w, :h]
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
end
