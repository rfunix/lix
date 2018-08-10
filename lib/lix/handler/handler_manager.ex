defmodule Lix.Handler.Manager do
  require Logger
  use GenServer

  @name __MODULE__

  ## Handler.Manager API

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: @name)
  end

  def register(handler) do
    Logger.debug("Handler.Manager -> registered: #{inspect(handler)}")
    GenServer.cast(@name, {:register, handler})
  end

  def get_registred_handlers() do
    Logger.debug("Handler.Manager -> get_registred_handlers")
    GenServer.call(@name, :get_registred_handlers)
  end

  def get_handler_by_name(handler_name) do
    Logger.debug("Handler.Manager -> get_handler_by_name")
    GenServer.call(@name, {:get_handler_by_name, handler_name})
  end

  ## Handler.Manager OTP Callbacks 

  @impl true
  def init(_args) do
    {:ok, %{}}
  end

  @impl true
  def handle_cast({:register, handler}, registred_handlers) do
    {:noreply, Map.merge(registred_handlers, handler)}
  end

  @impl true
  def handle_call(:get_registred_handlers, _from, registred_handlers) do
    {:reply, {:ok, registred_handlers}, registred_handlers}
  end

  @impl true
  def handle_call({:get_handler_by_name, handler_name}, _from, registred_handlers) do
    case registred_handlers[handler_name] do
      handler when handler != nil ->
        {:reply, {:ok, handler}, registred_handlers}

      nil ->
        {:reply, {:error, "Handler does not exists: #{handler_name}"}, registred_handlers}
    end
  end
end
