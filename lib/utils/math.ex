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
  defstruct coords: []
  @spec new([integer()]) :: %AdventOfCode2021.Utils.Math.Vector{coords: [integer()]}
  def new(list) do
    %__MODULE__{coords: list}
  end

  @spec dim(%AdventOfCode2021.Utils.Math.Vector{}) :: non_neg_integer
  def dim(vector = %__MODULE__{}), do: length(vector.coords)
end

defmodule AdventOfCode2021.Utils.Math.Matrix do
  defstruct rows: [], columns: []

  @spec new([integer()]) :: %AdventOfCode2021.Utils.Math.Matrix{columns: [[integer()]], rows: [[integer()]]}
  def new(lists) do
    %__MODULE__{rows: lists, columns: Enum.zip(lists)}
  end

  # def pow(%__MODULE__{} = matrix, {:vector, vector}) do
  #   vector
  # end

  # def pow(%__MODULE__{} = matrix, {:matrix, matrix}) do
  #   matrix
  # end

  # def multiply(a = %__MODULE__{}, b = %AdventOfCode2021.Utils.Math.Vector{}) do
  #   # for i <- Tuple.to_list(vector), do: i

  #   # end
  #   for {i, j} <- Enum.zip(Tuple.to_list(vector), matrix) do
  #     Enum.sum([i, j])
  #   end
  #   for i <- matrix,
  #       {_j, k} <- Enum.zip(vector, i) do
  #     i * k
  #   end
  # end

  def multiply(%__MODULE__{rows: rows_a, columns: _columns_a}, %__MODULE__{rows: _rows_b, columns: columns_b}) do
    for {row, column} <- Enum.zip(rows_a, columns_b) do
      for {a, b} <- Enum.zip(row, column) do
        a * b
      end
    end
  end
end
