defmodule AdventOfCode2021.Utils.Tree do
  @moduledoc """
  Binary tree
  """

  alias AdventOfCode2021.Utils.TreeNode

  defstruct nodes: %{}, root: %TreeNode{}

  def new() do
    %__MODULE__{}
  end

  def from_root(root_node) do
    %__MODULE__{root: root_node}
  end

  def from_nested_list(list) do
    %__MODULE__{
      nodes: process_list(list)
    }
  end

  def process_list(list) do
    list
  end
end
