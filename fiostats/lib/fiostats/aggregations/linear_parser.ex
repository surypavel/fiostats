defmodule Fiostats.Aggregations.LinearParser do
  def parse(expression) do
    expression
    |> normalize()
    |> split_terms()
    |> Enum.map(&parse_term/1)
  end

  defp normalize(expr) do
    expr
    |> String.replace("-", "+-")
  end

  defp split_terms(expr) do
    expr
    |> String.split("+", trim: true)
  end

  defp parse_term(term) do
    regex = ~r/^([+-]?)([a-zA-Z_]+)(?:([\*\/])(\d+(?:\.\d+)?))?$/

    case Regex.run(regex, term) do
      [_, sign, variable] ->
        factor = if sign == "-", do: -1.0, else: 1.0
        %{variable: variable, factor: factor}

      [_, sign, variable, "*", factor_str] ->
        factor = String.to_float(factor_str)
        factor = if sign == "-", do: -factor, else: factor
        %{variable: variable, factor: factor}

      [_, sign, variable, "/", factor_str] ->
        factor = 1.0 / String.to_float(factor_str)
        factor = if sign == "-", do: -factor, else: factor
        %{variable: variable, factor: factor}

      _ ->
        raise "Invalid term format: #{term}"
    end
  end
end
