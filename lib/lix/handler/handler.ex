defmodule Lix.Handler do
  require Logger
  import Lix.Handler.Helpers

  use GenServer

  @name __MODULE__
  @handler_process_time 500

  # Handler API

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: @name)
  end

  def run(handler_name) do
    Logger.debug("Handler -> run: #{inspect(handler_name)}")

    case Lix.Handler.Manager.get_handler_by_name(handler_name) do
      {:ok, handler} ->
        GenServer.cast(@name, {:run, handler, handler_name})

      {:error, error_message} ->
        Logger.debug(error_message)
    end

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

  ## Handler OTP Callbacks

  @impl true
  def init(_args) do
    {:ok, %{}}
  end

  @impl true
  def handle_cast({:run, handler, handler_name}, state) do
    message = Lix.Consumer.get_message(Keyword.get(handler, :queue))

    cond do
      length(message) > 0 ->
        execute_handler_callback(handler_name, handler, message)

      true ->
        Logger.debug("Handler queue: #{inspect(Keyword.get(handler, :queue))} is empty...")
    end

    {:noreply, state}
  end

  @impl true
  def handle_cast({:delete_message, handler_name, message}, state) do
    case Lix.Handler.Manager.get_handler_by_name(handler_name) do
      {:ok, handler} ->
        delete_message(handler, message)

      {:error, error_message} ->
        Logger.debug(error_message)
    end

    {:noreply, state}
  end
end
