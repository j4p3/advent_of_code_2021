defmodule AdventOfCode2021.Seventeen do
  @moduledoc """
  Day 17: Trick Shot
  https://adventofcode.com/2021/day/17
  """

  alias AdventOfCode2021.Utils.Math

  def one(input) do
    [{:x, {_x_start, _x_end}}, {:y, {y_end, _y_start}}] = parse_input(input)

    y_end
    |> max_y_velocity()
    |> apogee()
  end

  def two(input) do
    [{:x, {x_start, x_end}}, {:y, {y_end, y_start}}] = parse_input(input)

    accumulate_velocities(
      {{min_x_velocity(x_start), max_x_velocity(x_end)},
       {min_y_velocity(y_end), max_y_velocity(y_end)}},
      {{x_start, x_end}, {y_start, y_end}}
    )
    |> List.flatten()
    |> length
  end

  # entry case
  def accumulate_velocities(velocity_min_max, target_limits),
    do: accumulate_velocities(velocity_min_max, target_limits, [])

  # base case
  def accumulate_velocities({{vx0, max_x}, _y_min_max}, _target_limits, velocities)
      when vx0 > max_x,
      do: velocities

  # general case
  def accumulate_velocities({{vx0, max_x}, {min_y, max_y}}, target_limits, velocities) do
    new_velocities =
      Enum.reduce_while(min_y..max_y, [], fn vy0, acc ->
        # @todo optimize for starting with correct y range for x
        if intersects?({vx0, vy0}, target_limits) do
          {:cont, [{vx0, vy0} | acc]}
        else
          {:cont, acc}
        end
      end)

    accumulate_velocities({{vx0 + 1, max_x}, {min_y, max_y}}, target_limits, [
      new_velocities | velocities
    ])
  end

  # entry case
  def intersects?({vx0, vy0} = velocities, target_limits),
    do: intersects?({vx0, vy0}, velocities, 1, target_limits)

  # base case
  def intersects?({x, y}, _velocities, _t, {{x_start, x_end}, {y_start, y_end}})
      when x_start <= x and x <= x_end and y_end <= y and y <= y_start,
      do: true

  def intersects?({x, y}, _velocities, _t, {{_x_start, x_end}, {_y_start, y_end}})
      when x > x_end or y < y_end,
      do: false

  # general case
  def intersects?({x, y}, {vx, vy}, t, target_limits) do
    vx1 = max(vx - 1, 0)
    vy1 = vy - 1
    intersects?({x + vx1, y + vy1}, {vx1, vy1}, t + 1, target_limits)
  end

  def max_x_velocity(x_end), do: x_end

  def min_x_velocity(x_start), do: ceil(:math.sqrt(x_start))

  def min_y_velocity(y_end), do: -max_y_velocity(y_end) - 1

  def max_y_velocity(y_end) do
    abs(y_end) - 1
  end

  def apogee(y_velocity) do
    Math.triangle(y_velocity)
  end

  def x_at_t(vx0, step), do: max(vx0 - step, 0)

  def y_at_t(vy0, t) do
    vy0 * t - Math.triangle(t - 1)
  end

  def parse_input(<<"target area: ", coordinates::binary>>) do
    coordinates
    |> String.split(", ", trim: true)
    |> Enum.map(fn coordinate ->
      [dimension, range] = String.split(coordinate, "=", trim: true)
      [start, finish] = String.split(range, "..", trim: true)
      {String.to_atom(dimension), {String.to_integer(start), String.to_integer(finish)}}
    end)
  end
end
