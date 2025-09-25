defmodule CanvasCraft.Renderer do
  @moduledoc """
  Behaviour defining the backend-agnostic rendering contract for CanvasCraft.
  Backends implement these callbacks; the facade delegates to them.
  """

  @typedoc "Opaque backend surface handle"
  @type surface :: term()

  @callback new_surface(width :: pos_integer(), height :: pos_integer(), opts :: keyword()) ::
              {:ok, surface} | {:error, term()}

  @callback export_png(surface, opts :: keyword()) :: {:ok, binary()} | {:error, term()}

  @callback export_raw(surface) ::
              {:ok, {width :: non_neg_integer(), height :: non_neg_integer(), stride :: non_neg_integer(), rgba :: binary()}}
              | {:error, term()}
end
