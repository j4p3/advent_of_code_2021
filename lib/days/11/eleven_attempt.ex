defmodule AdventOfCode2021.ElevenAttempt do
  @moduledoc """
  Day 11: Dumbo Octopus
  https://adventofcode.com/2021/day/11

  Initial multi-pass iterative attempt
  """

  alias AdventOfCode2021.Utils.Grid

  def one(input_file) do
    grid =
      input_file
      |> parse_input()
      |> Grid.new()
      |> step(100)
  end

  def two() do
  end

  def step(grid, limit), do: step(grid, 0, 0, limit)

  def step(grid, flash_count, step_num, limit) when step_num > limit, do: {flash_count, grid}

  def step(grid, flash_count, step_num, limit) do
    flashes =
      grid
      |> increment()
      |> queue_flashes()
      |> flash()

    step(grid, flash_count + flashes, step_num + 1, limit)
  end

  def step(grid) do
    grid
    |> increment()
    |> queue_flashes()
    |> flash()
  end

  def increment(grid) do
    next_points =
      for y <- 0..(grid.height - 1),
          x <- 0..(grid.width - 1),
          into: grid.points,
          do: {{x, y}, grid.points[{x, y}] + 1}

    %Grid{grid | points: next_points}
  end

  def queue_flashes(grid) do
    flashed_points =
      for y <- 0..(grid.height - 1),
          x <- 0..(grid.width - 1),
          grid.points[{x, y}] > 9,
          into: grid.points,
          do: {{x, y}, queue_flash(grid, {x, y})}

    %Grid{grid | points: flashed_points}
  end

  def queue_flash(grid, point) do
    IO.puts("queueing flashes")

    flashed_points =
      for {point, value} <- Grid.neighbors(grid, point, all: true),
          into: grid.points,
          do: {point, value + 1}

    %Grid{grid | points: flashed_points}
  end

  def flash(grid) do
    flashed_points =
      grid.points
      |> Map.filter(fn {_point, value} -> value > 9 end)
      |> Enum.reduce(0, fn {{point, _value}, count} -> {{point, 0}, count + 1} end)
      |> Map.new()

    to_flash = Map.filter(grid.points, fn {_point, value} -> value > 9 end)
    count = length(to_flash)

    %Grid{grid | points: Map.merge(grid.points, flashed_points)}

    # for y <- 0..(grid.height - 1),
    #     x <- 0..(grid.width - 1),
    #     grid.points[{x, y}] > 9,
    #     reduce: {0, grid} do
    #   {count, g} ->
    #     if g.points[{x, y}] > 9 do
    #       {count + 1, %Grid{g | points: Map.put(g, {x, y}, 0)}}
    #     else
    #       {count, g}
    #     end
    # end
  end

  def parse_input(input_file) do
    AdventOfCode2021.Utils.Inputs.file_by_line("/lib/days/11/" <> input_file)
    |> Enum.map(&AdventOfCode2021.Utils.Inputs.to_integer_list/1)
  end
end
