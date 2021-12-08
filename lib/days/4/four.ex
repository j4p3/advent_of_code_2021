defmodule AdventOfCode2021.Four do
  @moduledoc """
  Day 4: Giant Squid
  Clean version
  https://adventofcode.com/2021/day/4
  """

  defmodule Board do
    @moduledoc """
    Using tuples for fast random access over a known size
    """
    empty_grid = Tuple.duplicate(Tuple.duplicate(false, 5), 5)
    defstruct grid: %{}, marks: empty_grid

    def new(grid) when is_map(grid) do
      %Board{grid: grid}
    end

    def mark(board, draw) do
      # super idiomatic pattern match on board, nice
      case board.grid do
        %{^draw => {x, y}} ->
          put_in(board, [Access.key(:marks), Access.elem(y), Access.elem(x)], true)

        %{} ->
          board
      end
    end

    def is_winning?(board) do
      is_winning_row?(board.marks) || is_winning_col?(board.marks)
    end

    def score(board) do
      for {value, {x, y}} <- board.grid,
          elem(elem(board.marks, y), x) == false,
          reduce: 0 do
        acc -> acc + value
      end
    end

    defp is_winning_row?(marks) do
      Enum.any?(0..4, fn row -> elem(marks, row) == {true, true, true, true, true} end)
    end

    defp is_winning_col?(marks) do
      Enum.any?(0..4, fn col ->
        Enum.all?(0..4, fn row -> elem(elem(marks, row), col) end)
      end)
    end
  end

  def one(input) do
    {draws, boards} = parse_input(input)
    {draw, winning_board} = Enum.reduce_while(draws, boards, &play_bingo/2)
    draw * Board.score(winning_board)
  end

  def two(input) do
    {draws, boards} = parse_input(input)
    {draw, losing_board} = Enum.reduce_while(draws, boards, &play_bingo_badly/2)
    # {draw, losing_board}
    draw * Board.score(losing_board)
  end

  def play_bingo(draw, boards) do
    boards = Enum.map(boards, &Board.mark(&1, draw))

    if Enum.any?(boards, &Board.is_winning?/1) do
      {:halt, {draw, Enum.find(boards, &Board.is_winning?/1)}}
    else
      {:cont, boards}
    end
  end

  def play_bingo_badly(draw, boards) do
    boards = Enum.map(boards, &Board.mark(&1, draw))

    case Enum.reject(boards, &Board.is_winning?/1) do
      [] ->
        {:halt, {draw, List.first(boards)}}

      boards ->
        {:cont, boards}
    end
  end

  def parse_input(input) do
    [draw_string | board_strings] =
      (File.cwd!() <> "/lib/days" <> input)
      |> File.read!()
      |> String.split("\n", trim: true)

    boards =
      board_strings
      |> Enum.chunk_every(5)
      |> Enum.map(&parse_board/1)

    {
      Enum.map(String.split(draw_string, ","), &String.to_integer/1),
      boards
    }
  end

  # generate a map of value => {x, y} coords
  def parse_board(board_data) do
    for {row, row_index} <- Enum.with_index(board_data),
        {number, col_index} <- Enum.with_index(String.split(row)),
        into: %{} do
      {String.to_integer(number), {col_index, row_index}}
    end
    |> Board.new()
  end
end
