defmodule HandlerTest do
  use ExUnit.Case, async: false

  import Mock

  @handler_name :handler_test
  @handler %{handler_test: [queue: "queue/test_handler", callback: "process_test"]}
  @sqs_message ["message test"]
  @receipt_handle [%{receipt_handle: "test_receipt_handle"}]

  # TODO: Improve this test
  test "handler run" do
    with_mocks([
      {Lix.Consumer, [], [get_message: fn _queue -> @sqs_message end]}
    ]) do
      Lix.Handler.Manager.register(@handler)
      Lix.Handler.run(@handler_name)
      assert called(Lix.Consumer.get_message("queue/test_handler"))
    end
  end

  test "confirm processed callback " do
    with_mocks([
      {ExAws.SQS, [], [delete_message: fn _queue, _receipt_handle -> {:ok} end]},
      {ExAws, [], [request!: fn _message -> {:ok} end]}
    ]) do
      Lix.Handler.Manager.register(@handler)
      Lix.Handler.confirm_processed_callback(@handler_name, @receipt_handle)
      Process.sleep(10)
      assert called(ExAws.SQS.delete_message("queue/test_handler", "test_receipt_handle"))
      assert called(ExAws.request!({:ok}))
    end
  end
end
