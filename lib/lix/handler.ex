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
    GenServer.cast(@name, {:execute, handler_name})
  end

  defp delete_message(handler, [%{receipt_handle: receipt_handle} | _]) do
    queue = Keyword.get(handler, :queue)
    IO.puts(inspect(Lix.Consumer.delete_message(queue, receipt_handle)))
  end

  defp call_handler_callback(handler_name, handler, message) do
    case GenServer.call(
           handler_name,
           {String.to_atom(Keyword.get(handler, :callback)), message}
         ) do
      {:ok, message} ->
        delete_message(handler, message)
      _ -> {:error, message}
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

    if length(message) > 0 do
      call_handler_callback(handler_name, handler, message)
    end

    {:noreply, registred_handlers}
  end
end
