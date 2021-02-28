defmodule Quadtreex.QuadtreexTest do
  use ExUnit.Case

  test "create tree" do
    {:ok, t} = Quadtreex.new({0, 0}, {25, 25}, 5.0, 10)
    assert 0 = Quadtreex.height(t)
  end
end
