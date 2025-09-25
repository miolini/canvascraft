defmodule CanvasCraft.Capabilities do
  @moduledoc """
  Capability and enums/typespecs for CanvasCraft primitive families and options.
  """

  @typedoc "Feature atoms for capability discovery"
  @type feature ::
          :images
          | :gradients
          | :filters
          | :blending
          | :clipping
          | :effects

  @typedoc "Line cap style"
  @type line_cap :: :butt | :round | :square

  @typedoc "Line join style"
  @type line_join :: :miter | :round | :bevel

  @typedoc "Clip operation mode"
  @type clip_mode :: :intersect | :difference

  @typedoc "Blend modes"
  @type blend_mode ::
          :src_over | :src | :dst | :clear |
          :multiply | :screen | :overlay | :darken | :lighten | :color_dodge | :color_burn |
          :hard_light | :soft_light | :difference | :exclusion | :hue | :saturation | :color | :luminosity

  @typedoc "Gradient stop: {offset 0..1, {r,g,b,a}}"
  @type gradient_stop :: {number(), {0..255, 0..255, 0..255, 0..255}}

  @doc "All known features"
  def features, do: MapSet.new([:images, :gradients, :filters, :blending, :clipping, :effects])

  @doc "Return true if backend supports feature (based on capabilities/0)"
  @spec supports?(module(), feature()) :: boolean()
  def supports?(backend, feat) when is_atom(backend) do
    caps = if function_exported?(backend, :capabilities, 0), do: backend.capabilities(), else: MapSet.new()
    MapSet.member?(caps, feat)
  end
end
