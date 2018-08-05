defmodule Lix.Item.Handler do
  use Lix.Handler

  def start_link() do
    GenServer.start_link(__MODULE__, {}, name: __MODULE__)
  end

  def init({}) do
    {:ok, {}}
  end

  def handling() do
    execute()
  end

  def handle_call({:process_item, message}, _from, _state) do
    {:reply, message, message}
  end

end
