defmodule AdventOfCode2021.Ten do
  @moduledoc """
  Day 10: Syntax Scoring
  https://adventofcode.com/2021/day/10
  """

  @closing_map %{
    ")" => {"(", 3},
    "]" => {"[", 57},
    "}" => {"{", 1197},
    ">" => {"<", 25137}
  }

  @opening_map %{
    "(" => {")", 1},
    "[" => {"]", 2},
    "{" => {"}", 3},
    "<" => {">", 4}
  }

  def one(input_file) do
    input_file
    |> parse_input()
    |> Enum.map(&error_score/1)
    |> Enum.sum()
  end

  def two(input_file) do
    input_file
    |> parse_input()
    |> Enum.filter(&is_not_corrupted?/1)
    |> Enum.map(&autocomplete/1)
    |> Enum.map(&autocomplete_score/1)
    |> Enum.sort()
    |> middle()
  end

  def middle(list) do
    Enum.at(list, div(length(list), 2))
  end

  def is_not_corrupted?(line), do: error_score(line) == 0

  def autocomplete_score(line) do
    line
    |> Enum.reduce(0, fn {_char, score}, acc -> acc * 5 + score end)
  end

  # public function
  def autocomplete([char | rem]) do
    autocomplete([char], rem)
  end

  # exit case: string complete
  def autocomplete(stack, []) do
    stack
    |> Enum.map(fn c -> Map.get(@opening_map, c) end)
  end

  # empty stack at end of line: empty autocomplete
  def autocomplete([], []), do: []

  # empty stack case: proceed
  def autocomplete([], [char | rem]), do: autocomplete([char], rem)

  # normal case: pop opening char from stack or continue stacking open chars
  def autocomplete([top | tail] = stack, [char | rem]) do
    {open, _} = Map.get(@closing_map, char, {nil, nil})

    if top == open do
      autocomplete(tail, rem)
    else
      autocomplete([char | stack], rem)
    end
  end

  # public function
  @spec error_score([String.t()]) :: integer()
  def error_score([top | tail]) do
    error_score([top], tail)
  end

  # normal exit case: string complete
  defp error_score(_stack, []), do: 0

  # empty stack case: throw on closing
  defp error_score([], [char | rem]) do
    case Map.get(@closing_map, char) do
      nil -> error_score([char], rem)
      {_open, points} -> points
    end
  end

  # normal case: check closing char against stack or continue stacking open chars
  defp error_score([top | tail] = stack, [char | rem]) do
    case Map.get(@closing_map, char) do
      nil -> error_score([char | stack], rem)
      {open, points} -> if top == open, do: error_score(tail, rem), else: points
    end
  end

  def parse_input(input_file) do
    (File.cwd!() <> "/lib/days/10/" <> input_file)
    |> File.read!()
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
  end
end
