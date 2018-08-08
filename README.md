# Lix [![CircleCI](https://circleci.com/gh/rfunix/lix/tree/master.svg?style=svg)](https://circleci.com/gh/rfunix/lix/tree/master)

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `lix` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:lix, "~> 0.1.0"}
  ]
end
```

## Example

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
    Lix.Handler.register(@handler_info)
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

