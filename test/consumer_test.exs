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
      assert called(ExAws.SQS.receive_message("queue/queue"))
      assert called(ExAws.request!(@sqs_message))
    end
  end
end
