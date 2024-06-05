defmodule Benchmark do
  require Logger

  @doc "Measure the time to execute a function"
  def measure(label, function) do
    Logger.warning("Measuring #{label}...")
    {us, result} = :timer.tc(function)
    Logger.warning("...Measured #{label} #{us / 1000}ms")
    result
  end

  @doc """
  Measure that can be used within a pipe

  To use convert:
      ...
      |> my_f()
      ...

  to:
      ...
      |> p_measure("my_f", & &1 |> my_f())
      ...

  """
  def p_measure(p, label, function) do
    measure(label, fn -> function.(p) end)
  end
end
