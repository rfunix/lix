defmodule Lix do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Lix.Consumer.Supervisor, []},
      {Lix.Producer.Supervisor, []},
      {Lix.Handler.Supervisor, []}
    ]

    opts = [strategy: :one_for_one, name: Lix.Supervisor]

    #{:ok, _} = Logger.add_backend(Sentry.LoggerBackend)

    Supervisor.start_link(children, opts)
  end
end
