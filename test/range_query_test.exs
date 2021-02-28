defmodule Quadtreex.RangeQueryTest do
  use ExUnit.Case

  setup do
    {:ok, tree} = Quadtreex.new({0, 0}, {100, 100}, 5, 32)

    tree =
      Enum.reduce(1..50, tree, fn n, tree ->
        {:ok, tree} = Quadtreex.insert(tree, {n, n}, "#{n}")
        tree
      end)

    {:ok, tree: tree}
  end

  test "point queries", %{tree: tree} do
    results = Quadtreex.range_query(tree, {10, 10}, 0)
    assert 1 == length(results)
    assert ["10"] = results
  end

  test "short range queries", %{tree: tree} do
    results = Quadtreex.range_query(tree, {10, 20}, 9)
    assert 7 == length(results)
  end
end
