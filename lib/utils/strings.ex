defmodule AdventOfCode2021.Utils.Strings do
  @doc """
  Perform a frequency count on a string.
  """
  @spec frequency_count(binary) :: %{binary() => integer()}
  def frequency_count(input), do: frequency_count(%{}, input)

  defp frequency_count(frequencies, ""), do: frequencies

  defp frequency_count(frequencies, <<c::binary-size(1), remaining::binary>>) do
    frequency_count(Map.update(frequencies, c, 1, fn ex -> ex + 1 end), remaining)
  end

  @doc """
  Difference between greatest and least values in a map.
  """
  @spec frequency_diff(%{any() => integer()}) :: integer()
  def frequency_diff(input) do
    values = input
    |> Map.to_list()
    |> Enum.map(&elem(&1, 1))

    Enum.max(values) - Enum.min(values)
  end
end
