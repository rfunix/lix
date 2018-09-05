# Lix [![CircleCI](https://circleci.com/gh/rfunix/lix/tree/master.svg?style=svg)](https://circleci.com/gh/rfunix/lix/tree/master)

# Lix is generic worker handler for SQS messages.

## Installation

First, add Lix to your `mix.exs` dependencies:

```elixir
def deps do
  [
    {:lix, git: "https://github.com/rfunix/lix/", tag: "0.1.9"},
  ]
end
```

and run `$ mix deps.get`. Add `:lix` to your applications list:

```elixir
def application do
  [applications: [:lix]]
end
```

Lix using [ex_aws_sqs](https://github.com/ex-aws/ex_aws_sqs) to handling SQS messages and [ex_aws_sns](https://github.com/ex-aws/ex_aws_sns) to publish handler messages.

We need to add some settings in our file `config.exs`, for example:

```elixir
config :ex_aws, :sqs,
  access_key_id: "",
  secret_access_key: "",
  scheme: "http://",
  host: "localhost",
  port: 4100,
  region: "local-01"
  
config :ex_aws, :sns,
  access_key_id: "",
  secret_access_key: "",
  scheme: "http://",
  host: "localhost",
  port: 4100,
  region: "local-01"
```

Lix has specific settings as well, for example:
```elixir
config :lix,
  max_number_of_messages: 10,
  visibility_timeout: 0.30,
  handler_backoff: 500
```

## Basic Worker Example

```elixir

defmodule Basic.Handler.Example do
  use GenServer

  @name :handler_example

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: @name)
  end

  @impl true
  def init(args) do
    Lix.Handler.Manager.register(%{
      handler_example: [queue: "queue/handler_queue", callback: "process_item"]
    })

    schedule_poller()
    {:ok, args}
  end

  defp schedule_poller() do
    send(self(), :poll)
  end

  @impl true
  def handle_info(:poll, state) do
    Lix.Handler.run(@name)
    schedule_poller()
    {:noreply, state}
  end

  @impl true
  def handle_cast({:process_item, messages}, state) do
    # Do things
    Enum.map(messages, fn message ->
      Lix.Handler.confirm_processed_callback(@name, message)
    end)

    {:noreply, state}
  end
end

```

## Basic Worker Example with publish sns messages

```
defmodule Basic.Handler.Example do
  use GenServer

  @name :handler_example

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: @name)
  end

  @impl true
  def init(args) do
    Lix.Handler.Manager.register(%{
      handler_example: [queue: "queue/handler_queue", callback: "process_item", topic_arn: "my-topic"]
    })

    schedule_poller()
    {:ok, args}
  end

  defp schedule_poller() do
    send(self(), :poll)
  end

  @impl true
  def handle_info(:poll, state) do
    Lix.Handler.run(@name)
    schedule_poller()
    {:noreply, state}
  end

  @impl true
  def handle_cast({:process_item, messages}, state) do
    # Do things
    Enum.map(messages, fn message ->
      Lix.Handler.confirm_processed_callback(@name, message, "PUBLISH THIS MESSAGE")
    end)

    {:noreply, state}
  end
end
```

## Workers Example

```elixir

defmodule Example.Handler.Supervisor do
  use Supervisor

  @number_of_workers 1..5

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = Enum.map(@number_of_workers, fn worker_number -> 
      name = String.to_atom("handler#{worker_number}")
      Supervisor.child_spec({Example.Handler, %{name: name, queue: "test_item"}}, id: name)
    end)

    Supervisor.init(children, strategy: :one_for_one)
  end
end

defmodule Example.Handler do
  use GenServer
  require Logger

  def start_link(%{name: name} = args) do
    GenServer.start_link(__MODULE__, args, name: name)
  end

  @impl true
  def init(args) do
    generate_handler_info(args)
    |> Lix.Handler.Manager.register()

    schedule_poller()
    {:ok, args}
  end

  defp generate_handler_info(%{name: name, queue: queue}) do
    AtomicMap.convert(%{name => [queue: "queue/#{queue}", callback: "process_item"]})
  end

  defp schedule_poller() do
    send(self(), :poll)
  end

  @impl true
  def handle_info(:poll, %{name: name} = state) do
    Lix.Handler.run(name)
    schedule_poller()
    {:noreply, state}
  end

  @impl true
  def handle_cast({:process_item, messages}, %{name: name} = state) do
    # Do things
    Enum.map(messages, fn message ->
      Lix.Handler.confirm_processed_callback(name, message)
    end)

    {:noreply, state}
  end
end

Example.Handler.Supervisor.start_link([])
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/lix](https://hexdocs.pm/lix).

