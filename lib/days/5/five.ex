defmodule AdventOfCode2021.Five do
  @moduledoc """
  Day 5: Hydrothermal Venture
  https://adventofcode.com/2021/day/5
  """

  @doc """
  Ideas:
  * build map by iterating through each line segment & incrementing
  * build system of equations, iterate through combinations, setting equal & solving for intersection points
    * equation: m = (y2 - y1)/(x2 - x1), solve for b with known point
    * modify equation w/ sqrt(abs(x - limit)), where limit = x value of line ends
    * ^ won't work for vertical lines
  """
  def one(input) do
    input
    |> parse_input()
    |> Enum.filter(&horizontal_or_vertical?/1)
    |> build_map()
    |> Enum.filter(fn {_k, v} -> v > 1 end)
    |> length()
  end

  def two(input) do
    input
    |> parse_input()
    |> build_map()
    |> Enum.filter(fn {_k, v} -> v > 1 end)
    |> length()
  end

  def build_map(lines) do
    Enum.reduce(lines, %{}, fn line, map ->
      for point <- traverse_line(line), reduce: map do
        acc -> Map.update(acc, point, 1, fn val -> val + 1 end)
      end
    end)
  end

  def traverse_line({{x1, y1}, {x2, y2}}) do
    distance = max(abs(x1 - x2), abs(y1 - y2)) + 1

    x_list = if x1 == x2 do
      List.duplicate(x1, distance)
    else
      for x <- x1..x2, do: x
    end

    y_list = if y1 == y2 do
      List.duplicate(y1, distance)
    else
      for y <- y1..y2, do: y
    end

    Enum.zip(x_list, y_list)
  end

  def horizontal_or_vertical?({{x1, y1}, {x2, y2}}), do: x1 == x2 || y1 == y2

  def parse_input(input) do
    (File.cwd!() <> "/lib/days/5/" <> input)
    |> File.read!()
    |> String.split("\n")
    |> Enum.map(fn line ->
      line
      |> String.split(" -> ")
      |> Enum.map(fn point ->
        point
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple()
      end)
      |> List.to_tuple()
    end)
  end
end
