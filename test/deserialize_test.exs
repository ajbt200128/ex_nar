defmodule DeserializeTest do
  use ExUnit.Case

  @output_path "/tmp/ex_nar"

  setup_all do
    File.rm_rf!(@output_path)
    File.mkdir_p!(@output_path)
  end

  test "deserialize regular" do
    import Bitwise

    Deserialize.deserialize!("test/foo.nar", @output_path <> "/foo")
    assert File.exists?(@output_path <> "/foo")
    assert File.lstat!(@output_path <> "/foo").type == :regular

    assert (File.lstat!(@output_path <> "/foo").mode &&& Deserialize.default_perms()) ==
             Deserialize.default_perms()

    assert File.read!("test/target/foo") == File.read!(@output_path <> "/foo")

    Deserialize.deserialize!("test/executable.nar", @output_path <> "/executable")
    assert File.exists?(@output_path <> "/executable")
    assert File.lstat!(@output_path <> "/executable").type == :regular

    assert (File.lstat!(@output_path <> "/executable").mode &&& Deserialize.executable_perms()) ==
             Deserialize.executable_perms()

    assert File.read!("test/target/executable") == File.read!(@output_path <> "/executable")
  end

  test "deserialize symlink" do
    Deserialize.deserialize!("test/foobar_ln.nar", @output_path <> "/foobar_ln")
    assert File.lstat!(@output_path <> "/foobar_ln").type == :symlink
    assert File.read_link!(@output_path <> "/foobar_ln") == "sub_dir/foobar.png"
  end

  test "deserialize identity" do
    # Helpful with debugging
    Deserialize.deserialize!("test/expected.nar", @output_path <> "/expected")
    s = Serialize.serialize!(@output_path <> "/expected")
    File.write!(@output_path <> "/expected.nar", s)
    assert s == File.read!("test/expected.nar")
  end
end
