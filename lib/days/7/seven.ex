defmodule AdventOfCode2021.Seven do
  @moduledoc """
  Day 7: The Treachery of Whales
  https://adventofcode.com/2021/day/7
  """

  @doc """
  Ideas:
  * sum distance to n for each member, pick lowest distance
  * nx create iota along vector, sum iotas
  """
  def one(input_file) do
    positions =
      input_file
      |> parse_input()

    {min, max} = Enum.min_max(positions)

    # iterate over the solution space
    min..max
    |> Enum.map(fn i ->
      # calculate the cost for every crab to get to that spot
      positions
      |> Enum.map(fn position ->
        abs(position - i)
      end)
      # and sum it
      |> Enum.sum()
    end)
    |> Enum.min()
  end

  def two(input_file) do
    positions =
      input_file
      |> parse_input()

    {min, max} = Enum.min_max(positions)

    min..max
    |> Enum.map(fn i ->
      positions
      |> Enum.map(fn position ->
        triangle(abs(position - i))
      end)
      |> Enum.sum()
    end)
    |> Enum.min()
  end

  # Reducer function solution:
  # Enum.reduce(crabs, List.duplicate(0, length), &increment_fuel_counts/2)
    # |> Enum.min()
  # def increment_fuel_counts(crab_position, fuel_sums) do
  #   fuel_sums
  #   |> Enum.with_index()
  #   |> Enum.map(fn {sum, i} ->
  #     sum + abs(crab_position - i)
  #   end)
  # end

  # # Reducer function solution:
  # # Returns solution off by 2.
  # # {_cache, fuel_totals} =
  # #   Enum.reduce(crabs, {cache, List.duplicate(0, length)}, &increment_fuel_counts_increasing/2)
  # def increment_fuel_counts_increasing(position, {cache, fuel_sums}) do
  #   new_sums =
  #     fuel_sums
  #     |> Enum.with_index()
  #     |> Enum.map(fn {sum, i} ->
  #       sum + Map.get(cache, abs(position - i))
  #     end)

  #   {cache, new_sums}
  # end

  def parse_input(input_file) do
    (File.cwd!() <> "/lib/days/7/" <> input_file)
    |> File.read!()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  def triangle(n), do: div(n*(n+1), 2)
end
