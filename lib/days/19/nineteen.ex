defmodule AdventOfCode2021.Nineteen do
  @moduledoc """
  Day 19: Beacon Scanner
  https://adventofcode.com/2021/day/19
  """

  @type coordinate :: {integer(), integer(), integer()}

  @doc """
  Ideas:
  * set up global frame of reference based on first scanner
  * compare point sets by relative distances
  * check all possible orientations against each other
  * build comprehensive list of known points
  * group point sets? e.g. 1 & 2 match, 3 & 4 match, 5 matches both, use to reconcile all?
  * can we rely on a single matching rotation? some points may match in multiple configurations
  """
  def one(input_file) do
    input_file
    |> parse_input()
    |> Enum.map(&scanner_rotations/1)

    # |> Enum.map(&beacon_relative_positions/1)
  end

  def two(input_file) do
    parse_input(input_file)
  end

  def scanner_rotations(scan) do
    Enum.map(scan, fn coord ->
      {coord, rotations(coord)}
    end)
  end

  def match_count(scan_a, scan_b) do
    for {_coords_a, pos_a} <- scan_a,
        {_coords_b, pos_b} <- scan_b,
        reduce: 0 do
      acc ->
        if pos_a == pos_b, do: acc + 1, else: acc
    end
  end

  @doc """
  Generate a set of distances from other beacons for each beacon in a scan.
  """
  @spec beacon_relative_positions([coordinate]) :: [{coordinate, MapSet.t(coordinate)}]
  def beacon_relative_positions(scan) do
    Enum.map(scan, fn {xa, ya, za} = a ->
      pos =
        for {xb, yb, zb} = b <- scan,
            reduce: MapSet.new() do
          acc ->
            # could accumulate an aggregate distance here in addition to or instead of mapset
            if a == b, do: acc, else: MapSet.put(acc, {xb - xa, yb - ya, zb - za})
        end

      {a, pos}
    end)
  end

  @doc """
  Sum of manhattan distance between point and neighbors
  """
  def relative_distance_sums(scan) do
    for {xa, ya, za} <- scan,
        {xb, yb, zb} <- scan do
      abs(xb - xa) + abs(yb - ya) + abs(zb - za)
    end
  end

  def generate_rotations({x, y, z} = coords) do
    :ok
    # [

    # ]

    # for _i <- 0..1,
    #     _j <- 0..3,
    #     _k <- 0..2
    #     reduce: {[coords], coords} do
    #       acc ->
    #         []
    #     end

    # rot_x()
  end

  def flip(coords, times), do: flip(coords, times, [coords])

  defp flip(_coords, 0, acc), do: acc

  defp flip(coords, times, acc = []) do
    flipped = flip(coords)
    flip(flipped, times - 1, [flipped | acc])
  end

  defp flip({x, y, z}), do: {y, x, -z}

  def rot_x(coords)

  def rot_x({x, y, z}), do: {x, z, -y}

  def rot_z({x, y, z}), do: {y, -x, z}

  def f_rotations({x, y, z}) do
    [
      {x, y, z},

      # +/- 180
      {x, -y, -z},
      {-x, y, -z},
      {-x, -y, z},

      # +/-90x
      {x, -z, y},
      {x, z, -y},

      # +/-90y
      {-z, y, x},
      {z, y, -x},

      # +/-90z
      {y, -x, z},
      {-y, x, z}
    ]
  end

  def f_generate_rotations({x, y, z}) do
    [
      {x, y, z},

      # z rotations (3)
      {y, -x, z},
      {-x, -y, z},
      {-y, x, z},
      # -z rotations (3)
      {x, -y, -z},
      {y, x, -z},
      {-x, y, -z}

      # y rotations (3)
      # -y rotations (3)

      # x rotations (3)
      # -x rotations (3)
    ]
  end

  def parse_input(input_file) do
    "#{File.cwd!()}/lib/days/19/#{input_file}.txt"
    |> File.read!()
    |> String.split("\n")
    # |> Enum.chunk_by(&==("\n"))  # why can't we apply &==?
    |> Enum.chunk_by(fn l -> l == "" end)
    |> Enum.reject(fn l -> l == [""] end)
    |> Enum.map(fn scans ->
      scans
      |> tl()
      |> Enum.map(fn p ->
        p
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple()
      end)
    end)
  end
end
