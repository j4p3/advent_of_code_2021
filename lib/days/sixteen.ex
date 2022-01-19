defmodule AdventOfCode2021.Sixteen do
  @moduledoc """
  Day 16: Packet Decoder
  https://adventofcode.com/2021/day/16
  """

  defmodule Packet do
    @doc """
    Create a new packet, peeling version + type from header bits.
    """
    # Need to specific body::bits because bitstring will default to bytes,
    # and remaining bits in body probably aren't divisible by 4
    def new(input_string) do
      input_string
      |> Base.decode16!()
      |> decode()
    end

    def decode(bitstring), do: decode(bitstring, [])

    # leftover garbage bits
    def decode("", packets), do: packets
    def decode(<<_::3, _::0>>, packets), do: packets

    def decode(<<version::3, body::bits>>, packets) do
      case decode_type(body, [%{version: version, bit_size: 3} | packets]) do
        {rem, new_packets} -> decode(rem, new_packets)
        new_packets -> new_packets
      end
    end

    # leftover garbage bits
    def decode(_, [_packet | packets]), do: packets

    ##
    # Types

    defp decode_type(<<4::3, body::bits>>, [packet | packets]) do
      packet =
        packet
        |> Map.put(:type, 4)
        |> increment_bit_size(3)

      decode_literal(body, [packet | packets])
    end

    # by length
    defp decode_type(
           <<type::3, 0::1, packets_size::15, payload::size(packets_size)-bits, rest::bits>>,
           [packet | packets]
         ) do
      packet =
        packet
        |> Map.put(:type, type)
        |> Map.put(:length_type_id, 0)
        |> Map.put(:should_contain_bits, packets_size)

      subpackets = decode_operator(:length, packets_size, payload, [])

      {rest, [process_subpackets(packet, subpackets) | packets]}
    end

    # by count
    defp decode_type(<<type::3, 1::1, packets_count::11, payload::bits>>, [packet | packets]) do
      packet =
        packet
        |> Map.put(:type, type)
        |> Map.put(:length_type_id, 1)

      case decode_operator(:count, packets_count, payload, []) do
        {rest, subpackets} ->
          {rest, [process_subpackets(packet, subpackets) | packets]}

        subpackets ->
          [process_subpackets(packet, subpackets) | packets]
      end
    end

    # leftover garbage bits
    defp decode_type(_, [_packet | packets]), do: packets

    defp process_subpackets(packet, subpackets) do
      subpackets_bit_size =
        Enum.reduce(subpackets, 0, fn s, acc -> acc + Map.get(s, :bit_size) end)

      bit_increment =
        case Map.get(packet, :length_type_id) do
          0 -> 19
          1 -> 15
        end

      packet
      |> Map.put(:subpackets, subpackets)
      |> increment_bit_size(bit_increment + subpackets_bit_size)
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

          decode_operator(:length, remaining_bit_size, rest, subpackets ++ packets)

        subpackets ->
          subpackets ++ packets
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
          decode_operator(:count, count - 1, rest, subpackets ++ packets)

        subpackets ->
          subpackets ++ packets
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

      {rest, [packet | packets]}
    end

    defp increment_bit_size(packet, amount) do
      Map.update(packet, :bit_size, amount, &(&1 + amount))
    end
  end

  def one(input) do
    Packet.new(input)
    |> traverse()
    |> Enum.sum()
  end

  def two(input_file) do
  end

  # entry case
  def traverse(packet_list), do: traverse(packet_list, [])

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
end
