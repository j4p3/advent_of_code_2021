defmodule AdventOfCode2021.Drawing do
  @moduledoc """
  Representing a list of two-element lists as a layered string.
  """

  def diagram([l, r]) do
    draw_container([l, r])
  end

  # def diagram([l, r]) when is_list(l) do
  #   "#{draw_container([l])}#{r}"
  # end

  # def diagram([l, r]) when is_list(r) do
  #   "#{l}#{draw_container(r)}"
  # end

  # def diagram([l, r]), do: draw_container([l, r])

  def diagram(el), do: "#{el}"

  # entry
  def draw(list) do
    q = :queue.new()
    q = :queue.in({list, 0, 0}, q)
    traverse(:queue.out(q), "", 0)
  end

  # base case
  def traverse({:empty, _}, visited, _), do: visited

  # general cases
  def traverse({{:value, {[l, r], spacing, depth}}, q}, drawing, prev_depth) do
    # if spacing > 0 do
    #   IO.inspect([l, r], charlists: :as_lists)
    # end
    q = :queue.in({l, spacing, depth + 1}, q)
    next_spacing = if height(r) > height(l), do: spacing + width(l), else: 0
    q = :queue.in({r, next_spacing, depth + 1}, q)

    diagram = "#{diagram([l, r])}"
    # diagram = "#{draw_space(spacing)}#{diagram([l, r])}"
    drawing = if depth > prev_depth, do: drawing <> "\n", else: drawing

    traverse(:queue.out(q), drawing <> diagram, depth)
  end

  def traverse({{:value, {el, spacing, depth}}, q}, drawing, prev_depth) do
    diagram = "#{draw_space(spacing)}#{diagram(el)}"
    drawing = if depth > prev_depth, do: drawing <> "\n", else: drawing
    traverse(:queue.out(q), drawing <> diagram, depth)
  end

  def draw_container(list) do
    limit = width(list)

    for i <- 1..limit, into: "" do
      cond do
        i == 1 -> "["
        i == limit -> "]"
        true -> "-"
      end
    end
  end

  def draw_space(0), do: ""
  def draw_space(number), do: for(_ <- 1..number, into: "", do: " ")

  def columns(0), do: 1
  def columns(number), do: floor(:math.log10(number)) + 1

  def width(list) when is_list(list) do
    list
    |> List.flatten()
    |> Enum.map(&columns/1)
    |> Enum.sum()
  end

  def width(num), do: columns(num)

  def height([l, r]) when is_list(l) and is_list(r) do
    Enum.max([height(l) + 1, height(r) + 1])
  end

  def height([l, _]) when is_list(l) do
    height(l) + 1
  end

  def height([_, r]) when is_list(r) do
    height(r) + 1
  end

  def height([_, _]), do: 1

  def height(_), do: 0
end
