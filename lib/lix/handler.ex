defmodule Lix.Handler do
  use GenServer

  defmacro __using__(_opts) do
    quote do
      import Lix.Handler
    end
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: handler_name())
  end

  defp handler_name() do
    Application.get_env(:lix, :handler_name)
  end

  def init(args) do
    {:ok, args}
  end

  def execute do
    GenServer.call(handler_name(), :execute)
  end

  ## OTP callbacks

  def handle_call(
        :execute,
        _from,
        state = %{queue: queue, handler_module: handler_module, callback: callback}
      ) do
    message = Lix.Consumer.get_message(queue)
    resp = GenServer.call(handler_module, {String.to_atom(callback), message})
    {:reply, resp, state}
  end
end
