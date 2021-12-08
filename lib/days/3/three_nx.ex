defmodule AdventOfCode2021.ThreeNx do
  @moduledoc """
  Day 3: https://adventofcode.com/2021/day/3
  Nx solution doing matrix operations on lists instead of iterating through them
  largely via https://gist.github.com/seanmor5/8a27ff8048040e22ae012983981f97b7
  """

  import Nx.Defn
  alias AdventOfCode2021.Utils.Inputs

  # length of bytes in input file
  @input_bitwidth 12

  @spec one(binary) :: number
  def one(input_file) do
    input_file
    |> nx_parse_input()
    |> power_consumption()
  end

  defp nx_parse_input(input_file) do
    input_file
    |> Inputs.file_to_stream()
    # getting the ASCII values of a char here, which means "0" is numerically 48, so shift to 0
    |> Enum.map(&Nx.subtract(Nx.from_binary(&1, {:u, 8}), Nx.tensor(48)))
    # turn a list of tensors into a single two-dimensional tensor
    |> Nx.stack()
  end

  # defn just marks this for compilation to gpu targets via exla/torch
  defnp power_consumption(bytes) do
    zeroes = count_occurrences(bytes, 0, axis: 0)
    ones = count_occurrences(bytes, 1, axis: 0)
    gamma = Nx.greater(ones, zeroes)
    epsilon = Nx.logical_not(gamma)
    Nx.multiply(binary_tensor_to_decimal(gamma), binary_tensor_to_decimal(epsilon))
  end

  # Build tensor of matches, then sum it
  defnp count_occurrences(x, value, opts \\ []) do
    opts = keyword!(opts, axis: 0)
    Nx.sum(Nx.equal(x, value), axes: [opts[:axis]])
  end

  # Turn a tensor representing a binary into a single-element decimal tensor
  # using dot product, vector multiplication to achieve Enum.join() |> Integer.parse(2)
  defnp binary_tensor_to_decimal(x, opts \\ []) do
    opts = keyword!(opts, bitwidth: @input_bitwidth)
    # the binary representation is ordered MSB to LSB,
    # so we can obtain this by using iota (a counter)
    # and taking element-wise 2^x. Then we reverse (bits
    # are MSB to LSB) and take the dot product between
    # our binary number and the bit values

    # apply a power of 2 (4, 16, ..)
    2
    # for as long as the width of the actual input
    |> Nx.power(Nx.iota({opts[:bitwidth]}))
    # (it'll come out backwards)
    |> Nx.reverse()
    # but only where we've got a 1 bit
    |> Nx.dot(x)
  end
end
