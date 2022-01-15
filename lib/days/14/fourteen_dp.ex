defmodule AdventOfCode.FourteenDp do
  @moduledoc """
  Attempted solution accumulating full transformation per # steps for each pair
  Too memory-inefficient to work for any significant depth
  """

  def two(input_file) do
    {_template, rules} = parse_input(input_file)

    rules
    |> Map.new(fn {{ka, kb}, v} -> {{ka, kb}, [ka <> v <> kb]} end)
    |> polymerize(4)
  end

  # entry case
  def polymerize(transformations, limit), do: polymerize(transformations, 1, limit)

  # base case
  def polymerize(transformations, depth, limit) when depth >= limit, do: transformations

  # general case
  def polymerize(transformations, depth, limit) do
    # IO.puts("polymerize depth #{depth}")
    # IO.write("transformations: ")
    # IO.inspect(Map.get(transformations, {"N", "N"}))
    transformations = for {key, [deepest_level | _tail] = levels} <- transformations, into: %{} do
      # for every key in the map:

      next_levels = deepest_level
      |> chunk()
      |> Enum.map(fn chunk ->
        # for every chunk in the current deepest level (r -> l),
        if key == {"N", "N"} do
          # IO.write("chunk: ")
          # IO.inspect(chunk)
        end
        Map.get(transformations, chunk)
        |> Enum.reverse()
      end)
      # produce a list of subsequent levels
      |> Enum.zip()
      |> Enum.map(fn level_results ->
        # and at each level, join the results
        if key == {"N", "N"} do
          # IO.write("level_results: ")
          # IO.inspect(level_results)
        end
        level_results
        |> Tuple.to_list()
        # something wrong here - merging chunks broken, missing final char, only on furthest depth?
        |> merge_chunks()
      end)


      {key, Enum.reverse(next_levels) ++ levels}
    end

    # IO.write("NN stack: ")
    # IO.inspect(Map.get(transformations, {"N", "N"}))
    polymerize(transformations, depth * 2, limit)
  end

  @doc """
  Turn an input string into paired tuples with a single overlap
  """
  def chunk(input) do
    input
    |> String.codepoints()
    |> Enum.chunk_every(2, 1)
    |> Enum.drop(-1)
    |> Enum.map(&List.to_tuple/1)
  end

  @doc """
  Turn paired tuples with a single overlap into a joined string, removing the overlap
  """
  def merge_chunks(to_merge), do: merge_chunks("", to_merge)

  def merge_chunks(merged, [last]), do: merged <> last

  def merge_chunks(merged, [chunk | tail]) do
    len = byte_size(chunk) - 1
    <<head::binary-size(len), _tail::binary>> = chunk
    merge_chunks(merged <> head, tail)
  end

  def parse_input(input_file) do
    {[template], rules} =
      (File.cwd!() <> "/lib/days/14/" <> input_file)
      |> File.read!()
      |> String.split("\n")
      |> Enum.chunk_by(fn l -> l == "" end)
      |> Enum.reject(fn i -> i == [""] end)
      |> List.to_tuple()

    rule_map = for rule <- rules, into: %{}, do: parse_rule(rule)
    {template, rule_map}
  end

  def parse_rule(rule_string) do
    rule_string
    |> String.split(" -> ")
    |> parse_rule_group()
  end

  def parse_rule_group([pattern, insertion]) do
    {List.to_tuple(String.codepoints(pattern)), insertion}
  end
end
