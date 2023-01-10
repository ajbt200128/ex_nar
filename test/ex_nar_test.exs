defmodule ExNarTest do
  use ExUnit.Case

  @output_path "/tmp/ex_nar"

  setup_all do
    File.rm_rf!(@output_path)
    File.mkdir_p!(@output_path)
  end

  test "serialize" do
    result = ExNar.serialize!("./test/target")
    # Handy for debugging
    File.write!("./test/target.nar", result)
    # Read in expected binary
    assert result == File.read!("./test/expected.nar")
  end

  test "serialize bytestream" do
    foo = "foo\n"
    assert ExNar.serialize!(foo, [:bytestream]) == File.read!("./test/foo.nar")
  end

  test "deserialize regular" do
    import Bitwise

    ExNar.deserialize!(File.read!("test/foo.nar"), @output_path <> "/foo")
    assert File.exists?(@output_path <> "/foo")
    assert File.lstat!(@output_path <> "/foo").type == :regular

    assert (File.lstat!(@output_path <> "/foo").mode &&& ExNar.default_perms()) ==
             ExNar.default_perms()

    assert File.read!("test/target/foo") == File.read!(@output_path <> "/foo")

    ExNar.deserialize!(File.read!("test/executable.nar"), @output_path <> "/executable")
    assert File.exists?(@output_path <> "/executable")
    assert File.lstat!(@output_path <> "/executable").type == :regular

    assert (File.lstat!(@output_path <> "/executable").mode &&& ExNar.executable_perms()) ==
             ExNar.executable_perms()

    assert File.read!("test/target/executable") == File.read!(@output_path <> "/executable")
  end

  test "deserialize symlink" do
    ExNar.deserialize!(File.read!("test/foobar_ln.nar"), @output_path <> "/foobar_ln")
    assert File.lstat!(@output_path <> "/foobar_ln").type == :symlink
    assert File.read_link!(@output_path <> "/foobar_ln") == "sub_dir/foobar.png"
  end

  test "deserialize identity" do
    # Helpful with debugging
    ExNar.deserialize!(File.read!("test/expected.nar"), @output_path <> "/expected")
    s = ExNar.serialize!(@output_path <> "/expected")
    File.write!(@output_path <> "/expected.nar", s)
    assert s == File.read!("test/expected.nar")
  end
end
