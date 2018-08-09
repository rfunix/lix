defmodule HandlerHelpersTest do
  use ExUnit.Case, async: false
  import Mock
  import Lix.Handler.Helpers

  @handler_name :handler_test
  @handler %{handler_test: [queue: "queue/test_handler", callback: "process_test"]}
  @receipt_handle [%{receipt_handle: "test_receipt_handle"}]
  @sqs_message %{body: %{messages: ["message test"]}}

  test "delete message" do
    with_mocks([
      {ExAws.SQS, [], [delete_message: fn _queue, _receipt_handle -> {:ok} end]},
      {ExAws, [], [request!: fn _message -> {:ok} end]}
    ]) do
      delete_message(@handler.handler_test, @receipt_handle)
      Process.sleep(1)
      assert called(ExAws.SQS.delete_message("queue/test_handler", "test_receipt_handle"))
      assert called(ExAws.request!({:ok}))
    end
  end

  test "execute handler callback" do
    with_mocks([
      {GenServer, [], [cast: fn _handler_name, {_callback, _message} -> {:ok} end]}
    ]) do
      callback = String.to_atom(Keyword.get(@handler.handler_test, :callback))
      execute_handler_callback(@handler_name, @handler.handler_test, @sqs_message)
      assert called(GenServer.cast(@handler_name, {callback, @sqs_message}))
    end
  end
end
