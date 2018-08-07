defmodule Lix.Consumer.Supervisor do
  use Supervisor

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(args) do
    children = [
      {Lix.Consumer, [args]}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
