defmodule Deserialize do
  @moduledoc """
  Deserialize a Nix Archive to a specific output path
  """
  @executable_perms 0o755
  @default_perms 0o644

  def default_perms, do: @default_perms
  def executable_perms, do: @executable_perms

  defp size(n), do: :binary.decode_unsigned(n, :little)

  defp block_size(n) do
    (((n - 1) / 8) |> floor()) + 1
  end

  defp read_block(size, stream) do
    block_size = block_size(size)

    block =
      Enum.take(stream, block_size)
      |> Enum.join("")
      |> :binary.bin_to_list()
      # Remove padding
      |> Enum.slice(0..(size - 1))
      |> :binary.list_to_bin()

    remainder = Enum.drop(stream, block_size)
    {block, remainder}
  end

  defp parse_block({_block, stream}) do
    parse_block(stream)
  end

  defp parse_block(stream) do
    {size, stream} = read_block(8, stream)

    if size == [] do
      {"", stream}
    else
      read_block(size(size), stream)
    end
  end

  defp write(stream, base_path, :regular) do
    {executable_or_contents, stream} = parse_block(stream)

    {executable, {contents, stream}} =
      case executable_or_contents do
        "executable" -> {true, parse_block(stream) |> parse_block() |> parse_block()}
        "contents" -> {false, parse_block(stream)}
      end

    File.write!(base_path, contents)
    perms = if executable, do: @executable_perms, else: @default_perms
    File.chmod!(base_path, perms)
    stream
  end

  defp write(stream, base_path, :symlink) do
    {target, stream} = parse_block(stream) |> parse_block()
    # Remove padding, symlinks don't like null terminators apparently
    File.ln_s!(target, base_path)
    stream
  end

  defp write(stream, base_path, :directory) do
    File.mkdir_p!(base_path)
    write_entries(stream, base_path)
  end

  defp write_entry(stream, base_path) do
    # "entry" |> "(" |> "name" |> name
    {name, stream} = parse_block(stream) |> parse_block() |> parse_block() |> parse_block()

    # "node" |> node
    {_, stream} = parse_block(stream)
    # stream = parse_stream(stream, Path.join(base_path, name))
    stream = write_object(stream, Path.join(base_path, name))

    # drop last parens
    {_, stream} = parse_block(stream)
    stream
  end

  defp write_entries(stream, base_path) do
    {look_ahead, _} = parse_block(stream)

    if look_ahead == "entry" do
      write_entry(stream, base_path) |> write_entries(base_path)
    else
      stream
    end
  end

  defp write_object(stream, base_path) do
    # "(" |> "type" |> type
    {_, stream} = parse_block(stream) |> parse_block()
    {type, stream} = parse_block(stream)

    case type do
      "regular" -> write(stream, base_path, :regular)
      "symlink" -> write(stream, base_path, :symlink)
      "directory" -> write(stream, base_path, :directory)
    end
    # Drop last parens
    |> parse_block()
  end

  defp parse_stream(stream, base_path) do
    case parse_block(stream) do
      {_, stream} = {"nix-archive-1", _} ->
        write_object(stream, base_path) |> parse_stream(base_path)

      {"", _} ->
        :ok

      {_, _} ->
        raise "Contents do not look like NAR"
    end
  end

  @doc """
  Given a path to a Nix Archive `nar` unpack it to `output_path`
  """
  def deserialize!(nar, output_path) when is_binary(nar) and is_binary(output_path) do
    File.read!(nar)
    |> :binary.bin_to_list()
    |> Enum.chunk_every(8)
    |> Enum.map(&:binary.list_to_bin/1)
    |> parse_stream(output_path)
  end
end
