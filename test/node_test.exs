defmodule Quadtreex.NodeTest do
  use ExUnit.Case

  alias Quadtreex.{BoundingBox, Node}

  test "root construction" do
    node = make_node({0, 0}, {100, 100})
    assert {0, 0} = node.bbox.l
    assert {100, 100} = node.bbox.r
    assert Node.is_root?(node)
  end

  test "parent/child construction" do
    root = make_node({0, 0}, {100, 100})
    child = make_node({0, 0}, {50, 50}, parent: root)
    assert Node.is_root?(root)
    refute Node.is_root?(child)
    assert root == child.parent
  end

  test "in bounds insertion" do
    node = make_node({0, 0}, {50, 50})
    assert Node.contains?(node, {25, 33.1})
    assert {:ok, node} = Node.insert(node, {25, 33.1}, "hello")
    assert length(node.entities) == 1
  end

  test "out of bounds insertion" do
    node = make_node({100, 100}, {200, 200})
    refute Node.contains?(node, {99, 150})
    assert {:error, :out_of_bounds} = Node.insert(node, {99, 150}, "hello")
  end

  test "insertion with split" do
    node = make_node({0, 0}, {50, 50}, split_size: 2)
    {:ok, n} = Node.insert(node, {10, 10}, "foo")
    {:ok, n} = Node.insert(n, {40, 49}, "bar")
    {:ok, n} = Node.insert(n, {25, 25}, "quux")
    assert Node.is_root?(n)
    refute Enum.empty?(n.children)
    assert Enum.empty?(n.entities)
  end

  test "height with root" do
    node = make_node({0, 0}, {10, 10}, split_size: 2)
    {:ok, n} = Node.insert(node, {3, 7}, "foo")
    assert 1 == Node.height(n)
  end

  test "height after split" do
    node = make_node({0, 0}, {10, 10}, split_size: 2)

    node =
      Enum.reduce(1..10, node, fn n, node ->
        {:ok, node} = Node.insert(node, {n, n}, "test")
        node
      end)

    assert 2 == Node.height(node)
  end

  defp make_node(l, r, options \\ []) do
    Node.new(BoundingBox.new(l, r), options)
  end
end
