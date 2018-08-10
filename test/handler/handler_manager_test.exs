defmodule HandlerManagerTest do
  use ExUnit.Case, async: true

  @handler_name :handler_test
  @invalid_handler_name :invalid_handler_test
  @handler %{handler_test: [queue: "queue/test_handler", callback: "process_test"]}

  test "register new handler" do
    Lix.Handler.Manager.register(@handler)
    assert {:ok, @handler} == Lix.Handler.Manager.get_registred_handlers()
  end

  test "get registred handlers" do
    Lix.Handler.Manager.register(@handler)
    {:ok, registred_handlers} = Lix.Handler.Manager.get_registred_handlers()
    assert registred_handlers == @handler
  end

  test "get handler by name" do
    Lix.Handler.Manager.register(@handler)
    {:ok, handler} = Lix.Handler.Manager.get_handler_by_name(@handler_name)
    assert handler == @handler.handler_test
  end

  test "handler does not exists" do
    expected = "Handler does not exists: #{@invalid_handler_name}"
    {:error, message} = Lix.Handler.Manager.get_handler_by_name(@invalid_handler_name)
    assert message == expected
  end
end
