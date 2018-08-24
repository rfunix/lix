defmodule Lix.Producer do
  use GenServer

  @name __MODULE__

  ## Producer API

  def start_link(_args) do
    GenServer.start_link(__MODULE__, {}, name: @name)
  end

  def init(args) do
    {:ok, args}
  end

  def send_message(topic, message) do
    GenServer.cast(@name, {:send_message, message, topic})
  end

  # Producer OTP callbacks

  def handle_cast({:send_message, message, topic_arn}, state) do
    ExAws.SNS.publish(message, topic_arn: topic_arn)
    |> ExAws.request!()

    {:noreply, state}
  end
end
