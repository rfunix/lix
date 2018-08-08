defmodule Lix.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Lix.Consumer.Supervisor, []},
      {Lix.Handler.Supervisor, []},
      {Lix.Item.Handler, []},
    ]

    opts = [strategy: :one_for_one, name: Lix.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
