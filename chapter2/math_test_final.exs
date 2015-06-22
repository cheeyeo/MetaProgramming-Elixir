defmodule MathTest do
  use Assertion

  test "integers can be added and subtracted" do
    assert 2 + 3 > 4
    assert 5 - 5 > 10
  end

  test "integers can be multiplied and divided" do
    assert 5 * 5 == 25
    assert 10 / 2 == 5.0
  end

  test "assert true" do
    assert false, "false otherwise"
  end

  # fails only if parameter is true
  test "refute test" do
    refute 1 > 0
  end
end
