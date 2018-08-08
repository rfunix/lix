defmodule HandlerTest do
  use ExUnit.Case, async: false

  import Mock

  @handler_name :handler_test
  @handler %{handler_test: [queue: "queue/test_handler", callback: "process_test"]}
  @sqs_message ["message test"]
  @receipt_handle [%{receipt_handle: "test_receipt_handle"}]

  setup do
    handler = start_supervised!(Lix.Handler)
    %{handler: handler}
  end

  test "register new handler" do
    Lix.Handler.register(@handler)
    assert {:ok, @handler} == Lix.Handler.get_registred_handlers()
  end

  # TODO: Improve this test
  test "handler run" do
    with_mocks([
      {Lix.Consumer, [], [get_message: fn _queue -> @sqs_message end]}
    ]) do
      Lix.Handler.register(@handler)
      Lix.Handler.run(@handler_name)
      assert called(Lix.Consumer.get_message("queue/test_handler"))
    end
  end

  test "confirm processed callback " do
    with_mocks([
      {Lix.Consumer, [], [delete_message: fn _queue, _receipt_handle -> {:ok} end]}
    ]) do
      Lix.Handler.register(@handler)
      Lix.Handler.confirm_processed_callback(@handler_name, @receipt_handle)
      Process.sleep(1)
      assert called(Lix.Consumer.delete_message("queue/test_handler", "test_receipt_handle"))
    end
  end
end
