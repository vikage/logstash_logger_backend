defmodule LogstashLoggerBackendTest do
  use ExUnit.Case
  doctest LogstashLoggerBackend

  test "greets the world" do
    assert LogstashLoggerBackend.hello() == :world
  end
end
