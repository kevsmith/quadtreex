defmodule Quadtreex.QuadtreexTest do
  use ExUnit.Case

  alias Quadtreex.WithinRangeQuery

  test "create tree" do
    {:ok, t} = Quadtreex.new({0, 0}, {25, 25}, 5.0, 10)
    assert 0 = Quadtreex.height(t)
  end

  test "traverse tree" do
    {:ok, t, size} = make_tree(128, 128)
    assert 5 = Quadtreex.height(t)
    result = Quadtreex.reduce(t, fn e, acc -> [e.thing | acc] end) |> Enum.sort()
    assert size == Enum.count(result)
    assert {0, 1} = Enum.at(result, 0)
    assert {128, 128} = Enum.at(result, size - 1)
  end

  test "point query" do
    {:ok, t, _size} = make_tree(128, 128)

    query = %WithinRangeQuery{location: {64, 64}, distance: 0, accum: []}

    result = Quadtreex.query(t, query, &[&1.thing | &2])

    assert [{64, 64}] = result
  end

  test "radius query" do
    {:ok, t, _size} = make_tree(128, 128)
    query = %WithinRangeQuery{location: {64, 64}, distance: 3.5, accum: []}
    result = Quadtreex.query(t, query, &[&1.thing | &2]) |> Enum.sort()
    assert 37 = Enum.count(result)
  end

  test "radius query no hits" do
    {:ok, t, _size} = make_tree(128, 128)
    query = %WithinRangeQuery{location: {256, 128}, distance: 10, accum: []}
    result = Quadtreex.query(t, query, &[&1.thing | &2])
    assert Enum.empty?(result)
  end

  defp make_tree(x_max, y_max) do
    min_width = x_max / 10
    max_entities = 10
    {:ok, t} = Quadtreex.new({0, 0}, {x_max, y_max}, min_width, max_entities)
    {t, size} = insert_entities(t, 0, x_max, y_max, y_max)
    {:ok, t, size}
  end

  defp insert_entities(t, count, 0, 0, _), do: {t, count}
  defp insert_entities(t, count, x, 0, y_max), do: insert_entities(t, count, x - 1, y_max, y_max)

  defp insert_entities(t, count, x, y, y_max) do
    {:ok, t} = Quadtreex.insert(t, {x, y}, {x, y})
    insert_entities(t, count + 1, x, y - 1, y_max)
  end
end
