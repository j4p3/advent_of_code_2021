defmodule AdventOfCode2021.EighteenRedux do
  @moduledoc """
  Day 18: Snailfish
  https://adventofcode.com/2021/day/18
  """

  def one(input_file) do
    :ok
  end

  def parse_input(input_file) do
    ("/lib/days/18/" <> input_file)
    |> AdventOfCode2021.Utils.Inputs.file_by_line()
    |> Enum.map(&parse_input_line/1)
  end

  def parse_input_line(line) do
    {line_literal, _binding} = Code.eval_string(line)
    line_literal
  end
end
