defmodule HandlerTest do
  use ExUnit.Case, async: true

  @handler %{handler_item: [queue: "queue/test_handler", callback: "process_test"]}

  test "register new handler" do
    Lix.Handler.register(@handler)
    assert {:ok, @handler} == Lix.Handler.get_registred_handlers()
  end

end
