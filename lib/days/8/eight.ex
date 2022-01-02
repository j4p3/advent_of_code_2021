defmodule AdventOfCode2021.Eight do
  @moduledoc """
  Day 8: Seven Segment Search
  https://adventofcode.com/2021/day/8
  """

  @known_lengths %{
    2 => 1,
    3 => 7,
    4 => 4,
    7 => 8
  }

  defmodule Display do
    @known_lengths %{
      2 => 1,
      3 => 7,
      4 => 4,
      7 => 8
    }

    @segments_default %{a: nil, b: nil, c: nil, d: nil, e: nil, f: nil, g: nil}
    @ints_default %{
      1 => nil,
      2 => nil,
      3 => nil,
      4 => nil,
      5 => nil,
      6 => nil,
      7 => nil,
      8 => nil,
      9 => nil,
      0 => nil
    }

    defstruct signals: %{}, ints: @ints_default, segments: @segments_default, key: nil

    def new(signals) do
      %Display{signals: signals}
      |> set_known_patterns()
      |> set_pattern(6)
      |> set_pattern(3)
      |> set_pattern(9)
      |> set_pattern(2)
      |> create_key()
    end

    defp set_known_patterns(display) do
      Enum.reduce(@known_lengths, display, fn {k, v}, acc ->
        set_int(acc, v, List.first(Map.get(display.signals, k)))
      end)
    end

    defp set_pattern(display, 6) do
      six_pattern =
        Enum.find(display.signals[6], fn s ->
          MapSet.size(MapSet.intersection(display.ints[1], s)) == 1
        end)

      display
      |> pop_signal(6, six_pattern)
      |> set_int(6, six_pattern)
    end

    defp set_pattern(display, 3) do
      three_pattern =
        Enum.find(display.signals[5], fn s ->
          MapSet.size(MapSet.intersection(display.ints[1], s)) == 2
        end)

      display
      |> pop_signal(5, three_pattern)
      |> set_int(3, three_pattern)
    end

    defp set_pattern(display, 9) do
      # sets 9 and 0
      fe_set = MapSet.difference(display.ints[8], display.ints[3])

      signal_diffs =
        for signal <- display.signals[6] do
          {signal, MapSet.intersection(fe_set, signal)}
        end

      {nine_pattern, f_set} =
        Enum.find(signal_diffs, fn {_signal, diff} -> MapSet.size(diff) == 1 end)

      display
      |> set_segment(:f, f_set)
      |> pop_signal(6, nine_pattern)
      |> set_int(9, nine_pattern)
      |> (&set_int(&1, 0, List.first(&1.signals[6]))).()
    end

    # defp set_pattern(display, 0), do: set_pattern(display, 9)
    # defp set_pattern(display, 5), do: set_pattern(display, 2)

    defp set_pattern(display, 2) do
      two_pattern =
        Enum.find(display.signals[5], fn s ->
          MapSet.disjoint?(s, display.segments[:f])
        end)

      display
      |> pop_signal(5, two_pattern)
      |> set_int(2, two_pattern)
      |> (&set_int(&1, 5, List.first(&1.signals[5]))).()
    end

    def set_int(display, known_int, value) do
      %Display{display | ints: %{display.ints | known_int => value}}
    end

    def set_segment(display, key, value) do
      %Display{display | segments: %{display.segments | key => value}}
    end

    def pop_signal(display, signal_length, signal_pattern) do
      new_signal_set =
        Enum.filter(display.signals[signal_length], fn s ->
          s != signal_pattern
        end)

      %Display{display | signals: %{display.signals | signal_length => new_signal_set}}
    end

    def create_key(display) do
      key = for {k, v} <- display.ints, into: %{}, do: {v, k}
      %Display{display | key: key}
    end
  end

  def one(input_file) do
    parse_input(input_file)
    |> Enum.reduce(0, fn [_signals, outputs], acc ->
      acc + Enum.count(outputs, fn o -> Map.has_key?(@known_lengths, String.length(o)) end)
    end)
  end

  @doc """
  Ideas:
  Build signal -> segment map from unique counts

  We have:
  * segment requirements per letter
  * constraints on which signals can represent which segments
  * known intersections:
  *   1 int 7|4|8 = bc
  *   8 int 7 = abc
  *   7 - 1 = a
  *   where n = [6|9|0] int 1 = [x], n = 6 && x = c
  *   where n = [2|3|5] int 1 = [x, y], n = 3
  *   where (8 - 3) int n = [9|0] = [x], n = 9, x = f
  *   where f disj n = [2|5], n = 2
  """
  def two(input_file) do
    input_file
    |> parse_input()
    |> Enum.map(&build_line/1)
    |> Enum.map(&build_key/1)
    |> Enum.map(&solve_outputs/1)
    |> Enum.sum()
  end

  def build_line({signals, outputs}) do
    line_map =
      signals
      |> Enum.reduce(%{}, fn s, acc ->
        signal = MapSet.new(String.to_charlist(s))

        Map.update(acc, String.length(s), [signal], fn ex ->
          # not generating a new list here, wtf
          [signal | ex]
        end)
      end)

    output_sets =
      outputs
      |> Enum.map(&String.to_charlist/1)
      |> Enum.map(&MapSet.new/1)

    {line_map, output_sets}
  end

  def build_key({signals, outputs}) do
    display = Display.new(signals)
    {display.key, outputs}
  end

  def solve_outputs({key, outputs}) do
    outputs
    |> Enum.map(fn o -> key[o] end)
    |> Enum.join()
    |> String.to_integer()
  end

  def parse_input(input_file) do
    (File.cwd!() <> "/lib/days/8/" <> input_file)
    |> File.read!()
    |> String.split("\n")
    |> Enum.map(fn s ->
      String.split(s, "|")
      |> Enum.map(&String.split/1)
      |> List.to_tuple()
    end)
  end
end
