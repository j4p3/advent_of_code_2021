defmodule AdventOfCode2021.Fourteen do
  @moduledoc """
  Day 14: Extended Polymerization
  https://adventofcode.com/2021/day/14
  """

  def one(input_file) do
    {template, rules} = parse_input(input_file)

    Enum.reduce(1..10, template, fn _i, acc ->
      process_template(rules, acc)
    end)
    |> AdventOfCode2021.Utils.Strings.frequency_count()
    |> AdventOfCode2021.Utils.Strings.frequency_diff()
  end

  @doc """
  Ideas:
  * DP - store chunk transformations n steps ahead, and apply those leapfrog transformations instead of single-step
  * Vectors - dump template into Nx vector & apply transformations to it
  * Computationally - calculate what pair XX will iterate to at step N based on rules
  * Cheaply - keep a count of each pair, adjust pairs with each step, forget ordering

  Key insight here being, for an output which requires impractical resources to operate on,
  operate instead on some relevant metadata about or abstraction of it.
  """
  def two(input_file) do
    {template, rules} = parse_input(input_file)

    # update frequency count from step to step
    counts = step_pair_counts(template, rules, 40)

    # take first letter of each pair & sum
    totals =
      Enum.reduce(counts, %{}, fn {{a, _b}, count}, acc ->
        Map.update(acc, a, count, fn ex -> ex + count end)
      end)

    # add back last letter
    template_length = byte_size(template) - 1
    <<_first::binary-size(template_length), last_letter::binary-size(1)>> = template

    Map.update(totals, last_letter, 1, fn ex -> ex + 1 end)
    |> AdventOfCode2021.Utils.Strings.frequency_diff()
  end

  # public interface
  def step_pair_counts(template, rules, limit) do
    counts =
      template
      |> chunk()
      |> Enum.frequencies()

    step_pair_counts(0, limit, counts, rules)
  end

  # base case
  def step_pair_counts(step, limit, counts, _rules) when step == limit, do: counts

  # general case
  def step_pair_counts(step, limit, counts, rules) do
    new_counts =
      Enum.flat_map(counts, fn {{a, b} = pair, count} ->
        [{{a, Map.get(rules, pair)}, count}, {{Map.get(rules, pair), b}, count}]
      end)
      |> Enum.reduce(%{}, fn {pair, count}, acc ->
        Map.update(acc, pair, count, fn ex -> ex + count end)
      end)

    step_pair_counts(step + 1, limit, new_counts, rules)
  end

  # public interface
  def process_template(map, template) do
    process_template(map, "", template)
  end

  # general case
  def process_template(map, processed, <<a::binary-size(1), b::binary-size(1), rest::binary>>) do
    process_template(map, processed <> a <> Map.get(map, {a, b}), b <> rest)
  end

  # base case
  def process_template(_map, processed, <<last::binary-size(1)>>), do: processed <> last

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
