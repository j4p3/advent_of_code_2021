defmodule AdventOfCode2021.Sixteen do
  @moduledoc """
  Day 16: Packet Decoder
  https://adventofcode.com/2021/day/16

  Parse bytecode, build an AST, and execute it.
  """

  defmodule Packet do
    @operators %{
      0 => &Enum.sum/1,
      1 => &Enum.product/1,
      2 => &Enum.min/1,
      3 => &Enum.max/1,
      5 => &AdventOfCode2021.Sixteen.gt/2,
      6 => &AdventOfCode2021.Sixteen.lt/2,
      7 => &AdventOfCode2021.Sixteen.equality/2
    }
    @doc """
    Create a new, single top-level packet from a hex string.
    """
    def new(input_string) do
      packet = input_string
      |> Base.decode16!()
      |> decode()

      case packet do
        {_rem, packet} -> packet # only one top-level packet
        packet -> packet
      end
    end

    def decode(bitstring), do: decode(bitstring, [])

    # leftover garbage bits
    def decode("", packets), do: packets
    def decode(<<_::1>>, packets), do: packets
    def decode(<<_::2>>, packets), do: packets
    def decode(<<_::3>>, packets), do: packets

    def decode(<<version::3, body::bits>>, packets) do
      decode_type(body, [%{version: version, bit_size: 3} | packets])
    end

    ##
    # Types

    # garbage bits
    defp decode_type(<<_::1>>, [_packet | packets]), do: packets
    defp decode_type(<<_::2>>, [_packet | packets]), do: packets
    defp decode_type(<<_::3>>, [_packet | packets]), do: packets

    defp decode_type(<<4::3, body::bits>>, [packet | packets]) do
      packet =
        packet
        |> Map.put(:type, 4)
        |> increment_bit_size(3)

      decode_literal(body, [packet | packets])
    end

    # garbage bits
    defp decode_type(<<_::4>>, [_packet | packets]), do: packets

    # by length
    defp decode_type(
           <<type::3, 0::1, packets_size::15, payload::size(packets_size)-bits, rest::bits>>,
           [packet | packets]
         ) do
      packet = handle_operator_data(packet, type, 0)

      subpackets = decode_operator(:length, packets_size, payload, [])

      {rest, [handle_operator_subpackets_data(packet, subpackets) | packets]}
    end

    # by count
    defp decode_type(<<type::3, 1::1, packets_count::11, payload::bits>>, [packet | packets]) do
      packet = handle_operator_data(packet, type, 1)

      case decode_operator(:count, packets_count, payload, []) do
        {rest, subpackets} ->
          {rest, [handle_operator_subpackets_data(packet, subpackets) | packets]}

        subpackets ->
          [handle_operator_subpackets_data(packet, subpackets) | packets]
      end
    end

    # garbage bits
    defp decode_type(<<_a::3, _b::1, _c::bits>>, [_packet | packets]), do: packets

    defp handle_operator_data(packet, type, length_type_id) do
      packet
      |> Map.put(:type, type)
      |> Map.put(:length_type_id, length_type_id)
      |> Map.put(:operator, Map.get(@operators, type))
    end

    defp handle_operator_subpackets_data(packet, subpackets) do
      bit_increment =
        case Map.get(packet, :length_type_id) do
          0 -> 19
          1 -> 15
        end

      packet
      |> Map.put(:subpackets, subpackets)
      |> increment_bit_size(bit_increment + packets_bit_size(subpackets))
    end

    defp packets_bit_size(subpackets) do
      Enum.reduce(subpackets, 0, fn s, acc -> acc + Map.get(s, :bit_size) end)
    end

    ##
    # Operators

    # base case: no more payload to analyze / garbage bits
    def decode_operator(_mode, _param, "", packets), do: packets

    # base case: finished evaluating packets, return accumulated packets & dump garbage bits
    def decode_operator(:length, 0, _payload, packets), do: packets

    # general case: still evaluating packets in this operator, continue recursing
    def decode_operator(:length, length, payload, packets) do
      case Packet.decode(payload, []) do
        {rest, subpackets} ->
          remaining_bit_size =
            length - Enum.reduce(subpackets, 0, fn s, acc -> acc + Map.get(s, :bit_size) end)

          decode_operator(:length, remaining_bit_size, rest, packets ++ subpackets)

        subpackets ->
          packets ++ subpackets
      end
    end

    # base case: finished evaluating packets, return remainder & accumulated packets
    def decode_operator(:count, 0, payload, packets) do
      {payload, packets}
    end

    # general case: still evaluating packets in this operator, continue recursing
    def decode_operator(:count, count, payload, packets) do
      case Packet.decode(payload, []) do
        {rest, subpackets} ->
          decode_operator(:count, count - length(subpackets), rest, packets ++ subpackets)

        subpackets ->
          packets ++ subpackets
      end
    end

    ##
    # Literals

    # entry case: start accumulating bits
    defp decode_literal(payload, packets), do: decode_literal(payload, "", packets)

    # general case: continue accumulating bits
    defp decode_literal(<<1::1, chunk::4, rest::bits>>, acc, packets) do
      decode_literal(rest, <<acc::bits, chunk::4>>, packets)
    end

    # base case: remainder, new packet list
    defp decode_literal(<<0::1, chunk::4, rest::bits>>, acc, [packet | packets]) do
      literal = <<acc::bits, chunk::4>>

      packet =
        Map.merge(packet, %{
          body: AdventOfCode2021.Sixteen.bitstring_to_decimal(literal)
        })
        |> increment_bit_size(div(bit_size(literal), 4) * 5)

      {rest, Enum.reverse([packet | packets])}
    end

    defp increment_bit_size(packet, amount) do
      Map.update(packet, :bit_size, amount, &(&1 + amount))
    end
  end

  def one(input) do
    input
    |> Packet.new()
    |> traverse()
    |> Enum.sum()
  end

  def two(input) do
    input
    |> Packet.new()
    |> evaluate()
  end

  def test_inputs() do
    [
      "D2FE28",
      "38006F45291200",
      "EE00D40C823060",
      "8A004A801A8002F478",
      "620080001611562C8802118E34",
      "C0015000016115A2E0802F182340",
      "A0016C880162017C3686B18A3D4780",
      "C200B40A82",
      "04005AC33890",
      "880086C3E88112",
      "CE00C43D881120",
      "D8005AC2A8F0",
      "F600BC2D8F",
      "9C005AC2F8F0",
      "9C0141080250320F1802104A08"
    ]
    |> Enum.map(fn i ->

      {i,
       Packet.new(i)
       |> evaluate()}
    end)
  end

  # entry case
  def evaluate([packet]), do: evaluate(packet)

  # general case: apply two-argument operator
  def evaluate(%{type: type, operator: operator} = packet) when type > 4 do
    apply(operator, Enum.map(Map.get(packet, :subpackets), &evaluate/1))
  end

  # general case: apply operator
  def evaluate(%{operator: operator} = packet) do
    apply(operator, [Enum.map(Map.get(packet, :subpackets), &evaluate/1)])
  end

  # base case: literal packet
  def evaluate(packet), do: Map.get(packet, :body)

  # entry case
  def traverse(packet_list) when is_list(packet_list), do: traverse(packet_list, [])
  def traverse(packet), do: traverse([packet], [])

  # base case
  def traverse([], visited), do: visited

  # general case: continue visiting subpackets
  def traverse([current_node | to_visit], visited) do
    subpackets = Map.get(current_node, :subpackets, [])
    traverse(to_visit ++ subpackets, [Map.get(current_node, :version) | visited])
  end

  def bitlist_to_list_of_bits(bitlist) do
    for <<bit::1 <- bitlist>>, do: bit
  end

  def bitstring_to_decimal(bs) when is_integer(bs), do: bs

  def bitstring_to_decimal(bs) when is_bitstring(bs) do
    bs
    |> pad_leading_zeroes()
    |> binary_to_decimal()
  end

  def binary_to_decimal(bit_list) when is_list(bit_list) do
    for {bit, power} <- Enum.with_index(Enum.reverse(bit_list)), reduce: 0 do
      total -> total + bit * 2 ** power
    end
  end

  def binary_to_decimal(bin) when is_binary(bin), do: :binary.decode_unsigned(bin)

  def pad_leading_zeroes(input) when is_binary(input), do: input

  def pad_leading_zeroes(input) when is_bitstring(input) do
    padding = 8 - rem(bit_size(input), 8)
    <<0::size(padding), input::bitstring>>
  end

  def gt(a, b), do: if(a > b, do: 1, else: 0)

  def lt(a, b), do: if(a < b, do: 1, else: 0)

  def equality(a, b), do: if(a == b, do: 1, else: 0)
end
