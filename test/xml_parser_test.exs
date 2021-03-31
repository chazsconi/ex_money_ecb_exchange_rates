defmodule ECBExchangeRatesTest do
  use ExUnit.Case

  alias Money.ExchangeRates.ECBExchangeRates.XMLParser

  test "Daily rates parsed" do
    assert {:ok, rates} =
             File.read!("test/fixtures/eurofxref-daily.xml")
             |> XMLParser.parse_rates()

    assert [
             %{
               time: "2021-03-30",
               data: [
                 %{currency: "USD", rate: "1.1741"},
                 %{currency: "JPY", rate: "129.48"} | _
               ]
             }
           ] = rates

    # Just rates for 1 date
    assert length(rates) == 1
    # Rates for 32 currencies
    assert length(hd(rates).data) == 32
  end

  test "90 day historical rates parsed" do
    assert {:ok, rates} =
             File.read!("test/fixtures/eurofxref-hist-90d.xml")
             |> XMLParser.parse_rates()

    assert [
             _,
             %{
               time: "2021-03-29",
               data: [
                 %{currency: "USD", rate: "1.1784"},
                 %{currency: "JPY", rate: "129.19"} | _
               ]
             }
             | _
           ] = rates

    # Just rates for 63 days (only includes working days)
    assert length(rates) == 63
    # Rates for 32 currencies
    assert length(hd(rates).data) == 32
  end

  test "invalid xml" do
    assert {:error, :invalid_xml_document} == XMLParser.parse_rates("foo")
  end

  test "valid xml, but incorrect structure" do
    assert {:error, :incorrect_xml_data} ==
             XMLParser.parse_rates("<foo><bar>something</bar></foo>")
  end
end
