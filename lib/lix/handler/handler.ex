defmodule Lix.Handler do
  require Logger
  import Lix.Handler.Helpers

  use GenServer

  @name __MODULE__
  @handler_process_time 500

  # Handler API

  def start_link(registred_handlers) do
    GenServer.start_link(__MODULE__, registred_handlers, name: @name)
  end

  def register(handler) do
    Logger.debug("Handler -> registered: #{inspect(handler)}")
    GenServer.cast(@name, {:register, handler})
  end

  def run(handler_name) do
    Logger.debug("Handler -> run: #{inspect(handler_name)}")
    GenServer.cast(@name, {:run, handler_name})
    Process.sleep(@handler_process_time)
  end

  def confirm_processed_callback(handler_name, message) do
    Logger.debug(
      "Handler confirm_processed_callback -> handler: #{inspect(handler_name)}, message: #{
        inspect(message)
      }"
    )

    GenServer.cast(@name, {:delete_message, handler_name, message})
  end

  def get_registred_handlers() do
    Logger.debug("Handler -> get_registred_handlers")
    GenServer.call(@name, :get_registred_handlers)
  end

  ## Handler OTP Callbacks

  @impl true
  def init(_args) do
    {:ok, %{}}
  end

  @impl true
  def handle_cast({:register, handler}, registred_handlers) do
    {:noreply, Map.merge(registred_handlers, handler)}
  end

  @impl true
  def handle_cast({:run, handler_name}, registred_handlers) do
    handler = registred_handlers[handler_name]
    message = Lix.Consumer.get_message(Keyword.get(handler, :queue))

    cond do
      length(message) > 0 ->
        execute_handler_callback(handler_name, handler, message)

      true ->
        Logger.debug("Handler queue: #{inspect(Keyword.get(handler, :queue))} is empty...")
    end

    {:noreply, registred_handlers}
  end

  @impl true
  def handle_cast({:delete_message, handler_name, message}, registred_handlers) do
    handler = registred_handlers[handler_name]
    delete_message(handler, message)
    {:noreply, registred_handlers}
  end

  @impl true
  def handle_call(:get_registred_handlers, _from, registred_handlers) do
    {:reply, {:ok, registred_handlers}, registred_handlers}
  end
end
