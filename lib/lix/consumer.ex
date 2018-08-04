defmodule Lix.Consumer do
  use GenServer

  @name __MODULE__

  ## Cli

  def start_link(_args) do
    GenServer.start_link(__MODULE__, {}, name: @name)
  end

  def init(_args) do
    {:ok, {}}
  end

  def get_message(queue) do
    GenServer.call(@name, {:get_message, queue})
  end

  defp parse_messages(%{body: %{messages: messages}}) do
    messages
  end

  ## OTP callbacks

  def handle_call({:get_message, queue}, _from, _args) do
    messages =
      ExAws.SQS.receive_message("queue/#{queue}")
      |> ExAws.request!()
      |> parse_messages

    {:reply, messages, queue}
  end
end
