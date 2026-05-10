defmodule AstroBotTest do
  use ExUnit.Case
  doctest AstroBot

  test "greets the world" do
    assert AstroBot.hello() == :world
  end
end
