defmodule ProducerTest do
  use ExUnit.Case, async: false
  import Mock

  defp message_test, do: "message_test"
  defp topic_arn_test, do: "topic_arn_test"

  test "send_message" do
    with_mocks [
      {ExAws.SNS, [], [publish: fn _message,  [topic_arn: _topic_arn] -> {:ok} end]},
      {ExAws, [], [request!: fn _message -> {:ok} end]}
    ] do
      Lix.Producer.send_message(topic_arn_test(), message_test())
      Process.sleep(1)
      assert called(ExAws.SNS.publish(message_test(), topic_arn: topic_arn_test()))
      assert called(ExAws.request!({:ok}))
    end
  end
end
