defmodule LixTest do
  use ExUnit.Case
  doctest Lix

  test "greets the world" do
    assert Lix.hello() == :world
  end
end
