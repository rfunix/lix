defmodule ConsumerTest do
  use ExUnit.Case, async: true

  import Mock

  @sqs_message %{body: %{messages: ["message test"]}}

  test "get_message" do
    with_mocks [
      {ExAws.SQS, [], [receive_message: fn _queue -> @sqs_message end]},
      {ExAws, [], [request!: fn _message -> @sqs_message end]}
    ] do
      assert ["message test"] == Lix.Consumer.get_message("queue")
      assert called(ExAws.SQS.receive_message("queue"))
      assert called(ExAws.request!(@sqs_message))
    end
  end

  test "delete_message" do
    with_mocks([
      {ExAws.SQS, [], [delete_message: fn _queue, _receipt_handle -> {:ok} end]},
      {ExAws, [], [request!: fn _message -> {:ok} end]}
    ]) do
      Lix.Consumer.delete_message("queue", "receipt_handle")
      Process.sleep(1)
      assert called(ExAws.SQS.delete_message("queue", "receipt_handle"))
      assert called(ExAws.request!({:ok}))
    end
  end
end
