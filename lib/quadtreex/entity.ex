defmodule Quadtreex.Entity do
  @moduledoc """
  A thing contained within a quadtree node
  """
  alias Quadtreex.BoundingBox

  defstruct location: nil, thing: nil

  @type t() :: %__MODULE__{
          location: BoundingBox.coordinate(),
          thing: term()
        }
end
