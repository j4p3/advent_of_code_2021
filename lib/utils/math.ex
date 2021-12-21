defmodule AdventOfCode2021.Utils.Math do
  def triangle(n), do: Enum.reduce(1..n, &+/2)
end
