defmodule JetCredo.MixProject do
  use Mix.Project

  def project do
    [
      app: :jet_credo,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:credo, "~> 1.6", optional: true},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false}
    ]
  end
end
