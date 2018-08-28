defmodule HandlerTest do
  use ExUnit.Case, async: true

  import Mock

  defp handler_name_fixture, do: :handler_test

  defp handler_fixture,
    do: %{handler_test: [queue: "queue/test_handler", callback: "process_test"]}

  defp sqs_message_fixture, do: ["message test"]
  defp receipt_handler_fixture, do: %{receipt_handle: "test_receipt_handle"}

  # TODO: Improve this test
  test "handler run" do
    with_mocks([
      {Lix.Consumer, [], [get_message: fn _queue -> sqs_message_fixture() end]}
    ]) do
      Lix.Handler.Manager.register(handler_fixture())
      Lix.Handler.run(handler_name_fixture())
      assert called(Lix.Consumer.get_message("queue/test_handler"))
    end
  end

  test "confirm processed callback " do
    with_mocks([
      {ExAws.SQS, [], [delete_message: fn _queue, _receipt_handle -> {:ok} end]},
      {ExAws, [], [request!: fn _message -> {:ok} end]}
    ]) do
      Lix.Handler.Manager.register(handler_fixture())
      Lix.Handler.confirm_processed_callback(handler_name_fixture(), receipt_handler_fixture())
      Process.sleep(10)
      assert called(ExAws.SQS.delete_message("queue/test_handler", "test_receipt_handle"))
      assert called(ExAws.request!({:ok}))
    end
  end
end
