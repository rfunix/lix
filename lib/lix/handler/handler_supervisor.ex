defmodule Lix.Handler.Supervisor do
  use Supervisor

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    children = [
      {Lix.Handler.Manager, %{}},
      {Lix.Handler, %{}}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
