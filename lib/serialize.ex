defmodule Serialize do
  @moduledoc """
  Serialize a given path (FSO) to a Nix Archive
  """
  import Bitwise

  defp executable?(%{mode: mode}), do: (mode &&& 0o111) != 0

  defp serialize_entry(fso) do
    type = File.lstat!(fso).type
    name = Path.basename(fso)
    ["entry", "(", "name", name, "node", serialize_p(fso, type), ")"]
  end

  defp serialize_p_p(fso, :regular) do
    executable = executable?(File.lstat!(fso))
    executable = if executable, do: ["executable", ""], else: []
    ["regular", executable, "contents", File.read!(fso)]
  end

  defp serialize_p_p(fso, :symlink) do
    ["symlink", "target", File.read_link!(fso)]
  end

  defp serialize_p_p(fso, :directory) do
    sorted_entries = File.ls!(fso) |> Enum.sort()
    ["directory", Enum.map(sorted_entries, &serialize_entry(Path.join(fso, &1)))]
  end

  defp serialize_p(fso, type) do
    ["(", "type", serialize_p_p(fso, type), ")"]
  end

  # Pads a byte sequence `s` with 0s to a multiple of 8 bytes
  defp pad(s) do
    pad = 8 - rem(byte_size(s), 8)
    if pad == 8, do: s, else: s <> String.duplicate(<<0>>, pad)
  end

  # The 64 bit little endian representation of the number `n`
  defp serialize_int(n) do
    <<n::little-integer-size(64)>>
  end

  # Pads and serializes a string `s` as a 64 bit little endian length followed by the string
  defp string(s) do
    size = byte_size(s)
    s = pad(s)
    serialize_int(size) <> s
  end

  @doc """
  Serializes and archives a given path `fso`, returning a binary
  """
  def serialize!(fso) when is_binary(fso) do
    type = File.lstat!(fso).type
    data = ["nix-archive-1", serialize_p(fso, type)] |> List.flatten()
    # join bytes together
    Enum.map_join(data, &string/1)
  end
end
