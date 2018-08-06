defmodule Lix.Handler do
  use GenServer

  @name __MODULE__

  def start_link(registred_handlers) do
    GenServer.start_link(__MODULE__, registred_handlers, name: @name)
  end

  @impl true
  def init(%{}) do
    {:ok, %{}}
  end

  def register(handler) do
   GenServer.cast(@name, {:register, handler})
  end

  def run(handler_name) do
    GenServer.call(@name, {:execute, handler_name})
  end

  ## OTP callbacks

  @impl true
  def handle_cast({:register, handler}, registred_handlers) do
    {:noreply, Map.merge(registred_handlers, handler)}
  end

  @impl true
  def handle_call({:execute, handler_name}, _from, registred_handlers) do
    handler = registred_handlers[handler_name]
    message = Lix.Consumer.get_message(Keyword.get(handler, :queue))
    resp = GenServer.call(handler_name, {String.to_atom(Keyword.get(handler, :callback)), message})
    {:reply, resp, registred_handlers}
  end
end
