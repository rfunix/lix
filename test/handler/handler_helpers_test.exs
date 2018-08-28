defmodule HandlerHelpersTest do
  use ExUnit.Case, async: false
  import Mock
  import Lix.Handler.Helpers

  defp topic_arn_test, do: "topic_arn_test"
  defp handler_name, do: :handler_test

  defp handler_fixture,
    do: [
      queue: "queue/test_handler",
      callback: "process_test",
      topic_arn: topic_arn_test()
    ]

  defp receipt_handle, do: %{receipt_handle: "test_receipt_handle"}
  defp sqs_message_fixture, do: %{body: %{messages: ["message test"]}}
  defp message_test, do: "message_test"

  test "delete message" do
    with_mocks([
      {ExAws.SQS, [], [delete_message: fn _queue, _receipt_handle -> {:ok} end]},
      {ExAws, [], [request!: fn _message -> {:ok} end]}
    ]) do
      delete_message(handler_fixture(), receipt_handle())
      Process.sleep(1)
      assert called(ExAws.SQS.delete_message("queue/test_handler", "test_receipt_handle"))
      assert called(ExAws.request!({:ok}))
    end
  end

  test "execute handler callback" do
    with_mocks([
      {GenServer, [], [cast: fn _handler_name, {_callback, _message} -> {:ok} end]}
    ]) do
      callback = String.to_atom(Keyword.get(handler_fixture(), :callback))
      execute_handler_callback(handler_name(), handler_fixture(), sqs_message_fixture())
      assert called(GenServer.cast(handler_name(), {callback, sqs_message_fixture()}))
    end
  end

  test "publish_message" do
    with_mocks [
      {ExAws.SNS, [], [publish: fn _message, [topic_arn: _topic_arn] -> {:ok} end]},
      {ExAws, [], [request!: fn _message -> {:ok} end]}
    ] do
      publish_message(handler_fixture(), message_test())
      Process.sleep(1)
      assert called(ExAws.SNS.publish(message_test(), topic_arn: topic_arn_test()))
      assert called(ExAws.request!({:ok}))
    end
  end
end
