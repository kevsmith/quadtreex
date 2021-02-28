defmodule Quadtreex do
  @moduledoc """
  A dynamic quadtree implemented in pure Elixir
  """
  alias Quadtreex.BoundingBox
  alias Quadtreex.Node

  defstruct root: nil

  @type t() :: %__MODULE__{
          root: Node.t()
        }

  @spec new(BoundingBox.coordinate(), BoundingBox.coordinate(), float(), pos_integer()) ::
          {:ok, t()}
  def new(l, r, min_size, split_size) do
    {:ok,
     %__MODULE__{
       root: Node.new(BoundingBox.new(l, r), min_size: min_size, split_size: split_size)
     }}
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

  def brute_force(point, max_distance) do
    Enum.reduce(0..100, [], fn n, acc ->
      if distance_to({n, n}, point) <= max_distance do
        [n | acc]
      else
        acc
      end
    end)
  end

  defp distance_to({ex, ey}, {px, py}) do
    :math.sqrt(:math.pow(ey - py, 2) + :math.pow(ex - px, 2))
  end
end
