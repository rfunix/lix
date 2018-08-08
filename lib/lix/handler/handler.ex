defmodule Lix.Handler do
  require Logger
  use GenServer

  @name __MODULE__
  @handler_process_time 1000

  def start_link(registred_handlers) do
    GenServer.start_link(__MODULE__, registred_handlers, name: @name)
  end

  @impl true
  def init(%{}) do
    {:ok, %{}}
  end

  # Handler API

  def register(handler) do
    Logger.debug("Handler -> registered: #{inspect(handler)}")
    GenServer.cast(@name, {:register, handler})
  end

  def run(handler_name) do
    Logger.debug("Handler -> run: #{inspect(:handler_name)}")
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

  defp delete_message(handler, [%{receipt_handle: receipt_handle} | _]) do
    Logger.debug(
      "Handler -> delete_message -> handler: #{inspect(handler)}, receipt_handle: #{
        receipt_handle
      }"
    )

    queue = Keyword.get(handler, :queue)
    Lix.Consumer.delete_message(queue, receipt_handle)
  end

  defp execute_handler_callback(handler_name, handler, message) do
    Logger.debug(
      "Handler -> execute_handler_callback: handler_name: #{inspect(:handler_name)} handler: #{
        inspect(handler)
      } message: #{inspect(message)}"
    )

    callback = String.to_atom(Keyword.get(handler, :callback))

    GenServer.cast(
      handler_name,
      {callback, message}
    )
  end

  ## Handler OTP Callbacks

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
