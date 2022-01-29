defmodule AdventOfCode2021.Eighteen do
  @moduledoc """
  Day 18: Snailfish
  https://adventofcode.com/2021/day/18

  @todo: figure out why sample2 breaks on step 5
  after 112 reductions yielding a [7,8] where it should have a [6,8] and a [8,9] where it should have a [9,9]
  """

  def one(input_file) do
    input_file
    |> parse_input()
    |> sum_lists()
  end

  def two(input) do
    input
  end

  def sum_lists(lists) do
    Enum.reduce(lists, fn list, acc ->
      IO.puts("\nadding lists:")
      IO.inspect(acc, charlists: :as_lists)
      IO.inspect(list, charlists: :as_lists)
      reduce([acc, list])
    end)
  end

  def reduce(list) do
    case explode(list) do
      {exp_list, true} ->
        IO.puts("exploded, list is now: ")
        IO.inspect(exp_list, charlists: :as_lists)
        IO.puts("")
        reduce(exp_list)

      {exp_list, false} ->
        case split(exp_list) do
          {split_list, true} ->
            IO.puts("split, list is now: ")
            IO.inspect(split_list, charlists: :as_lists)
            IO.puts("")
            reduce(split_list)

          {split_list, false} ->
            split_list
        end
    end
  end

  # general case (both, check right)
  def split([l_list, r_list], :right) when is_list(l_list) and is_list(r_list) do
    case split(r_list) do
      {new_r_list, true} -> {[l_list, new_r_list], true}
      {new_r_list, false} -> {[l_list, new_r_list], false}
    end
  end

  # general case (both, check left)
  def split([l_list, r_list]) when is_list(l_list) and is_list(r_list) do
    case split(l_list) do
      {new_l_list, true} ->
        {[new_l_list, r_list], true}

      {new_l_list, false} ->
        split([new_l_list, r_list], :right)
    end
  end

  # base case (right-hand int)
  def split([l_list, right]) when is_list(l_list) and right >= 10 do
    IO.puts("splitting [#{right}]")
    {[l_list, [floor(right / 2), ceil(right / 2)]], true}
  end

  # general case (right-hand int)
  def split([l_list, right]) when is_list(l_list) do
    {new_l_list, split?} = split(l_list)
    {[new_l_list, right], split?}
  end

  # base case (left-hand int)
  def split([left, r_list]) when is_list(r_list) and left >= 10 do
    IO.puts("splitting [#{left}]")
    {[[floor(left / 2), ceil(left / 2)], r_list], true}
  end

  # general case (left-hand int)
  def split([left, r_list]) when is_list(r_list) do
    {new_r_list, split?} = split(r_list)
    {[left, new_r_list], split?}
  end

  # base case (pair)
  def split([left, right]) do
    cond do
      left >= 10 ->
        IO.puts("splitting [#{left}]")
        {[[floor(left / 2), ceil(left / 2)], right], true}

      right >= 10 ->
        IO.puts("splitting [#{right}]")
        {[left, [floor(right / 2), ceil(right / 2)]], true}

      true ->
        {[left, right], false}
    end
  end

  # entry case
  def explode(input) do
    case explode(input, 1) do
      {{_, list}, exp?} when is_list(list) -> {list, exp?}
      {{list, _}, exp?} when is_list(list) -> {list, exp?}
      {{_, list}, exp?} when is_list(list) -> {list, exp?}
      {list, true} -> {list, true}
      {list, false} -> {list, false}
    end
  end

  # general case (both, exploding right)
  def explode([l_list, r_list], depth, :right) when is_list(l_list) and is_list(r_list) do
    case explode(r_list, depth + 1) do
      {{l_value, 0, r_value}, exp?} ->
        {{[push(:left, l_list, l_value), 0], r_value}, exp?}

      {{l_value, new_r_list}, exp?} when is_list(new_r_list) ->
        {[push(:left, l_list, l_value), new_r_list], exp?}

      {{new_r_list, r_value}, exp?} when is_list(new_r_list) ->
        {{[l_list, new_r_list], r_value}, exp?}

      {new_r_list, true} when is_list(new_r_list) ->
        {[l_list, new_r_list], true}

      {new_r_list, false} when is_list(new_r_list) ->
        # explode(:right) is only called after default explode(left) fails
        {[l_list, new_r_list], false}
    end
  end

  # general case (both, exploding left)
  def explode([l_list, r_list], depth) when is_list(l_list) and is_list(r_list) do
    case explode(l_list, depth + 1) do
      {{l_value, 0, r_value}, exp?} ->
        {{l_value, [0, push(:right, r_list, r_value)]}, exp?}

      {{l_value, new_l_list}, exp?} when is_list(new_l_list) ->
        {{l_value, [new_l_list, r_list]}, exp?}

      {{new_l_list, r_value}, exp?} when is_list(new_l_list) ->
        {[new_l_list, push(:right, r_list, r_value)], exp?}

      {new_l_list, true} when is_list(new_l_list) ->
        {[new_l_list, r_list], true}

      {new_l_list, false} when is_list(new_l_list) ->
        explode([new_l_list, r_list], depth, :right)
    end
  end

  # general case (left)
  def explode([l_list, right], depth) when is_list(l_list) do
    case explode(l_list, depth + 1) do
      {{l_value, 0, r_value}, exp?} ->
        IO.puts("incrementing #{right} by #{r_value}")
        {{l_value, [0, right + r_value]}, exp?}

      {{new_l_list, r_value}, exp?} when is_list(new_l_list) ->
        IO.puts("incrementing #{right} by #{r_value}")
        {[new_l_list, right + r_value], exp?}

      {{l_value, new_l_list}, exp?} when is_list(new_l_list) ->
        {{l_value, [new_l_list, right]}, exp?}

      {new_l_list, exp?} when is_list(new_l_list) ->
        {[new_l_list, right], exp?}
    end
  end

  # general case (right)
  def explode([left, r_list], depth) when is_list(r_list) do
    case explode(r_list, depth + 1) do
      {{l_value, 0, r_value}, exp?} ->
        IO.puts("incrementing #{left} by #{l_value}")
        {{[l_value + left, 0], r_value}, exp?}

      {{l_value, new_r_list}, exp?} when is_list(new_r_list) ->
        IO.puts("incrementing #{left} by #{l_value}")
        {[left + l_value, new_r_list], exp?}

      {{new_r_list, r_value}, exp?} when is_list(new_r_list) ->
        {{[left, new_r_list], r_value}, exp?}

      {new_r_list, exp?} when is_list(new_r_list) ->
        {[left, new_r_list], exp?}
    end
  end

  # base case: integer pair, explosion
  def explode([left, right], depth) when depth > 4 do
    IO.puts("exploding [#{left}, #{right}]")
    {{left, 0, right}, true}
  end

  # base case: integer pair, no explosion
  def explode([left, right], _depth) do
    {[left, right], false}
  end

  def push(:right, [l_list, r_list], value) when is_list(l_list) and is_list(r_list) do
    [push(:right, l_list, value), r_list]
  end

  def push(:right, [left, r_list], value) when is_list(r_list) do
    IO.puts("incrementing #{left} by #{value}")
    [left + value, r_list]
  end

  def push(:right, [l_list, right], value) when is_list(l_list) do
    [push(:right, l_list, value), right]
  end

  def push(:right, [left, right], value) do
    IO.puts("incrementing #{left} by #{value}")
    [left + value, right]
  end

  def push(:left, [l_list, r_list], value) when is_list(l_list) and is_list(r_list) do
    [l_list, push(:left, r_list, value)]
  end

  def push(:left, [left, r_list], value) when is_list(r_list) do
    [left, push(:left, r_list, value)]
  end

  def push(:left, [l_list, right], value) when is_list(l_list) do
    IO.puts("incrementing #{right} by #{value}")
    [l_list, right + value]
  end

  def push(:left, [left, right], value) do
    IO.puts("incrementing #{right} by #{value}")
    [left, right + value]
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
