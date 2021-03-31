defmodule Money.ExchangeRates.ECBExchangeRates.Cldr do
  use Cldr,
    locales: ["en"],
    default_locale: "en",
    providers: [Cldr.Number],
    # Prevents warning at runtime as the format is precompiled
    precompile_number_formats: ["#0.00"]
end
