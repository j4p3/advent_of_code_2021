defmodule AdventOfCode2021.Utils.Grid do
  @moduledoc """
  A grid structure with width and height attributes.
  """
  defstruct points: %{}, width: nil, height: nil

  @doc """
  Generate a new grid from a list of lists of values.
  """
  @spec new([[integer()]]) :: %AdventOfCode2021.Utils.Grid{}
  def new(lines) do
    points =
      for {line, y} <- Enum.with_index(lines),
          {point, x} <- Enum.with_index(line),
          into: %{},
          do: {{x, y}, point}

    %__MODULE__{points: points, width: length(List.first(lines)), height: length(lines)}
  end

  @doc """
  Generate a new grid from a list of tuples representing {x, y} coordinates
  """
  @spec from_coordinates([{integer(), integer()}]) :: %AdventOfCode2021.Utils.Grid{}
  def from_coordinates(coordinates) do
    # points = for point <- coordinates, into: %{}, do: {point, "#"}
    {points, width, height} = Enum.reduce(coordinates, {%{}, 0, 0}, fn {x, y}, {points, max_width, max_height} ->
      {Map.put(points, {x, y}, "#"), max(max_width, x), max(max_height, y)}
    end)
    %__MODULE__{points: points, width: width + 1, height: height + 1}
  end

  @doc """
  Update a point value
  """
  def set(grid, point, value) do
    %__MODULE__{grid | points: Map.put(grid.points, point, value)}
  end

  @doc """
  Horizontal and vertical neighbors only
  Pass all: true to include diagonals
  """
  def neighbors(grid, point), do: neighbors(grid, point, all: false)
  def neighbors(grid, {x, y}, all: false) do
    [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]
    |> get_valid_points(grid)
  end

  def neighbors(grid, {x, y}, all: true) do
    [
      {x + 1, y},
      {x - 1, y},
      {x, y + 1},
      {x, y - 1},
      {x + 1, y + 1},
      {x + 1, y - 1},
      {x - 1, y + 1},
      {x - 1, y - 1}
    ]
    |> Enum.filter(&in_bounds?(grid, &1))
  end

  defp get_valid_points(point_set, grid) do
    point_set
    |> Enum.filter(&in_bounds?(grid, &1))
    |> Enum.map(fn coords -> {coords, Map.get(grid.points, coords)} end)
  end

  defp in_bounds?(grid, {x, y}), do: x < grid.width && x >= 0 && y < grid.height && y >= 0

  def inspect(grid) do
    for y <- 0..(grid.height - 1) do
      for(x <- 0..(grid.width - 1), do: Map.get(grid.points, {x, y}, "."))
      |> Enum.join()
    end
    |> Enum.join("\n")
    |> IO.puts()
  end

  @spec to_file(%__MODULE__{}, String.t()) :: :ok | {:error, Posix.t()}
  def to_file(grid, filepath) do
    output = for y <- 0..(grid.height - 1) do
      for(x <- 0..(grid.width - 1), do: Map.get(grid.points, {x, y}, "."))
      |> Enum.join()
    end
    |> Enum.join("\n")

    File.write(File.cwd!() <> filepath, output)
  end
end
