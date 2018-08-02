defmodule Lix.Consumer do
  use GenServer

  ## Cli

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: args.worker_name)
  end

  def init(args) do
    {:ok, args}
  end

  def get_message(worker_name) do
    GenServer.call(worker_name, :get_message)
  end

  ## OTP functions

  def handle_call(:get_message, _from, args) do
    message =
      ExAws.SQS.receive_message("queue/#{args.queue_name}")
      |> ExAws.request!

    {:reply, message, args}
  end

end
