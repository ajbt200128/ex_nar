defmodule SerializeTest do
  use ExUnit.Case

  test "serialize" do
    result = Serialize.serialize!("./test/target")
    # Handy for debugging
    File.write!("./test/target.nar", result)
    # Read in expected binary
    assert result == File.read!("./test/expected.nar")
  end
end
