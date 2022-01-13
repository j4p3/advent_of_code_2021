defmodule AdventOfCode2021.Thirteen do
  @moduledoc """
  Day 13: Transparent Origami
  https://adventofcode.com/2021/day/13

  Simple transformation over list
  Could be a nice nx solution for long lists
  Works nicely with grid utility, since answer requires display
  """

  def one(input_file) do
    {dots, instructions} =
      input_file
      |> parse_input()

    transform_dots(List.first(instructions), dots)
    |> length()
  end

  def two(input_file) do
    {dots, instructions} =
      input_file
      |> parse_input()

    Enum.reduce(instructions, dots, &transform_dots/2)
    |> AdventOfCode2021.Utils.Grid.from_coordinates()
    |> AdventOfCode2021.Utils.Grid.inspect()
  end

  def transform_dots({:x, fold_line}, dots) do
    for {x, y} <- dots do
      if x < fold_line do
        {x, y}
      else
        {2 * fold_line - x, y}
      end
    end
    |> Enum.uniq()
  end

  def transform_dots({:y, fold_line}, dots) do
    for {x, y} <- dots do
      if y < fold_line do
        {x, y}
      else
        {x, 2 * fold_line - y}
      end
    end
    |> Enum.uniq()
  end

  def parse_input(input_file) do
    {dot_strings, instruction_strings} =
      (File.cwd!() <> "/lib/days/13/" <> input_file)
      |> File.read!()
      |> String.split("\n")
      |> Enum.chunk_by(fn l -> l == "" end)
      |> Enum.reject(fn i -> i == [""] end)
      |> List.to_tuple()

    {Enum.map(dot_strings, &parse_dot/1), Enum.map(instruction_strings, &parse_instruction/1)}
  end

  def parse_dot(dot_string) do
    String.split(dot_string, ",")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  def parse_instruction("fold along " <> instruction) do
    [dimension, fold_line] = String.split(instruction, "=")
    {String.to_atom(dimension), String.to_integer(fold_line)}
  end
end
