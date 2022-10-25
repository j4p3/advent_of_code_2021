defmodule AdventOfCode2021.Utils.Math do
  @doc """
  Triangle number of n

  Returns additive factorial of 0 + 1 + 2 .. + n
  """
  @spec triangle(integer) :: integer
  def triangle(0), do: 0
  def triangle(n), do: div(n * (n + 1), 2)
end

defmodule AdventOfCode2021.Utils.Math.Vector do
  def new(list) do
    list
  end
end

defmodule AdventOfCode2021.Utils.Math.Matrix do
  defstruct rows: [], columns: []

  def new(lists) do
    %__MODULE__{rows: lists, columns: Enum.zip(lists)}
  end

  def pow(%__MODULE__{} = matrix, {:vector, vector}) do
    vector
  end

  def pow(%__MODULE__{} = matrix, {:matrix, matrix}) do
    matrix
  end

  def multiply(matrix, {:vector, vector}) do
    # for i <- Tuple.to_list(vector), do: i

    # end
    for {i, j} <- Enum.zip(Tuple.to_list(vector), matrix) do
      Enum.sum([i, j])
    end
    for i <- matrix,
        {_j, k} <- Enum.zip(vector, i) do
      i * k
    end
  end

  def multiply(matrix, {:matrix, matrix}) do
    matrix
  end
end
