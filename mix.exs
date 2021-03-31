defmodule ECBExchangeRates.MixProject do
  use Mix.Project

  def project do
    [
      app: :ecb_exchange_rates,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: false,
      deps: deps(),
      description: description(),
      name: "ECBExchangeRates",
      elixirc_paths: elixirc_paths(Mix.env()),
      package: package(),
      config_path: "config/config.exs"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description, do: "Money plugin to use European Central Bank exchange rates"

  defp package do
    [
      maintainers: ["Charles Bernasconi"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/chazsconi/ex_money_ecb_exchange_rates",
        "Readme" =>
          "https://github.com/chazsconi/ex_money_ecb_exchange_rates/blob/master/README.md",
        "Changelog" =>
          "https://github.com/chazsconi/ex_money_ecb_exchange_rates/blob/master/CHANGELOG.md"
      },
      files: [
        "lib",
        "mix.exs",
        "README.md",
        "CHANGELOG.md"
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_money, ">= 3.4.0"},
      {:sweet_xml, "~> 0.6.6"},
      {:jason, "~> 1.0", optional: true}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test", "test/support"]
  defp elixirc_paths(:dev), do: ["lib", "mix"]
  defp elixirc_paths(_), do: ["lib"]
end
