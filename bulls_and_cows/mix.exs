defmodule BullsAndCows.Mixfile do
  use Mix.Project

  def project do
    [
      app: :bulls_and_cows,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      test_coverage: [tool: Coverex.Task]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cowboy, "~> 1.1.2"},
      {:plug, "~> 1.4.3"},
      {:uuid, "~> 1.1"},
      {:poison, "~> 3.1.0"},
      {:coverex, "~> 1.4.10", only: :test},
      {:mock, "~> 0.2.1", only: :test}
    ]
  end
end
