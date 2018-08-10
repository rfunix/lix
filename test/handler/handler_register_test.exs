defmodule HandlerRegisterTest do
  use ExUnit.Case, async: false

  @handler %{handler_test: [queue: "queue/test_handler", callback: "process_test"]}

  test "register new handler" do
    Lix.Handler.Manager.register(@handler)
    assert {:ok, @handler} == Lix.Handler.Manager.get_registred_handlers()
  end
end
