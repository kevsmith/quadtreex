defmodule Quadtreex do
  @moduledoc """
  A dynamic quadtree implemented in pure Elixir
  """
  alias Quadtreex.Entity
  alias Quadtreex.BoundingBox
  alias Quadtreex.Node
  alias Quadtreex.WithinRangeQuery

  defstruct root: nil

  @type t() :: %__MODULE__{
          root: Node.t()
        }

  @type reducer() :: (entity :: Entity.t(), current_acc :: term() -> updated_acc :: term())

  @type tree_query() :: WithinRangeQuery.t()

  @spec new(BoundingBox.coordinate(), BoundingBox.coordinate(), float(), pos_integer()) ::
          {:ok, t()}
  def new(l, r, min_size, split_size) do
    {:ok,
     %__MODULE__{
       root: Node.new(BoundingBox.new(l, r), min_size: min_size, split_size: split_size)
     }}
  end

  @spec query(t(), tree_query(), reducer()) :: term()
  def query(tree, query, fun) do
    result = reduce(tree, query, fun)
    result.accum
  end

  @spec range_query(t(), BoundingBox.coordinate(), float()) :: [] | [term()]
  def range_query(%__MODULE__{root: root}, point, max_distance) do
    Node.range_query(root, point, max_distance)
  end

  @spec insert(t(), BoundingBox.coordinate(), term()) :: {:ok, t()} | {:error, :out_of_bounds}
  def insert(%__MODULE__{root: root} = tree, location, thing) do
    case Node.insert(root, location, thing) do
      {:ok, root} ->
        {:ok, %{tree | root: root}}

      error ->
        error
    end
  end

  @spec height(t()) :: non_neg_integer()
  def height(%__MODULE__{root: root}), do: Node.height(root)

  @spec reduce(t(), term(), reducer()) :: term()
  def reduce(tree, acc \\ [], fun) do
    Enum.reduce(tree.root, acc, fun)
  end
end
