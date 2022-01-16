defmodule AdventOfCode2021.Fifteen do
  @moduledoc """
  Day 15: Chiton
  https://adventofcode.com/2021/day/15
  """

  alias AdventOfCode2021.Utils.Grid
  alias AdventOfCode2021.Utils.PQ

  def one(input_file) do
    input_file
    |> parse_input()
    |> AdventOfCode2021.Utils.Grid.new()
    |> shortest_path()
  end

  def two(input_file) do
    input_file
    |> parse_input()
    |> duplicate_grid(5)
    |> AdventOfCode2021.Utils.Grid.new()
    |> shortest_path()
  end

  # entry case: init data structures
  def shortest_path(graph) do
    start = {0, 0}
    start_cost = 0
    target = {graph.width, graph.height}
    frontier = PQ.put(PQ.new(), start, start_cost)

    shortest_path(graph, target, start, frontier, {%{start => nil}, %{start => start_cost}})
  end

  # base case: route found
  def shortest_path(_graph, target, node, _frontier, {_map, costs}) when node == target,
    do: Map.get(costs, target)

  # base case: no route
  def shortest_path(_graph, _target, _node, %PQ{tree: {0, nil}}, routes), do: {:error, routes}

  # general case: dequeue min priority neighbors and call on them using dijkstra's
  def shortest_path(graph, target, node, frontier, {map, costs}) do
    {new_frontier, new_map, new_costs} =
      Grid.neighbors(graph, node)
      |> Enum.reduce({frontier, map, costs}, fn {point, cost}, {f_acc, m_acc, c_acc} ->
        cost_to_node = Map.get(costs, node) + cost
        # enqueue neighbors that are unseen or for which we've discovered a lower-cost route
        if not Map.has_key?(costs, point) || cost_to_node < Map.get(costs, point) do
          {
            PQ.put(f_acc, point, cost),
            Map.put(m_acc, point, node),
            Map.put(c_acc, point, cost_to_node)
          }
        else
          {f_acc, m_acc, c_acc}
        end
      end)

    {next_node, next_frontier} = PQ.pop(new_frontier)
    shortest_path(graph, target, next_node, next_frontier, {new_map, new_costs})
  end

  def parse_input(input_file) do
    ("/lib/days/15/" <> input_file)
    |> AdventOfCode2021.Utils.Inputs.file_by_line()
    |> Enum.map(&AdventOfCode2021.Utils.Inputs.to_integer_list/1)
  end

  def duplicate_grid(grid, times) do
    for y <- 0..(times - 1) do
      for x <- 0..(times - 1) do
        increment_grid(grid, x + y)
      end
      |> Enum.zip()
      |> Enum.map(fn zipped ->
        zipped
        |> Tuple.to_list()
        |> Enum.concat()
      end)
    end
    |> Enum.concat()
  end

  def increment_grid(grid, increment) do
    for row <- grid do
      for val <- row do
        sum = val + increment

        if sum > 9 do
          rem(sum, 9)
        else
          sum
        end
      end
    end
  end
end
