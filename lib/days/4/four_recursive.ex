defmodule AdventOfCode2021.FourRecursive do
  @moduledoc """
  Day 4: Giant Squid
  https://adventofcode.com/2021/day/4
  """

  require AdventOfCode2021.Utils.Inputs

  def one(input) do
    {draws, boards} = parse_input(input)

    play_bingo(draws, boards)
  end

  def play_bingo(draws, boards), do: play_bingo(draws, {:playing, boards})

  def play_bingo(_draws, :won, {winning_draw, winning_board}), do: {winning_draw, winning_board}

  def play_bingo([draw | draws], :playing, boards) do
    {state, data} = mark_boards(draw, boards)
    if state == :won do
      data
    else
      play_bingo(draws, data)
    end
  end

  def mark_boards(draw, boards) do
    for board <- boards, do: mark_board(draw, board)

    marked_boards = Enum.map(boards, &mark_board(draw, &1))

    # todo: if a board is winning, return it here with {:won}
    # otherwise, pass back boards with {:playing}

    if Enum.any?(marked_boards, fn {_board, state} -> state end) do
      {:won, Enum.find(marked_boards, fn {_board, state} -> state end)}
    else
      {:playing, marked_boards}
    end
  end

  def mark_board(draw, board) do
    marked_board = Enum.map(board, &mark_row(draw, &1))

    is_winning =
      Enum.any?(0..(length(marked_board) - 1), fn i ->
        is_winning_row?(Enum.at(board, i)) || is_winning_column?(board, i)
      end)

    {marked_board, is_winning}
  end

  defp mark_row(draw, row) do
    Enum.map(row, fn {value, _} ->
      if(value == draw, do: {value, true}, else: {value, false})
    end)
  end

  defp is_winning_row?(row), do: Enum.reduce(row, true, fn {_, marked}, acc -> acc && marked end)

  defp is_winning_column?(board, index),
    do: Enum.reduce(board, true, fn row, acc -> acc && elem(Enum.at(row, index), 1) end)

  defp parse_input(input) do
    [[draws_string] | board_strings] =
      input
      |> AdventOfCode2021.Utils.Inputs.file_to_stream()
      |> Stream.chunk_by(fn l -> l == "" end)
      |> Stream.reject(fn l -> l == [""] end)
      |> Enum.to_list()

    draws = String.split(draws_string, ",") |> Enum.map(fn s -> {String.to_integer(s), false} end)
    boards = Enum.map(board_strings, &parse_board/1)

    {draws, boards}
  end

  defp parse_board(board_list) do
    Enum.map(board_list, fn row -> Enum.map(String.split(row), &String.to_integer/1) end)
  end
end
