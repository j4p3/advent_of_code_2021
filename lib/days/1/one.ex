defmodule AdventOfCode2021.One do
  @moduledoc """
  Day 1: https://adventofcode.com/2021/day/1
  """

  import AdventOfCode2021.Utils.Inputs

  @spec one :: integer()
  def one() do
    file_to_integer_stream("1/input.txt")
    |> Stream.chunk_every(2, 1, :discard)
    |> Enum.reduce(0, fn [a, b], count -> count + increment_if_increase(a, b) end)
  end

  @spec two :: nil
  def two() do
    file_to_integer_stream("1/input.txt")
    |> Stream.chunk_every(3, 1, :discard)
    |> Stream.map(&Enum.sum/1)
    |> Stream.chunk_every(2, 1, :discard)
    |> Enum.reduce(0, fn [a, b], count -> count + increment_if_increase(a, b) end)
  end

  defp increment_if_increase(a, b), do: if(b > a, do: 1, else: 0)
end
