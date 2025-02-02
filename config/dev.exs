import Config

config :ex_money,
  auto_start_exchange_rate_service: true,
  exchange_rates_retrieve_every: 300_000,
  log_failure: :warn,
  log_info: :info,
  log_success: :info,
  json_library: Jason,
  exchange_rates_cache: Money.ExchangeRates.Cache.Dets,
  default_cldr_backend: Money.ExchangeRates.ECBExchangeRates.Cldr,
  api_module: Money.ExchangeRates.ECBExchangeRates

config :ex_cldr,
  default_backend: Money.ExchangeRates.ECBExchangeRates.Cldr
