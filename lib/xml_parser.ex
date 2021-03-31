defmodule Money.ExchangeRates.ECBExchangeRates.XMLParser do
  @moduledoc "Parse XML returned from ECB endpoint"
  import SweetXml

  @doc """
  Given the XML returns `{:ok, rates}` or `{:error, reason}`

  The `rates` is a list:
  ```
    [
      %{
        data: [
          %{currency: "USD", rate: "1.1741"},
          %{currency: "GBP", rate: "0.85378"},
        ],
        time: "2021-03-30"
      }
    ]
  ```
  """
  def parse_rates(doc) do
    # The l suffix is for a list, the s suffix is to return as strings not charlists
    try do
      doc
      |> xpath(~x"/gesmes:Envelope/Cube/Cube"l,
        time: ~x"@time"s,
        data: [~x"Cube"l, currency: ~x"@currency"s, rate: ~x"@rate"s]
      )
      |> case do
        # Should have at least one rate present otherwise the XML is probably not the right format
        [_ | _] = rates -> {:ok, rates}
        _ -> {:error, :incorrect_xml_data}
      end
    catch
      :exit, _ -> {:error, :invalid_xml_document}
    end
  end
end
