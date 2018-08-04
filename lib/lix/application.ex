defmodule Lix.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: Lix.Worker.start_link(arg)
      {Lix.Consumer.Supervisor, []}
      #Supervisor.child_spec(
      #  {Lix.Consumer, %{worker_name: :catalog_item, queue_name: "test_item"}},
      #  id: :catalog_item_consumer
      #)
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Lix.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
