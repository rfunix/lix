defmodule Lix.Handler.Supervisor do
  use Supervisor

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    children = [
      {Lix.Handler,
       %{queue: "test_item", callback: "process_item", handler_module: Lix.Item.Handler}}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
