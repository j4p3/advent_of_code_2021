defmodule AdventOfCode2021.Nine do
  @moduledoc """
  Day 9:Smoke Basin
  https://adventofcode.com/2021/day/9
  """

  alias AdventOfCode2021.Utils.Inputs

  defmodule Grid do
    defstruct points: %{}, width: nil, height: nil

    @spec new([[integer()]]) :: map
    def new(lines) do
      points =
        for {line, y} <- Enum.with_index(lines),
            {point, x} <- Enum.with_index(line),
            into: %{},
            do: {{x, y}, point}

      %Grid{points: points, width: length(List.first(lines)), height: length(lines)}
    end

    def neighbors(grid, {x, y}) do
      [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]
      |> Enum.filter(&in_bounds?(grid, &1))
      |> Enum.map(fn coords -> {coords, Map.get(grid.points, coords)} end)
    end

    defp in_bounds?(grid, {x, y}), do: x < grid.width && x >= 0 && y < grid.height && y >= 0
  end

  def one(input) do
    input
    |> parse_input()
    |> Grid.new()
    |> low_points()
    |> Enum.map(fn {_coords, value} -> value end)
    |> Enum.sum()
  end

  @doc """
  Ideas:
  * requires an actual graph search rather than just dumping into a map and interating through
  * define a node with n-e-w-s neighbors (or just up to 4 anonymous neighbors)
  * iterate through input lines & create nodes
  * how to store nodes?
  * search graph for low points
  * on low point, trigger search for 9s & accumulate size
  * sum sizes
  """
  def two(input) do
    grid =
      input
      |> parse_input()
      |> Grid.new()

    grid
    |> low_points()
    |> Enum.map(fn {coords, _value} -> traverse_basin(grid, coords) end)
    |> Enum.map(&MapSet.size/1)
    |> Enum.sort(&(&1 > &2))
    |> Enum.slice(0..2)
    |> Enum.reduce(&(&1 * &2))
  end

  def low_points(grid) do
    for y <- 0..(grid.height - 1),
        x <- 0..(grid.width - 1),
        reduce: [] do
      acc -> if low_point?(grid, {x, y}), do: [{{x, y}, grid.points[{x, y}] + 1} | acc], else: acc
    end
  end

  def traverse_basin(grid, coords) do
    traverse_basin(grid, coords, MapSet.new([coords]))
  end

  def traverse_basin(grid, coords, traversed) do
    if grid.points[coords] == 9 do
      traversed
    else
      traversed = MapSet.put(traversed, coords)

      Grid.neighbors(grid, coords)
      |> Enum.filter(fn {neighbor, _value} -> neighbor not in traversed end)
      |> Enum.reduce(traversed, fn {neighbor, _value}, acc ->
        traverse_basin(grid, neighbor, acc)
      end)
    end
  end

  def low_point?(grid, coords) do
    point = grid.points[coords]
    Enum.all?(Grid.neighbors(grid, coords), fn {_coords, n} -> point < n end)
  end

  def parse_input(input_file) do
    (File.cwd!() <> "/lib/days/9/" <> input_file)
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&Inputs.to_integer_list/1)
  end
end
