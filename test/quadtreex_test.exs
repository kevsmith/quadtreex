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

  test "delete on tree w/no child nodes works" do
    {:ok, t} = Quadtreex.new({0, 0}, {128, 128}, 5, 10)
    {:ok, t} = Quadtreex.insert(t, {10, 10}, "hello")
    {:ok, t} = Quadtreex.insert(t, {100, 30}, "goodbye")
    assert {:ok, true, t} = Quadtreex.delete(t, "hello")
    result = Quadtreex.query(t, %WithinRangeQuery{location: {10, 10}, distance: 0, accum: []})
    assert Enum.empty?(result)
    assert {:ok, false, _} = Quadtreex.delete(t, "wubba")
  end

  test "delete on tree w/children works" do
    {:ok, t} = Quadtreex.new({0, 0}, {128, 128}, 5, 3)
    {:ok, t} = Quadtreex.insert(t, {10, 10}, "h")
    {:ok, t} = Quadtreex.insert(t, {20, 20}, "e")
    {:ok, t} = Quadtreex.insert(t, {30, 30}, "l")
    {:ok, t} = Quadtreex.insert(t, {40, 40}, "l")
    {:ok, t} = Quadtreex.insert(t, {50, 50}, "o")
    result = Quadtreex.query(t, %WithinRangeQuery{location: {30, 30}, distance: 14.15})
    assert Enum.count(result) == 3
    assert {:ok, true, t} = Quadtreex.delete(t, "l")
    result = Quadtreex.query(t, %WithinRangeQuery{location: {30, 30}, distance: 15})
    assert Enum.count(result) == 2
    assert {:ok, false, _} = Quadtreex.delete(t, "g")
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
