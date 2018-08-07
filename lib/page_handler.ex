defmodule Lix.Page.Handler do
  use GenServer 
  @name :handler_page
  @handler_info %{handler_page: [queue: "test_page", callback: "process_page"]}

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: @name)
  end

  def init(args) do
    Lix.Handler.register(@handler_info)
    {:ok, args}
  end

  def handling() do
    Lix.Handler.run(@name)
  end

  def handle_call({:process_page, message}, _from, _state) do
    {:reply, message, message}
  end


end
