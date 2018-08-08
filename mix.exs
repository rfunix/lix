defmodule Lix.MixProject do
  use Mix.Project

  defp description do
    """
    Library to create is generic handler workers for SQS messages.
    """
  end

  def project do
    [
      app: :lix,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: description()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
      # mod: {Lix.Application, []},
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      #
      {:ex_aws, "~> 2.0"},
      {:ex_aws_sqs, "~> 2.0"},
      {:poison, "~> 3.0"},
      {:hackney, "~> 1.9"},
      {:sweet_xml, "~> 0.6"},
      {:mock, "~> 0.3.0", only: :test}
    ]
  end

  defp package do
    [
      maintainers: ["Rafael Francischini"],
      files: ~w(lib priv .formatter.exs mix.exs README* readme* LICENSE*
                        license* CHANGELOG* changelog* src),
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/rfunix/lix"}
    ]
  end
end
