defmodule AdventOfCode2021.Nineteen do
  @moduledoc """
  Day 19: Beacon Scanner
  https://adventofcode.com/2021/day/19
  """

  @typedoc """
  3d coordinate
  """
  @type coordinate :: {integer(), integer(), integer()}

  @typedoc """
  All orientations of a scan
  """
  @type scan :: [[coordinate()]]

  @typedoc """
  Distances between a coordinate and all other coordinates in a scan
  """
  @type relative_coordinate :: {coordinate(), MapSet[coordinate()]}

  @typedoc """
  All relative coordinates in a scan
  """
  @type relative_scan :: [[relative_coordinate()]]

  @doc """
  Worth noting that this problem got a lot simpler by defining types.
  A lot of this complexity is just fanning out more data from the initial input.
  Specifying what the input and outputs look like make it a lot easier to think about.
  """
  def one(input_file) do
    scans =
      input_file
      |> parse_input()

    scans = Enum.map(scans, &scan_orientations/1)
    relative_scans = Enum.map(scans, &relative_scan_positions/1)

    Enum.reduce(relative_scans, fn scan, known_scan ->
      # @todo: build_beacon_list had the right idea here
      # check for a match, if so, merge the nonmatchers in
      # if not, put it at the end of the list and keep going
    end)

    # build complete list of beacons
    # all_beacons = Enum.reduce(tail_scans, origin_beacons, fn scan_orientations, known_beacons ->
    #   case find_matching_orientation(known_beacons, scan_orientations) do
    #     nil -> :ok
    #   end

    # Enum.reduce_while(scan_orientations, origin_scan, fn coordinates, _ ->
    #   if match_count(origin_scan, coordinates) >= 12 do
    #     {:halt, Enum.uniq(origin_scan ++ coordinates)}
    #   else
    #     {:cont, origin_scan}
    #   end
    # end)

    # end)

    # |> Enum.map(&beacon_relative_positions/1)
  end

  def two(input_file) do
    parse_input(input_file)
  end

  @spec match_count([relative_scan()], [relative_scan()]) :: integer()
  def match_count(scan_a, scan_b) do
    for a <- scan_a,
        b <- scan_b,
        reduce: 0 do
      acc ->
        if a == b, do: acc + 1, else: acc
    end
  end

  @doc """
  Build beacon list from all scans.
  If there's not enough matches, put that scan at the end of the list and continue.
  """

  # def build_beacon_list(known_beacons, []), do: known_beacons

  # def build_beacon_list(known_beacons, [scan | scans]) do
  #   case check_beacon_orientations(known_beacons, scan) do
  #     nil ->
  #       build_beacon_list(known_beacons, Enum.reverse([scan | Enum.reverse(scans)]))
  #     scan_orientation ->
  #       new_beacons = translate_beacons(known_beacons, scan_orientation)
  #       build_beacon_list(new_beacons, scans)
  #   end
  # end

  def check_beacon_orientations(_known_beacons, []), do: nil

  def check_beacon_orientations(known_beacons, [scan_orientation | scan_orientations]) do
    if match_count(known_beacons, scan_orientation) >= 12 do
      scan_orientation
    else
      check_beacon_orientations(known_beacons, scan_orientations)
    end
  end

  # @spec find_matching_orientation([coordinate()], [[coordinate()]]) :: [coordinate()]
  # def find_matching_orientation(known_beacons, []), do: nil
  # def find_matching_orientation(known_beacons, [orientation | scan_orientations]) do

  # end

  @spec relative_scan_positions(scan()) :: relative_scan()
  def relative_scan_positions(scans) do
    for scan <- scans, do: relative_scan_orientation_positions(scan)
  end

  @spec relative_scan_orientation_positions([coordinate()]) :: [relative_coordinate()]
  def relative_scan_orientation_positions(scan) do
    Enum.map(scan, fn i ->
      relative_positions =
        for j <- scan,
            reduce: MapSet.new() do
          acc ->
            # could accumulate an aggregate distance here in addition to or instead of mapset?
            if i == j, do: acc, else: MapSet.put(acc, relative_position(i, j))
        end

      {i, relative_positions}
    end)
  end

  @spec relative_position(coordinate(), coordinate()) :: coordinate()
  def relative_position({xa, ya, za}, {xb, yb, zb}) do
    {xb - xa, yb - ya, zb - za}
  end

  @spec scan_orientations([coordinate()]) :: scan()
  def scan_orientations(scan) do
    scan
    |> Enum.map(&coordinate_orientations_set/1)
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.reverse()
  end

  @spec coordinate_orientations_set(coordinate()) :: [coordinate()]
  def coordinate_orientations_set(coord) do
    coord
    |> flip(2)
    |> Enum.map(fn j ->
      rotate(:x, j, 4)
      |> Enum.map(fn k ->
        rotate(:z, k, 4)
      end)
    end)
    |> List.flatten()
    # todo combine rotations properly
    |> Enum.uniq()
  end

  def flip(coords, times), do: flip(coords, times - 1, [coords])

  defp flip(_coords, 0, acc), do: acc

  defp flip(coords, times, acc) do
    flipped = flip(coords)
    flip(flipped, times - 1, [flipped | acc])
  end

  defp flip({x, y, z}), do: {y, x, -z}

  def rotate(dim, coords, times) do
    rotate(dim, coords, times - 1, [coords])
  end

  defp rotate(_dim, _coords, 0, acc), do: acc

  defp rotate(dim, coords, times, acc) do
    rotated = rotate(dim, coords)
    rotate(dim, rotated, times - 1, [rotated | acc])
  end

  defp rotate(:x, {x, y, z}), do: {x, z, -y}

  defp rotate(:z, {x, y, z}), do: {y, -x, z}

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
