defmodule Quadtreex.WithinRangeQuery do
  alias Quadtreex.BoundingBox

  @moduledoc """
  Query to find all entities within a given distance of a point
  """
  defstruct location: nil, distance: 0.0, accum: []

  @type t() :: %__MODULE__{
          location: BoundingBox.coordinate(),
          distance: float(),
          accum: list()
        }
end
