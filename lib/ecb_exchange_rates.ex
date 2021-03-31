defmodule Money.ExchangeRates.ECBExchangeRates do
  @moduledoc """
  Implements the `Money.ExchangeRates` for the European Central Bank XML data.

  Rates are only published on working days at around 16:00 CET

  The latest_rates just returns the rate from the previous working day, or current day if available (after 16:00 CET)
  If requesting an historical rate for a non-working day, the rate from the next available date is given.

  Only rates for up to 90 days in the past are available.

  Only rates for major currencies are available.

  ## Required configuration:

  It is possible to configure an alternative base url for the
  service in case it changes in the future. For example:

      config :ex_money,
        ecb_exchange_rates_url: "https://www.ecb.europa.eu/some_other_url/"

  """
  require Logger
  alias Money.ExchangeRates.Retriever
  alias Money.ExchangeRates.ECBExchangeRates.XMLParser

  @behaviour Money.ExchangeRates

  @ecb_rates_url "https://www.ecb.europa.eu/stats/eurofxref/"

  @doc """
  Update the retriever configuration to include the requirements
  for ECB Exchange Rates.  This function is invoked when the
  exchange rate service starts up, just after the ets table
  :exchange_rates is created.

  * `default_config` is the configuration returned by `Money.ExchangeRates.default_config/0`

  Returns the configuration either unchanged or updated with
  additional configuration specific to this exchange
  rates retrieval module.
  """
  @impl Money.ExchangeRates
  def init(default_config) do
    url = Money.get_env(:ecb_rates_url, @ecb_rates_url)
    Map.put(default_config, :retriever_options, %{url: url})
  end

  @impl Money.ExchangeRates
  def decode_rates(body) do
    {:ok, raw_rates} = XMLParser.parse_rates(body)

    raw_rates
    |> Enum.map(fn %{time: time, data: data} ->
      {Date.from_iso8601!(time),
       data
       |> Enum.map(fn %{currency: cur, rate: rate} ->
         {String.to_atom(cur), Decimal.new(rate)}
       end)
       |> Map.new()
       # Add EUR as the reference rate
       |> Map.put(:EUR, Decimal.new("1.0"))}
    end)
    |> Map.new()
  end

  @doc """
  Retrieves the latest exchange rates from Open Exchange Rates site.

  * `config` is the retrieval configuration. When invoked from the
  exchange rates services this will be the config returned from
  `Money.ExchangeRates.config/0`

  Returns:

  * `{:ok, rates}` if the rates can be retrieved

  * `{:error, reason}` if rates cannot be retrieved

  Typically this function is called by the exchange rates retrieval
  service although it can be called outside that context as
  required.

  """
  @impl Money.ExchangeRates
  @spec get_latest_rates(Money.ExchangeRates.Config.t()) :: {:ok, map()} | {:error, String.t()}
  def get_latest_rates(config) do
    url = config.retriever_options.url

    with {:ok, %{} = rates} <- retrieve_latest_rates(url, config) do
      case Map.values(rates) do
        [latest_rates] -> {:ok, latest_rates}
        _ -> {:error, :invalid_latest_rates}
      end
    end
  end

  @latest_rates "/eurofxref-daily.xml"
  defp retrieve_latest_rates(url, config) do
    Retriever.retrieve_rates(url <> @latest_rates, config)
  end

  @doc """
  Retrieves the historic exchange rates from Open Exchange Rates site.

  * `date` is a date returned by `Date.new/3` or any struct with the
    elements `:year`, `:month` and `:day`.

  * `config` is the retrieval configuration. When invoked from the
    exchange rates services this will be the config returned from
    `Money.ExchangeRates.config/0`

  Returns:

  * `{:ok, rates}` if the rates can be retrieved

  * `{:error, reason}` if rates cannot be retrieved

  Typically this function is called by the exchange rates retrieval
  service although it can be called outside that context as
  required.
  """
  @impl Money.ExchangeRates
  def get_historic_rates(%Date{calendar: Calendar.ISO} = date, config) do
    url = config.retriever_options.url

    with {:ok, rates} <- retrieve_historic_rates(url, config) do
      find_closest_date(rates, date)
    end
  end

  def get_historic_rates(%{year: year, month: month, day: day}, config) do
    case Date.new(year, month, day) do
      {:ok, date} -> get_historic_rates(date, config)
      error -> error
    end
  end

  defp find_closest_date(rates, date) do
    sorted_rates =
      rates
      |> Enum.sort_by(fn {rate_date, _} -> rate_date end, Date)

    {first_rate_date, _} = hd(sorted_rates)

    # Ensure we are not checking for date before the first available date
    case Date.compare(date, first_rate_date) do
      :lt ->
        {:error, :no_rate_for_date}

      _ ->
        sorted_rates
        |> Enum.find(fn {rate_date, _} -> Date.compare(date, rate_date) in [:lt, :eq] end)
        |> case do
          {_, rates_for_date} -> {:ok, rates_for_date}
          nil -> {:error, :no_rate_for_date}
        end
    end
  end

  @historic_rates "/eurofxref-hist-90d.xml"
  defp retrieve_historic_rates(url, config) do
    Retriever.retrieve_rates(url <> @historic_rates, config)
  end
end
