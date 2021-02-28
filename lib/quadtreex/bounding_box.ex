defmodule Quadtreex.BoundingBox.Guards do
  @moduledoc false
  defguard is_within(lx, ly, rx, ry, x, y) when x >= lx and x <= rx and y >= ly and y <= ry
end

defmodule Quadtreex.BoundingBox do
  @moduledoc """
  Describes a box of 2 dimensional space
  """
  @enforce_keys [:l, :r]
  defstruct l: {nil, nil}, r: {nil, nil}, center: {nil, nil}, height: 0.0, width: 0.0

  @type coordinate() :: {number(), number()}
  @type quadrant :: :ne | :se | :sw | :nw

  @type t() :: %__MODULE__{
          center: {float(), float()},
          height: number(),
          l: coordinate(),
          r: coordinate(),
          width: number()
        }

  import Quadtreex.BoundingBox.Guards

  @spec new(number(), number(), number(), number()) :: t()
  def new(lx, ly, rx, ry) do
    width = rx - lx
    height = ry - ly
    cx = lx + width * 0.5
    cy = ly + height * 0.5
    %__MODULE__{l: {lx, ly}, r: {rx, ry}, center: {cx, cy}, height: height, width: width}
  end

  @spec new(coordinate(), coordinate()) :: t()
  def new({lx, ly}, {rx, ry}) do
    new(lx, ly, rx, ry)
  end

  @spec for_quadrant(t(), quadrant()) :: t()
  def for_quadrant(%__MODULE__{l: {lx, ly}, r: {rx, ry}, center: {cx, cy}}, quadrant) do
    case quadrant do
      :ne ->
        new(cx, cy, rx, ry)

      :se ->
        new(cx, ly, rx, cy)

      :sw ->
        new(lx, ly, cx, cy)

      :nw ->
        new(lx, cy, cx, ry)
    end
  end

  @spec contains?(t(), coordinate()) :: boolean()
  def contains?(%__MODULE__{l: {lx, ly}, r: {rx, ry}}, {x, y})
      when is_within(lx, ly, rx, ry, x, y),
      do: true

  def contains?(%__MODULE__{}, _coord), do: false

  @spec find_quadrant(t(), coordinate()) :: {:ok, quadrant()} | {:error, :out_of_bounds}
  def find_quadrant(%__MODULE__{l: {lx, ly}, r: {rx, ry}, center: {cx, cy}}, {x, y})
      when is_within(lx, ly, rx, ry, x, y) do
    quadrant =
      if x < cx do
        if y < cy do
          :sw
        else
          :nw
        end
      else
        if y < cy do
          :se
        else
          :ne
        end
      end

    {:ok, quadrant}
  end

  def find_quadrant(%__MODULE__{}, _coord), do: {:error, :out_of_bounds}

  def distance_from(_bbox, _point, point \\ :l)

  def distance_from(%__MODULE__{l: {lx, ly}}, {x, y}, :l) do
    :math.sqrt(:math.pow(ly - y, 2) + :math.pow(lx - x, 2))
  end

  def distance_from(%__MODULE__{r: {rx, ry}}, {x, y}, :r) do
    :math.sqrt(:math.pow(ry - y, 2) + :math.pow(rx - x, 2))
  end

  def distance_from(%__MODULE__{center: {cx, cy}}, {x, y}, :center) do
    :math.sqrt(:math.pow(cy - y, 2) + :math.pow(cx - x, 2))
  end
end
