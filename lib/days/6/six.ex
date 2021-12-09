defmodule AdventOfCode2021.Six do
  @moduledoc """
  Day 6: Lanternfish
  https://adventofcode.com/2021/day/6
  """

  def one(input_file) do
    step(80, parse_input(input_file))
  end

  @doc """
  Ideas:
  * nx matrix operations, pass vector
  * mathematically represent population as equation
  * represent population as map of ages
  """
  def two(input_file) do
    input_file
    |> parse_input()
    |> to_map()
    |> step_population(256)
  end

  def step(limit, school, day \\ 0)
  def step(limit, school, day) when day == limit, do: length(school)

  def step(limit, school, day) do
    new_school =
      Enum.reduce(school, [], fn fish, acc ->
        if fish == 0 do
          [8, 6 | acc]
        else
          [fish - 1 | acc]
        end
      end)

    step(limit, new_school, day + 1)
  end

  def step_population(pop, limit, day \\ 1)

  def step_population(pop, limit, day) when day > limit do
    Enum.reduce(pop, 0, fn {_k, v}, acc -> acc + v end)
  end

  def step_population(pop, limit, day) do
    spawning = Map.get(pop, 0, 0)

    new_pop =
      Enum.reduce(
        1..8,
        %{},
        fn period, acc ->
          count = Map.get(pop, period, 0)
          Map.update(acc, period - 1, count, fn existing -> existing + count end)
        end
      )
      |> Map.update(6, spawning, fn existing -> existing + spawning end)
      |> Map.update(8, spawning, fn existing -> existing + spawning end)

    step_population(new_pop, limit, day + 1)
  end

  def to_map(fish_list) do
    for f <- fish_list, reduce: %{} do
      acc -> Map.update(acc, f, 1, fn existing -> existing + 1 end)
    end
  end

  def parse_input(input_file) do
    (File.cwd!() <> "/lib/days/6/" <> input_file)
    |> File.read!()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end
end
