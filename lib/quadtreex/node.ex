defmodule Quadtreex.Node do
  @moduledoc """
  A node in a quadtree

  A quadtree node represents a bounded volume of 2 dimensional space.
  """
  alias Quadtreex.BoundingBox
  alias Quadtreex.Entity

  defstruct parent: nil, bbox: nil, min_size: 0.0, split_size: 0, children: %{}, entities: []

  @type child_map() :: %{BoundingBox.quadrant() => t()}

  @type min_size_option() :: {:min_size, float()}
  @type split_size_option() :: {:split_size, non_neg_integer()}
  @type parent_option() :: {:parent, t()}

  @type create_option :: min_size_option() | split_size_option() | parent_option()
  @type create_options :: [] | [create_option(), ...]

  @type t() :: %__MODULE__{
          parent: t() | nil,
          bbox: BoundingBox.t(),
          min_size: float(),
          split_size: pos_integer(),
          children: %{} | child_map(),
          entities: [] | [Entity.t()]
        }

  @spec new(BoundingBox.t(), create_options()) :: t()
  def new(%BoundingBox{} = bbox, options \\ []) do
    parent = Keyword.get(options, :parent)
    min_size = Keyword.get(options, :min_size, 5.0)
    split_size = Keyword.get(options, :split_size, 32)
    %__MODULE__{parent: parent, bbox: bbox, min_size: min_size, split_size: split_size}
  end

  @spec is_root?(t()) :: boolean()
  def is_root?(%__MODULE__{parent: nil}), do: true
  def is_root?(%__MODULE__{}), do: false

  @spec contains?(t(), BoundingBox.coordinate()) :: boolean()
  def contains?(%__MODULE__{bbox: bbox}, coord) do
    BoundingBox.contains?(bbox, coord)
  end

  @spec range_query(t(), BoundingBox.coordinate(), number()) :: [] | [term()]
  def range_query(%__MODULE__{} = node, {px, py} = point, max_distance) do
    if Enum.empty?(node.children) do
      Enum.reduce(node.entities, [], fn entity, accum ->
        {ex, ey} = entity.location

        if :math.sqrt(:math.pow(ey - py, 2) + :math.pow(ex - px, 2)) <= max_distance do
          [entity.thing | accum]
        else
          accum
        end
      end)
    else
      Enum.flat_map(node.children, fn {_key, child} -> range_query(child, point, max_distance) end)
    end
  end

  @spec insert(t(), BoundingBox.coordinate(), term()) :: {:ok, t()} | {:error, :out_of_bounds}
  def insert(%__MODULE__{} = node, location, thing) do
    insert(node, %Entity{location: location, thing: thing})
  end

  @spec height(t()) :: non_neg_integer()
  def height(%__MODULE__{children: children, entities: entities}) do
    if Enum.empty?(children) do
      if(Enum.empty?(entities)) do
        0
      else
        1
      end
    else
      heights = Enum.map(Map.values(children), &height(&1))
      Enum.max(heights) + 1
    end
  end

  @spec insert(t(), Entity.t()) :: {:ok, t()} | {:error, :out_of_bounds}
  def insert(%__MODULE__{} = node, %Entity{} = entity) do
    if BoundingBox.contains?(node.bbox, entity.location) do
      if Enum.empty?(node.children) do
        if should_split?(node) do
          insert(split!(node), entity)
        else
          {:ok, %{node | entities: [entity | node.entities]}}
        end
      else
        {:ok, quadrant} = BoundingBox.find_quadrant(node.bbox, entity.location)
        child = Map.fetch!(node.children, quadrant)

        case insert(child, entity) do
          {:ok, child} ->
            {:ok, %{node | children: Map.put(node.children, quadrant, child)}}

          error ->
            error
        end
      end
    else
      {:error, :out_of_bounds}
    end
  end

  defp split!(%__MODULE__{children: %{}, entities: entities} = node) do
    node = %{node | children: make_children(node)}
    node = handoff_to_child!(entities, node)
    %{node | entities: []}
  end

  defp handoff_to_child!([], node) do
    %{node | entities: []}
  end

  defp handoff_to_child!([entity | t], %__MODULE__{bbox: bbox, children: children} = node) do
    {:ok, key} = BoundingBox.find_quadrant(bbox, entity.location)
    children = Map.update!(children, key, fn child -> insert!(child, entity) end)
    handoff_to_child!(t, %{node | children: children})
  end

  defp insert!(%__MODULE__{} = node, entity) do
    case insert(node, entity) do
      {:ok, node} ->
        node

      {:error, reason} ->
        raise RuntimeError, message: reason
    end
  end

  defp should_split?(
         %__MODULE__{split_size: split_size, entities: entities, children: %{}} = node
       ) do
    has_room?(node) and length(entities) >= split_size
  end

  defp should_split?(_node), do: false

  defp has_room?(%__MODULE__{bbox: bbox, min_size: min_size}) do
    bbox.width > min_size and bbox.height > min_size
  end

  defp make_children(%__MODULE__{min_size: min_size, split_size: split_size, bbox: bbox} = node) do
    options = [min_size: min_size, split_size: split_size, parent: node]

    %{
      ne: new(BoundingBox.for_quadrant(bbox, :ne), options),
      se: new(BoundingBox.for_quadrant(bbox, :se), options),
      sw: new(BoundingBox.for_quadrant(bbox, :sw), options),
      nw: new(BoundingBox.for_quadrant(bbox, :nw), options)
    }
  end
end
