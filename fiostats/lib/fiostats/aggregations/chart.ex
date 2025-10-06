defmodule Fiostats.Aggregations.Chart do
  alias Fiostats.Aggregations.TimeUtils
  alias Fiostats.Transactions.Dashboards

  @min_date ~D[2020-01-01]

  defp group_by_buckets(payments_aggregate, buckets, granularity) do
    payments_aggregate
    |> Enum.group_by(fn [_, _, month, year] ->
      TimeUtils.date_to_index(
        %Date{month: month, year: year, day: 1},
        granularity
      )
    end)
    |> Map.merge(buckets |> Map.new(fn term -> {term, []} end), fn _, val1, _ -> val1 end)
  end

  defp sum_by_classification(payments_aggregate) do
    payments_aggregate
    |> Enum.group_by(fn [_, classification, _, _] -> classification end)
    |> Enum.map(fn {classification, group} ->
      {classification,
       group
       |> Enum.sum_by(fn [amount, _, _, _] ->
         -(amount
           |> Decimal.round(0, :down)
           |> Decimal.to_integer())
       end)}
    end)
    |> Map.new()
  end

  defp evaluate_dashboard_expr(row, expr) do
    expr
    |> Enum.map(fn expr -> Map.get(row, expr.variable, 0) * expr.factor end)
    |> Enum.sum()
    |> trunc()
    |> max(0)
  end

  def make(dashboard_id, payments_aggregate, granularity) do
    current_date = Date.utc_today()

    dashboard = Dashboards.get_options() |> Enum.find(&(&1.id == dashboard_id))

    buckets = TimeUtils.buckets_between(@min_date, current_date, granularity)

    bounds =
      buckets
      |> Enum.map(fn bucket -> TimeUtils.bounds_from_index(bucket, granularity) end)
      |> Enum.map(fn {s, e} -> [s, e] end)

    categories = buckets |> Enum.map(fn bucket -> TimeUtils.index_to_str(bucket, granularity) end)

    frequencies =
      payments_aggregate
      |> group_by_buckets(buckets, granularity)
      |> Enum.sort_by(fn {bucket, _} -> bucket end)
      |> Enum.map(fn {_, payments_aggregate_per_bucket} ->
        sum_by_classification(payments_aggregate_per_bucket)
      end)

    series =
      dashboard.columns
      |> Enum.map(fn col ->
        expr = Fiostats.Aggregations.LinearParser.parse(col.expr)
        values = frequencies |> Enum.map(&evaluate_dashboard_expr(&1, expr))

        %{
          name: col.name,
          data: values,
          deps: expr |> Enum.map(fn e -> e.variable end)
        }
      end)

    colors = dashboard.columns |> Enum.map(fn %{color: color} -> color end)

    %{
      categories: categories,
      series: series,
      colors: colors,
      bounds: bounds
    }
  end
end
