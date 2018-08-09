defmodule Lix.Handler.Helpers do
  require Logger

  def delete_message(handler, [%{receipt_handle: receipt_handle} | _]) do
    Logger.debug(
      "Handler -> delete_message -> handler: #{inspect(handler)}, receipt_handle: #{
        receipt_handle
      }"
    )

    queue = Keyword.get(handler, :queue)
    Lix.Consumer.delete_message(queue, receipt_handle)
  end

  def execute_handler_callback(handler_name, handler, message) do
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
end
