defmodule AdventOfCode2021.EighteenRedux do
  @moduledoc """
  Day 18: Snailfish
  https://adventofcode.com/2021/day/18
  """

  def one(input_file, debug? \\ false) do
    debug_list = if debug?, do: parse_input(input_file <> "_results"), else: nil

    input_file
    |> parse_input()
    |> then(&sum_lists(&1, debug_list))
    |> magnitude()
  end

  def two(input_file) do
    nums =
      input_file
      |> parse_input()

    for a <- nums,
        b <- nums,
        reduce: 0 do
      acc ->
        if a == b, do: acc, else: max(acc, magnitude(reduce([a, b])))
    end
  end

  defp magnitude([l, r]) do
    3 * magnitude(l) + 2 * magnitude(r)
  end

  defp magnitude(el), do: el

  defp sum_lists(lists, debug_list) do
    {_, result, _} =
      Enum.reduce(tl(lists), {0, hd(lists), debug_list}, fn list, {i, acc, debug} ->
        {head, tail} = if debug, do: {hd(debug), tl(debug)}, else: {nil, nil}
        result = reduce([acc, list])

        if is_nil(head) or result == head do
          {i + 1, result, tail}
        else
          IO.puts("\n\nwrong answer")
          IO.puts("expected:")
          IO.inspect(head, charlists: :as_lists)
          IO.puts("got:")
          IO.inspect(result, charlists: :as_lists)
          exit(:ennui)
        end
      end)

    result
  end

  defp reduce(list, inspect? \\ false) do
    {list, exp?} = explode(list)

    if exp? do
      reduce(list, inspect?)
    else
      {list, split?} = split(list)

      if split?, do: reduce(list, inspect?), else: list
    end
  end

  # general case (both)
  defp split([l_list, r_list]) when is_list(l_list) and is_list(r_list) do
    {l_list, split_l?} = split(l_list)

    if split_l? do
      {[l_list, r_list], split_l?}
    else
      {r_list, split_r?} = split(r_list)
      {[l_list, r_list], split_r?}
    end
  end

  # general case (right-hand int)
  defp split([l_list, right]) when right < 10 and is_list(l_list) do
    {l_list, split?} = split(l_list)
    {[l_list, right], split?}
  end

  # general case (left-hand int)
  defp split([left, r_list]) when left < 10 and is_list(r_list) do
    {r_list, split?} = split(r_list)
    {[left, r_list], split?}
  end

  # base case (left-hand int)
  defp split([left, r_list]) when is_list(r_list) and left >= 10 do
    {[[floor(left / 2), ceil(left / 2)], r_list], true}
  end

  # base case (right-hand int)
  defp split([l_list, right]) when is_list(l_list) and right >= 10 do
    {l_list, split_l?} = split(l_list)

    if split_l? do
      {[l_list, right], split_l?}
    else
      {[l_list, [floor(right / 2), ceil(right / 2)]], true}
    end
  end

  # base case (pair)
  defp split([left, right]) do
    cond do
      left >= 10 ->
        {[[floor(left / 2), ceil(left / 2)], right], true}

      right >= 10 ->
        {[left, [floor(right / 2), ceil(right / 2)]], true}

      true ->
        {[left, right], false}
    end
  end

  # entry case
  defp explode(input) do
    case explode(input, 1) do
      {{_, list}, exp?} when is_list(list) -> {list, exp?}
      {{list, _}, exp?} when is_list(list) -> {list, exp?}
      result_tuple -> result_tuple
    end
  end

  # general case (both, exploding right)
  defp explode([l_list, r_list], depth, :right) when is_list(l_list) and is_list(r_list) do
    case explode(r_list, depth + 1) do
      {{l_value, 0, r_value}, exp?} ->
        {{[push(:left, l_list, l_value), 0], r_value}, exp?}

      {{l_value, new_r_list}, exp?} when is_list(new_r_list) ->
        {[push(:left, l_list, l_value), new_r_list], exp?}

      {{new_r_list, r_value}, exp?} when is_list(new_r_list) ->
        {{[l_list, new_r_list], r_value}, exp?}

      {new_r_list, exp?} ->
        {[l_list, new_r_list], exp?}
    end
  end

  # general case (both, exploding left)
  defp explode([l_list, r_list], depth) when is_list(l_list) and is_list(r_list) do
    case explode(l_list, depth + 1) do
      {{l_value, 0, r_value}, exp?} ->
        {{l_value, [0, push(:right, r_list, r_value)]}, exp?}

      {{l_value, new_l_list}, exp?} when is_list(new_l_list) ->
        {{l_value, [new_l_list, r_list]}, exp?}

      {{new_l_list, r_value}, exp?} when is_list(new_l_list) ->
        {[new_l_list, push(:right, r_list, r_value)], exp?}

      {new_l_list, true} ->
        {[new_l_list, r_list], true}

      {new_l_list, false} ->
        explode([new_l_list, r_list], depth, :right)
    end
  end

  # general case (left list)
  defp explode([l_list, right], depth) when is_list(l_list) do
    case explode(l_list, depth + 1) do
      {{l_value, 0, r_value}, exp?} ->
        {{l_value, [0, right + r_value]}, exp?}

      {{new_l_list, r_value}, exp?} when is_list(new_l_list) ->
        {[new_l_list, right + r_value], exp?}

      {{l_value, new_l_list}, exp?} when is_list(new_l_list) ->
        {{l_value, [new_l_list, right]}, exp?}

      {new_l_list, exp?} ->
        {[new_l_list, right], exp?}
    end
  end

  # general case (right list)
  defp explode([left, r_list], depth) when is_list(r_list) do
    case explode(r_list, depth + 1) do
      {{l_value, 0, r_value}, exp?} ->
        {{[l_value + left, 0], r_value}, exp?}

      {{l_value, new_r_list}, exp?} when is_list(new_r_list) ->
        {[left + l_value, new_r_list], exp?}

      {{new_r_list, r_value}, exp?} when is_list(new_r_list) ->
        {{[left, new_r_list], r_value}, exp?}

      {new_r_list, exp?} ->
        {[left, new_r_list], exp?}
    end
  end

  # base case: integer pair, explosion
  defp explode([left, right], depth) when depth > 4 do
    {{left, 0, right}, true}
  end

  # base case: integer pair, no explosion
  defp explode([left, right], _depth) do
    {[left, right], false}
  end

  # general case: pushing left, both list
  defp push(:left, [l_list, r_list], value) when is_list(l_list) and is_list(r_list) do
    [l_list, push(:left, r_list, value)]
  end

  # general case: pushing right, both list
  defp push(:right, [l_list, r_list], value) when is_list(l_list) and is_list(r_list) do
    [push(:right, l_list, value), r_list]
  end

  # general case: pushing left, right list
  defp push(:left, [left, r_list], value) when is_list(r_list) do
    [left, push(:left, r_list, value)]
  end

  # general case: pushing right, left list
  defp push(:right, [l_list, right], value) when is_list(l_list) do
    [push(:right, l_list, value), right]
  end

  # base case: pushing right, left int
  defp push(:right, [left, right], value) when is_integer(left) do
    [left + value, right]
  end

  # base case: pushing left, right int
  defp push(:left, [left, right], value) when is_integer(right) do
    [left, right + value]
  end

  defp parse_input(input_file) do
    "/lib/days/18/#{input_file}.txt"
    |> AdventOfCode2021.Utils.Inputs.file_by_line()
    |> Enum.map(&parse_input_line/1)
  end

  defp parse_input_line(line) do
    {line_literal, _binding} = Code.eval_string(line)
    line_literal
  end
end
