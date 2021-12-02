defmodule AdventOfCode2021.Two do
  @moduledoc """
  Day 2: https://adventofcode.com/2021/day/2
  """
  import AdventOfCode2021.Utils.Inputs

  def one() do
    {x, y} = file_to_stream("2/input.txt")
    |> Enum.reduce({0, 0}, &step/2)

    x * y
  end

  def two() do
    {_aim, x, y} = file_to_stream("2/input.txt")
    |> Enum.reduce({0, 0, 0}, &aim_step/2)

    x * y
  end

  defp step(instruction, {x, y}) do
    case read_instruction(instruction) do
      {:forward, n} -> {x + n, y}
      {:up, n} -> {x, y - n}
      {:down, n} -> {x, y + n}
    end
  end

  defp aim_step(instruction, {aim, x, y}) do
    case read_instruction(instruction) do
      {:forward, n} -> {aim, x + n, y + aim * n}
      {:up, n} -> {aim - n, x, y}
      {:down, n} -> {aim + n, x, y}
    end
  end

  defp read_instruction(instruction) do
    instruction
    |> String.split()
    |> List.to_tuple()
    |> tokenize_instruction_terms()
  end

  defp tokenize_instruction_terms({direction, distance}) do
    {String.to_atom(direction), String.to_integer(distance)}
  end
end
