defmodule AdventOfCode2021.Eleven do
  @moduledoc """
  Day 11: Dumbo Octopus
  https://adventofcode.com/2021/day/11
  """

  alias AdventOfCode2021.Utils.Grid

  def one(input_file, steps \\ 100) do
    grid = parse_input(input_file)

    {flash_count, grid} = Enum.reduce(1..steps, {0, grid}, fn _, {count, grid} ->
      {grid, flashed} = step(grid)
      {count + MapSet.size(flashed), grid}
    end)

    Grid.inspect(grid)
    flash_count
  end

  def two(input_file) do
    grid = parse_input(input_file)

    step_until_synchronized(grid)
  end

  def step_until_synchronized(grid), do: step_until_synchronized(grid, 0)

  def step_until_synchronized(grid, step) do
    {grid, flashed} = step(grid)
    if MapSet.size(flashed) == grid.height * grid.width do
      Grid.inspect(grid)
      step + 1
    else
      step_until_synchronized(grid, step + 1)
    end
  end

  def step(grid), do: bump_or_flash(Map.keys(grid.points), grid, MapSet.new())

  def bump_or_flash([point | points], grid, flashed) do
    energy = grid.points[point]

    cond do
      point in flashed ->
        # already flashed - no point incrementing
        bump_or_flash(points, grid, flashed)

      energy >= 9 ->
        # flashing - store & enqueue neighbors
        bump_or_flash(
          Grid.neighbors(grid, point, all: true) ++ points,
          Grid.set(grid, point, 0),
          MapSet.put(flashed, point)
        )

      true ->
        # increment
        bump_or_flash(points, Grid.set(grid, point, energy + 1), flashed)
    end
  end

  def bump_or_flash([], grid, flashed), do: {grid, flashed}

  def parse_input(input_file) do
    AdventOfCode2021.Utils.Inputs.file_by_line("/lib/days/11/" <> input_file)
    |> Enum.map(&AdventOfCode2021.Utils.Inputs.to_integer_list/1)
    |> Grid.new()
  end
end
