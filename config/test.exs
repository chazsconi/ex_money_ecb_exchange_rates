use Mix.Config

config :ex_money,
  exchange_rates_retrieve_every: :never,
  log_failure: nil,
  log_info: nil,
  default_cldr_backend: Money.ExchangeRates.ECBExchangeRates.Cldr,
  api_module: Money.ExchangeRates.ECBExchangeRates
