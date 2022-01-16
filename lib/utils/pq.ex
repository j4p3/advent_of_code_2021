defmodule AdventOfCode2021.Utils.PQ do
  @moduledoc """
  Minimum priority queue implementation on Erlang gb_trees
  """

  defstruct tree: :gb_trees.empty()

  @doc """
  Create a new PriorityQueue.
  """
  @spec new :: %__MODULE__{tree: :gb_trees.tree()}
  def new(), do: %__MODULE__{}

  @doc """
  Get the current minvalue from a PriorityQueue and the updated PriorityQueue.
  """
  @spec pop(%__MODULE__{}) :: {any, %__MODULE__{}}
  def pop(queue) do
    {el, _priority, new_tree} = :gb_trees.take_smallest(queue.tree)
    {el, %__MODULE__{tree: new_tree}}
  end

  @doc """
  Return a new PriorityQueue with the inserted value.
  """
  @spec put(%__MODULE__{}, any, integer()) :: %__MODULE__{}
  def put(queue, el, priority) do
    new_tree = :gb_trees.enter(el, priority, queue.tree)
    %__MODULE__{tree: new_tree}
  end
end
