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

  @doc """
  Convert a string of integer characters ("1", "45") to a list of individual integers
  """
  @spec to_integer_list(String.t()) :: [integer()]
  def to_integer_list(input_string) do
    input_string
    |> String.codepoints()
    |> Enum.map(fn i -> String.to_integer(i) end)
  end

  def file_by_line(input_filepath) do
      (File.cwd!() <> input_filepath)
      |> File.read!()
      |> String.split("\n")
  end
end
