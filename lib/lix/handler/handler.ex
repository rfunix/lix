defmodule Lix.Handler do
  require Logger
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
    Logger.debug("Handler -> registered: #{inspect(handler)}")
    GenServer.cast(@name, {:register, handler})
  end

  def run(handler_name) do
    Logger.debug("Handler -> run: #{inspect(:handler_name)}")
    GenServer.cast(@name, {:execute, handler_name})
  end

  defp delete_message(handler, [%{receipt_handle: receipt_handle} | _]) do
    Logger.debug(
      "Handler -> delete_message -> handler: #{inspect(:handler_name)}, receipt_handle: #{
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

    case GenServer.call(
           handler_name,
           {String.to_atom(Keyword.get(handler, :callback)), message}
         ) do
      {:ok, message} ->
        delete_message(handler, message)
        {:ok, message}

      _ ->
        {:error, message}
    end
  end

  ## OTP callbacks

  @impl true
  def handle_cast({:register, handler}, registred_handlers) do
    {:noreply, Map.merge(registred_handlers, handler)}
  end

  @impl true
  def handle_cast({:execute, handler_name}, registred_handlers) do
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
end
