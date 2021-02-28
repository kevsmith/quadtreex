defmodule Quadtreex.BoundingBoxTest do
  use ExUnit.Case

  alias Quadtreex.BoundingBox

  test "constructing a square bounding box" do
    bbox = BoundingBox.new({0, 0}, {100, 100})
    assert {0, 0} = bbox.l
    assert {100, 100} = bbox.r
    assert {50.0, 50.0} = bbox.center
    assert 100 = bbox.height
    assert 100 = bbox.width
  end

  test "constructing a rectangular bounding box" do
    bbox = BoundingBox.new({100, 50}, {150, 75})
    assert {100, 50} = bbox.l
    assert {150, 75} = bbox.r
    assert {125.0, 62.5} = bbox.center
    assert 50 = bbox.width
    assert 25 = bbox.height
  end

  test "containment with a square bounding box" do
    bbox = BoundingBox.new({0, 0}, {0.9, 0.9})
    assert {0.45, 0.45} = bbox.center
    assert BoundingBox.contains?(bbox, {0.8, 0.2})
    refute BoundingBox.contains?(bbox, {0.3, 1.1})
  end

  test "containment with a rectangular bounding box" do
    bbox = BoundingBox.new({10, 10}, {50, 30})
    assert {30.0, 20.0} = bbox.center
    assert BoundingBox.contains?(bbox, {15, 10})
    assert BoundingBox.contains?(bbox, {49.5, 30})
    refute BoundingBox.contains?(bbox, {9, 30})
  end

  test "find_quadrants with in bounds point" do
    bbox = BoundingBox.new({0, 0}, {99, 99})
    assert {:ok, :ne} = BoundingBox.find_quadrant(bbox, {80, 90})
    assert {:ok, :se} = BoundingBox.find_quadrant(bbox, {60, 30})
    assert {:ok, :sw} = BoundingBox.find_quadrant(bbox, {10, 10})
    assert {:ok, :nw} = BoundingBox.find_quadrant(bbox, {20, 70})
  end

  test "find_quadrants with out of bounds point" do
    bbox = BoundingBox.new({0, 0}, {45, 45})
    assert {:error, :out_of_bounds} = BoundingBox.find_quadrant(bbox, {0, 45.5})
    assert {:error, :out_of_bounds} = BoundingBox.find_quadrant(bbox, {50, 50})
  end

  test "sub divide into quadrants" do
    bbox = BoundingBox.new({0, 0}, {100, 100})
    {lx, ly} = bbox.l
    {rx, ry} = bbox.r
    {cx, cy} = bbox.center
    ne = BoundingBox.for_quadrant(bbox, :ne)
    assert {cx, cy} == ne.l
    assert {rx, ry} == ne.r
    se = BoundingBox.for_quadrant(bbox, :se)
    assert {cx, ly} == se.l
    assert {rx, cy} == se.r
    sw = BoundingBox.for_quadrant(bbox, :sw)
    assert {lx, ly} == sw.l
    assert {cx, cy} == sw.r
    nw = BoundingBox.for_quadrant(bbox, :nw)
    assert {lx, cy} == nw.l
    assert {cx, ry} == nw.r
    assert ne.width == 50.0
    assert se.width == 50.0
    assert sw.width == 50.0
    assert nw.width == 50.0
    assert ne.height == 50.0
    assert se.height == 50.0
    assert sw.height == 50.0
    assert nw.height == 50.0
  end

  test "distance_from to point" do
    bbox = BoundingBox.new({0, 0}, {10, 10})
    assert 5.385164807134504 == BoundingBox.distance_from(bbox, {2, 5})
    assert 3 == BoundingBox.distance_from(bbox, {2, 5}, :center)
    assert 0 == BoundingBox.distance_from(bbox, {5, 5}, :center)
    assert 9.433981132056603 == BoundingBox.distance_from(bbox, {2, 5}, :r)
  end
end
