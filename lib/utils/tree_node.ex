defmodule AdventOfCode2021.Utils.TreeNode do
  @moduledoc """
  Binary tree node
  """

  defstruct parent: nil, left: nil, right: nil, value: nil

  def new([left, right]) do
    new(nil, [left, right])
  end

  def new(parent, [left, right]) do
    %__MODULE__{
      value: nil,
      parent: parent
    }
    |> add_child(:left, left)
    |> add_child(:right, left)
  end

  def new(nil), do: nil

  def new(value), do: %__MODULE__{value: value, left: nil, right: nil}

  def add_child(%__MODULE__{} = node, :left, value) do
    %__MODULE__{
      node |
      left: new(node, value)
    }
  end

  def add_child(%__MODULE__{} = node, :right, value) do
    %__MODULE__{
      node |
      right: new(node, value)
    }
  end

  def update_value(%__MODULE__{} = node, new_value) do
    %__MODULE__{node | value: new_value}
  end
end
