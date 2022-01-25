defmodule AdventOfCode2021.Utils.Math do
  @doc """
  Triangle number of n

  Returns additive factorial of 0 + 1 + 2 .. + n
  """
  @spec triangle(integer) :: integer
  def triangle(0), do: 0
  def triangle(n), do: div(n*(n+1), 2)
end
