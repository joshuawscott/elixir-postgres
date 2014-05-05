defmodule Postgres.Mixfile do
  use Mix.Project

  def project do
    [ app: :postgres,
      version: "0.0.1",
      elixir: "~> 0.13",
      deps: deps,
      compile_path: 'ebin' ]
  end

  # Configuration for the OTP application
  def application do
    []
  end

  # Returns the list of dependencies in the format:
  # { :foobar, "~> 0.1", git: "https://github.com/elixir-lang/foobar.git" }
  defp deps do
    []
  end
end
