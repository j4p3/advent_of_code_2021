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

  @typedoc """
  Quick-lookup format of relative positions and the absolute coordinates of the related beacon
  """
  @type relative_beacon_map :: %{MapSet[coordinate()] => coordinate()}

  @doc """
  Note: Nearly there. Not finding matches for all scans, even in sample2.
  Likely orientations still not correct - 2 of 4 scans not matching origin
  even though they're the same points. Flipping going wrong?

  Approach:
  1. Generate all orientations of all scans
  2. Set first orientation of first scan as frame of reference
  3. Store this frame of refererence as k-v [relative_distances => absolute coordinate]
  4. Generate matching k-v of absolute coordinates and their relative distances for each orientation of each other scan
  5. Compare orientations of each scan to find matching orientation
  6. Consolidate absolute coordinates on matching orientation
  """
  def one(input_file) do
    scans =
      input_file
      |> parse_input()

    scan_orientations = Enum.map(scans, &scan_orientations/1)

    known_beacons =
      hd(scans)
      |> relative_scan_orientation_positions()
      |> relative_scan_orientation_to_beacon_map()

    relative_scans = Enum.map(tl(scan_orientations), &relative_scan_positions/1)

    beacons = build_beacon_map(known_beacons, relative_scans)

    map_size(beacons)
  end

  def two(input_file) do
    parse_input(input_file)
  end

  ################################################################################################
  # Matching & consolidating scans
  #

  @doc """
  Build beacon list from all scans.
  If there's not enough matches, put that scan at the end of the list and continue.
  """
  @spec build_beacon_map(relative_beacon_map(), [relative_scan()]) :: relative_beacon_map()
  def build_beacon_map(known_beacons, []), do: known_beacons

  def build_beacon_map(known_beacons, [scan | scans]) do
    IO.puts("checking scan")
    IO.inspect(scan)
    case get_matching_orientation(known_beacons, scan) do
      nil ->
        build_beacon_map(known_beacons, Enum.reverse([scan | Enum.reverse(scans)]))

      scan_orientation ->
        # @todo: breaks here
        known_beacons = consolidate_beacons(known_beacons, scan_orientation)
        build_beacon_map(known_beacons, scans)
    end
  end

  @doc """
  Find the orientation of a scan with sufficient matches in the known set.
  If no orientations, return nil.
  """
  @spec get_matching_orientation(relative_beacon_map(), relative_scan()) ::
          [relative_coordinate()] | nil
  def get_matching_orientation(_known_beacons, []), do: nil

  def get_matching_orientation(known_beacons, [scan_orientation | scan_orientations]) do
    if match_count(known_beacons, scan_orientation) >= 6 do
      scan_orientation
    else
      get_matching_orientation(known_beacons, scan_orientations)
    end
  end

  @doc """
  Number points in a scan orientation whose relative position matches a known point.
  """
  @spec match_count(relative_beacon_map(), [relative_coordinate()]) :: integer()
  def match_count(known_beacons, scan_orientation) do
    for {_coord, relative_positions} <- scan_orientation,
        reduce: 0 do
      acc ->
        if Map.has_key?(known_beacons, relative_positions), do: acc + 1, else: acc
    end
  end

  @spec consolidate_beacons(relative_beacon_map(), [relative_coordinate()]) ::
          relative_beacon_map()
  def consolidate_beacons(known_beacons, scan) do
    {origin_beacon, new_beacon} = find_matching_beacon_pair(known_beacons, scan)
    translation = relative_position(new_beacon, origin_beacon)

    scan
    |> Enum.each(fn {coordinate, relative_positions} ->
      {translate_coordinate(coordinate, translation), relative_positions}
      Map.put(known_beacons, relative_positions, translate_coordinate(coordinate, translation))
    end)

    known_beacons
  end

  @doc """
  Find the pair of beacon coordinates whose relative distance from other beacons match
  """
  @spec find_matching_beacon_pair(relative_beacon_map(), [relative_coordinate()]) ::
          {relative_coordinate(), relative_coordinate()}
  def find_matching_beacon_pair(known_beacons, [{new_beacon_coord, relative_positions} | beacons]) do
    if Map.has_key?(known_beacons, relative_positions) do
      {Map.get(known_beacons, relative_positions), new_beacon_coord}
    else
      find_matching_beacon_pair(known_beacons, beacons)
    end
  end

  ################################################################################################
  # Building data structures for search
  #

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
            # what other signatures could identify a point besides relative distances?
            if i == j, do: acc, else: MapSet.put(acc, relative_position(i, j))
        end

      {i, relative_positions}
    end)
  end

  @spec relative_position(coordinate(), coordinate()) :: coordinate()
  def relative_position({xa, ya, za}, {xb, yb, zb}), do: {xb - xa, yb - ya, zb - za}

  @spec translate_coordinate(coordinate(), coordinate()) :: coordinate()
  def translate_coordinate({x, y, z}, {tx, ty, tz}), do: {x + tx, y + ty, z + tz}

  @spec scan_orientations([coordinate()]) :: scan()
  def scan_orientations(scan) do
    scan
    |> Enum.map(&coordinate_orientations_set/1)
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
  end

  @spec coordinate_orientations_set(coordinate()) :: [coordinate()]
  def coordinate_orientations_set(coord) do
    coord
    |> rotate(:x, 4)
    |> Enum.flat_map(&rotate(&1, :z, 3))
    |> Enum.flat_map(&flip(&1, 2))
    |> Enum.reverse()
  end

  @spec relative_scan_orientation_to_beacon_map([relative_coordinate()]) :: relative_beacon_map()
  def relative_scan_orientation_to_beacon_map(relative_coordinates) do
    Map.new(relative_coordinates, fn {coordinate, relative_positions} ->
      {relative_positions, coordinate}
    end)
  end

  ################################################################################################
  # Rotation + transformation
  #

  @spec flip([coordinate()], integer()) :: [coordinate()]
  def flip(coords, times), do: flip(coords, times - 1, [coords])

  defp flip(_coords, 0, acc), do: acc

  defp flip(coords, times, acc) do
    flipped = flip(coords)
    flip(flipped, times - 1, [flipped | acc])
  end

  defp flip({x, y, z}), do: {y, x, -z}

  @spec rotate([coordinate()], :x | :z, integer()) :: [coordinate()]
  def rotate(coords, dim, times) do
    rotate(coords, dim, times - 1, [coords])
  end

  defp rotate(_coords, _dim, 0, acc), do: acc

  defp rotate(coords, dim, times, acc) do
    rotated = rotate(dim, coords)
    rotate(rotated, dim, times - 1, [rotated | acc])
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
