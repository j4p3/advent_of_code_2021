defmodule AdventOfCode2021.Utils.Inputs do
  @spec file_to_stream(String.t()) :: %Stream{}
  def file_to_stream(filepath) do
    File.stream!(File.cwd!() <> "/lib/days/" <> filepath)
    |> Stream.map(&String.trim/1)
  end

  @spec file_to_integer_stream(String.t()) :: %Stream{}
  def file_to_integer_stream(filepath) do
    file_to_stream(filepath)
    |> Stream.map(&String.to_integer/1)
  end
end
