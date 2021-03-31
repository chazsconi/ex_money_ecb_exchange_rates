# ECB Exchange Rates

## Overview
Money plugin to use European Central Bank exchange rates found here:

### 90 day historical rates
https://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml

### Current rate
https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml

### All historical rates
https://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist.xml

Currently only rates for 90 days are available via this plugin.

See the `Money.ExchangeRates.ECBExchangeRates` for more details for the limitations.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ecb_exchange_rates` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ecb_exchange_rates, "~> 0.1.0"}
  ]
end
```

In your `ex_money` configuration, set it the `api_module` to `Money.ExchangeRates.ECBExchangeRates`

## TODO
* Add better tests as only the `XMLParser` is currently tested
* Support rates from more than 90 days ago