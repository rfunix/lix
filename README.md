# Lix [![CircleCI](https://circleci.com/gh/rfunix/lix/tree/master.svg?style=svg)](https://circleci.com/gh/rfunix/lix/tree/master)

# Lix is generic worker handler for SQS messages.

## Installation

First, add Lix to your `mix.exs` dependencies:

```elixir
def deps do
  [
    {:lix, git: "https://github.com/rfunix/lix/", tag: "0.1.7"},
  ]
end
```

and run `$ mix deps.get`. Add `:lix` to your applications list if your Elixir version is 1.3 or lower:

```elixir
def application do
  [applications: [:lix]]
end
```

Lix using [ex_aws_sqs](https://github.com/ex-aws/ex_aws_sqs) to handling SQS messages.
We need to add some settings in our file `config.exs`, for example:

```elixir
config :ex_aws, :sqs,
  access_key_id: "",
  secret_access_key: "",
  scheme: "http://",
  host: "localhost",
  port: 4100,
  region: "local-01"
```

## Usage

```elixir
defmodule Example.Item.Handler do
  use GenServer

  @name :handler_item
  @handler_info %{handler_item: [queue: "queue/test_item", callback: "process_item"]}

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: @name)
  end

  def handling() do
    Lix.Handler.run(@name)
    handling()
  end

  @impl true
  def init(args) do
    Lix.Handler.Manager.register(@handler_info)
    {:ok, args}
  end

  @impl true
  def handle_cast({:process_item, message}, _state) do
    # Do things
    Lix.Handler.confirm_processed_callback(@name, message)
    {:noreply, message}
  end
end

```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/lix](https://hexdocs.pm/lix).

