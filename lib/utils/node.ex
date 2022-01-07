defmodule AdventOfCode2021.Utils.Node do
  defstruct type: nil, value: nil, children: []

  def new("start") do
    %__MODULE__{type: :start, value: "start"}
  end

  def new("end") do
    %__MODULE__{type: :end, value: "end"}
  end

  def new(value) do
    type = if value == String.upcase(value), do: :large, else: :small
    %__MODULE__{type: type, value: value}
  end

  def add_child(node, child) do
    %__MODULE__{node | children: [child.value | node.children]}
  end
end
