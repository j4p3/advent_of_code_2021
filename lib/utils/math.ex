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
  @spec new([integer()]) :: %__MODULE__{coords: [integer()]}
  def new(list) do
    %__MODULE__{coords: list}
  end

  @spec dim(%AdventOfCode2021.Utils.Math.Vector{}) :: non_neg_integer
  def dim(vector = %__MODULE__{}), do: length(vector.coords)
end

defmodule AdventOfCode2021.Utils.Math.Matrix do
  defstruct rows: %{}, columns: %{}, dimensions: 0

  # Right angle 3d rotation matrices
  @rx [[1, 0, 0], [0, 0, -1], [0, 1, 0]]
  @ry [[0, 0, -1], [0, 1, 0], [1, 0, 0]]
  @rz [[0, 1, 0], [-1, 0, 0], [0, 0, 1]]

  @spec new([[integer()]]) :: %__MODULE__{
          columns: [[integer()]],
          rows: [[integer()]]
        }
  def new(lists = [a | _b]) when is_list(a) do
    %__MODULE__{rows: zip_to_list(lists), columns: lists, dimensions: length(lists)}
  end

  @spec multiply(
          %__MODULE__{},
          %__MODULE__{} | %AdventOfCode2021.Utils.Math.Vector{}
        ) :: %__MODULE__{} | %AdventOfCode2021.Utils.Math.Vector{}
  def multiply(%__MODULE__{rows: m_rows}, %AdventOfCode2021.Utils.Math.Vector{coords: v_coords}) do
    for row <- m_rows do
      Enum.zip(row, v_coords)
      |> Enum.map(fn {r, c} -> r * c end)
      |> Enum.sum()
    end
    |> AdventOfCode2021.Utils.Math.Vector.new()
  end

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

  @spec rotate(:x | :y | :z, %AdventOfCode2021.Utils.Math.Vector{}) ::
          %AdventOfCode2021.Utils.Math.Vector{}
  def rotate(:x, vector = %AdventOfCode2021.Utils.Math.Vector{}) do
    multiply(new(@rx), vector)
  end

  def rotate(:y, vector = %AdventOfCode2021.Utils.Math.Vector{}) do
    multiply(new(@ry), vector)
  end

  def rotate(:z, vector = %AdventOfCode2021.Utils.Math.Vector{}) do
    multiply(new(@rz), vector)
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
