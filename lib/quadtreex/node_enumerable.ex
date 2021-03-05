defimpl Enumerable, for: Quadtreex.Node do
  alias Quadtreex.{BoundingBox, Node, WithinRangeQuery}

  @impl Enumerable
  def count(_node), do: {:error, Node}

  @impl Enumerable
  def member?(_node, _thing), do: {:error, Node}

  @impl Enumerable
  def slice(_node), do: {:error, Node}

  @impl Enumerable
  def reduce(%Node{children: c, entities: e}, {:cont, _} = acc, fun)
      when map_size(c) == 0 do
    reduce_entities(e, acc, fun)
  end

  def reduce(%Node{children: c}, {:cont, _} = acc, fun) do
    cv = Map.values(c)
    reduce_children(cv, acc, fun)
  end

  defp reduce_entities([h | t], {:cont, %WithinRangeQuery{} = q}, fun) do
    {signal, m} =
      if BoundingBox.distance_between(h.location, q.location) <= q.distance do
        fun.(h, q.accum)
      else
        {:cont, q.accum}
      end

    reduce_entities(t, {signal, %{q | accum: m}}, fun)
  end

  defp reduce_entities([h | t], {:cont, acc}, fun) do
    reduce_entities(t, fun.(h, acc), fun)
  end

  defp reduce_entities([], {:cont, acc}, _fun), do: {:cont, acc}
  defp reduce_entities(_entities, {:halt, acc}, _fun), do: {:halted, acc}

  defp reduce_entities(entities, {:suspend, acc}, fun),
    do: {:suspended, acc, &reduce_entities(entities, &1, fun)}

  defp reduce_children([], {:cont, acc}, _fun), do: {:cont, acc}

  defp reduce_children([h | t], {:cont, %WithinRangeQuery{} = q}, fun) do
    {signal, uq} =
      if is_candidate?(h.bbox, q) do
        reduce(h, {:cont, q}, fun)
      else
        {:cont, q}
      end

    reduce_children(t, {signal, uq}, fun)
  end

  defp reduce_children([h | t], {:cont, _} = acc, fun) do
    reduce_children(t, reduce(h, acc, fun), fun)
  end

  defp is_candidate?(bbox, query) do
    distance = query.distance * 2

    cond do
      BoundingBox.contains?(bbox, query.location) ->
        true

      BoundingBox.distance_from(bbox, query.location, :l) <= distance ->
        true

      BoundingBox.distance_from(bbox, query.location, :r) <= distance ->
        true

      true ->
        false
    end
  end
end
