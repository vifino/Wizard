defmodule Wizard.Mixfile do
  use Mix.Project

  def project do
    [ app: :wizard,
      version: "0.0.1",
      elixir: "~> 1.0",
      escript: escript,
      deps: deps ]
  end

  def escript do
    [ main_module: Wizard, embeded_elixir: true ]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [ applications: [],
      mod: { Wizard, [] }
    ]
  end

  # Returns the list of dependencies in the format:
  # { :foobar, git: "https://github.com/elixir-lang/foobar.git", tag: "0.1" }
  #
  # To specify particular versions, regardless of the tag, do:
  # { :barbat, "~> 0.1", github: "elixir-lang/barbat" }
  defp deps do
    []
  end
end
