defmodule Lix.Item.Handler do
  use GenServer

  @name :handler_item
  @handler_info %{handler_item: [queue: "test_item", callback: "process_item"]}

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: @name)
  end

  @impl true
  def init(args) do
    Lix.Handler.register(@handler_info)
    {:ok, args}
  end

  def handling() do
    Lix.Handler.run(@name)
    handling()
  end

  @impl true
  def handle_call({:process_item, message}, _from, _state) do
    # Do things
    {:reply, {:ok, message}, message}
  end
end
