defmodule AdventOfCode2021.Three do
  @moduledoc """
  Day 3: https://adventofcode.com/2021/day/3
  """

  alias AdventOfCode2021.Utils.Inputs

  ##
  # Pure elixir solution: reduce over list of lists, recursing through children binary string lists
  ##

  @spec one(binary) :: number
  def one(filepath) do
    [gamma, epsilon] =
      filepath
      |> parse_input()
      |> gamma_epsilon()

    gamma * epsilon
  end

  @spec two(binary) :: number
  def two(input_file) do
    input_file
    |> parse_input()
    |> life_support()
  end

  # turn input into list of lists of integers
  defp parse_input(filepath) do
    filepath
    |> Inputs.file_to_stream()
    |> Enum.map(&Inputs.to_integer_list/1)
  end

  # calculate life support rating:
  # oxygen rating (repeatedly filter l->r by most common bit value, converted to decimal)
  # times co2 rating (least common bits, converted to decimal)
  defp life_support([first | _] = bytes) do
    byte_length = length(first) - 1
    {_mode, [oxygen_rating]} = Enum.reduce_while(0..byte_length, {:most, bytes}, &filter_bytes/2)

    {_mode, [co2_rating]} = Enum.reduce_while(0..byte_length, {:least, bytes}, &filter_bytes/2)

    bit_list_to_int(oxygen_rating) * bit_list_to_int(co2_rating)
  end

  # base case to return byte matching least/most matching criteria
  defp filter_bytes(_index, {mode, [last_element]}), do: {:halt, {mode, [last_element]}}

  # for a list of bytes, remove the elements which don't have the least common bit at index
  defp filter_bytes(index, {:least, list}) do
    {_, least_frequent} = most_least_frequent_at(list, index)

    {:cont, {:least, Enum.filter(list, fn byte -> Enum.at(byte, index) == least_frequent end)}}
  end

  # for a list of bytes, remove the elements which don't have the most common bit at index
  defp filter_bytes(index, {:most, list}) do
    {most_frequent, _} = most_least_frequent_at(list, index)

    {:cont, {:most, Enum.filter(list, fn byte -> Enum.at(byte, index) == most_frequent end)}}
  end

  # for a list of bytes, calculate the most frequent bit value at index (sum + divide)
  defp most_least_frequent_at(bytes, index) do
    sum_at_index = Enum.reduce(bytes, 0, fn byte, acc -> Enum.at(byte, index) + acc end)

    most_at_index = if sum_at_index >= length(bytes) / 2, do: 1, else: 0
    least_at_index = if sum_at_index < length(bytes) / 2, do: 1, else: 0
    {most_at_index, least_at_index}
  end

  # least & most common bit values of a list of bytes
  defp gamma_epsilon(bytes) do
    bytes
    |> Enum.reduce({[], 0}, &sum_int_lists/2)
    |> build_max_min()
    |> Enum.map(&bit_list_to_int/1)
  end

  # sum values at each bit position for list of bytes
  defp sum_int_lists(int_list, {[], count}),
    do: sum_int_lists(int_list, {for(_ <- 1..length(int_list), do: 0), count})

  defp sum_int_lists(int_list, {sums, count}) do
    {increment_intlist_sums(int_list, sums), count + 1}
  end

  # walk through a byte with a sum for each bit position and increment those sums
  defp increment_intlist_sums(byte, sums, new_sums \\ [])
  defp increment_intlist_sums([], [], new_sums), do: Enum.reverse(new_sums)

  defp increment_intlist_sums([bit_value | byte], [bit_sum | sums], new_sums) do
    increment_intlist_sums(byte, sums, [bit_sum + bit_value | new_sums])
  end

  # most and least frequent bit at each position
  defp build_max_min({sums, count}) do
    # build both at once
    max = for bit_sum <- sums, do: if(bit_sum >= count / 2, do: 1, else: 0)
    min = for bit_sum <- sums, do: if(bit_sum < count / 2, do: 1, else: 0)
    [max, min]
  end

  # convert list of integers representing a byte to a decimal integer
  defp bit_list_to_int(bit_list) do
    bit_list
    |> Enum.join()
    |> Integer.parse(2)
    |> elem(0)
  end
end
