defmodule AdventOfCode2021.Twelve do
  @moduledoc """
  Day 12: Passage Pathing
  https://adventofcode.com/2021/day/12

  Interesting problem here with branching recursion and how to flatten results efficiently,
  or how to synchronize state between recursive branches

  Not a problem - recurse for each branch as necessary in general case,
  prune those branches from the list of things to be recursed through,
  call recursively with diminished list
  Base case when list is empty
  """

  alias AdventOfCode2021.Utils.GraphNode

  def one(input_file) do
    input_file
    |> parse_input()
    |> traverse()
    |> List.flatten()
    |> Enum.chunk_while([], &chunk_paths/2, &after_chunk_paths/1)
  end

  @doc """
  ideas:
  * on filtering children, don't filter out :small types until one appears twice in visited list
    * wouldn't we just visit the first :small twice and poison all further branches?
    * no, it's just adding an additional branch
    * recursive general case could be tightened up a lot, just pass a bool flag instead of double iterating for twice?
  """
  def two(input_file) do
    input_file
    |> parse_input()
    |> traverse_again()
    |> IO.inspect()
    |> length()
  end

  @doc """
  Entrypoint
  """
  def traverse(nodes), do: traverse(nodes, "start", [])

  # Base case
  defp traverse(_nodes, "end", visited) do
    Enum.reverse(["end" | visited])
  end

  # General case
  defp traverse(nodes, next_node, visited) do
    node = nodes[next_node]

    children =
      Enum.filter(node.children, fn c ->
        c == "end" || nodes[c].type == :large || c not in visited
      end)

    Enum.map(children, fn child ->
      traverse(nodes, child, [next_node | visited])
    end)
  end

  @doc """
  Entrypoint
  """
  def traverse_again(nodes),
    do: traverse_again(nodes, nodes["start"].children, ["start"], [], false)

  # Base case: finished searching
  defp traverse_again(_nodes, [], _visited, paths, _visited_twice?) do
    paths
  end

  # termination case: return the path that got us to end
  defp traverse_again(nodes, ["end" | to_visit], visited, paths, visited_twice?) do
    new_path = Enum.reverse(["end" | visited])
    IO.puts("visiting end - storing path")
    IO.inspect(new_path)
    IO.puts("")

    traverse_again(nodes, to_visit, visited, [new_path | paths], visited_twice?)
  end

  # General case: call again
  defp traverse_again(nodes, [node_value | to_visit], visited, paths, visited_twice?) do
    IO.write("visiting #{node_value} - ")
    node = nodes[node_value]

    new_paths =
      cond do
        node.type == :start || (node_value in visited && node.type == :small && visited_twice?) ->
          # termination case - visiting a nonviable node
          IO.puts("termination case\n")
          paths

        node_value in visited && node.type == :small ->
          # general case: second visit to small node
          IO.puts("general case, second visit to small node")
          traverse_again(nodes, node.children, [node_value | visited], paths, true)

        node.type == :small ->
          # general case: first visit to small node
          IO.puts("general case, first visit to small node")
          traverse_again(nodes, node.children, [node_value | visited], paths, visited_twice?)

        true ->
          # large unvisited
          IO.puts("general case, large unvisited")
          traverse_again(nodes, node.children, [node_value | visited], paths, visited_twice?)
      end

    # general case: continue iterating through to_visit
    IO.puts("general case, continuing")
    traverse_again(nodes, to_visit, visited, new_paths, visited_twice?)
  end

  defp chunk_paths(el, acc) do
    if el == "end" do
      {:cont, Enum.reverse([el | acc]), []}
    else
      {:cont, [el | acc]}
    end
  end

  defp after_chunk_paths(acc), do: {:cont, acc}

  def parse_input(input_file) do
    AdventOfCode2021.Utils.Inputs.file_by_line("/lib/days/12/" <> input_file)
    |> Enum.map(fn l ->
      String.split(l, "-")
      |> List.to_tuple()
    end)
    |> Enum.reduce(%{}, fn {a, b}, nodes ->
      nodes
      |> Map.put_new(a, GraphNode.new(a))
      |> Map.put_new(b, GraphNode.new(b))
      |> (&Map.put(&1, a, GraphNode.add_child(&1[a], &1[b]))).()
      |> (&Map.put(&1, b, GraphNode.add_child(&1[b], &1[a]))).()
    end)
  end
end
