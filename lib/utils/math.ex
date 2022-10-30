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
  defstruct rows: %{}, columns: %{}, dimensions: 0

  @spec new([[integer()]]) :: %AdventOfCode2021.Utils.Math.Matrix{
          columns: [[integer()]],
          rows: [[integer()]]
        }
  def new(lists = [a | _b]) when is_list(a) do
    %__MODULE__{rows: zip_to_list(lists), columns: lists, dimensions: length(lists)}
  end

  # def new(list) do
  #   columns = for i <- list, do: [i]
  #   %__MODULE__{rows: list, columns: columns, dimensions: 1}
  # end

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

  def mult(a = %__MODULE__{}, b = %__MODULE__{}), do: multiply(a, b)

  def mult_id(%__MODULE__{dimensions: dim}) do
    for i <- 1..dim do
      for j <- 1..dim do
        if i == j, do: 1, else: 0
      end
    end
  end

  @spec multiply(
          %__MODULE__{},
          %__MODULE__{}
        ) :: %__MODULE__{}
  def multiply(%__MODULE__{rows: rows_a, columns: _columns_a}, %__MODULE__{
        rows: _rows_b,
        columns: columns_b
      }) do
    new_cols =
      for row <- rows_a do
        for col <- columns_b do
          Enum.zip(row, col)
          |> Enum.map(fn {r, c} -> r * c end)
          |> Enum.sum()
        end
      end

    new(new_cols)
  end

  defp zip_to_map(lists) do
    zip_to_list(lists)
    |> list_to_map()
  end

  defp zip_to_list(lists) do
    Enum.zip(lists)
    |> Enum.map(&Tuple.to_list/1)
  end

  defp list_to_map(list) do
    Enum.with_index(list)
    |> Map.new()
  end

  defp depth([list]), do: 1 + depth(list)

  defp depth(_list), do: 1
end
