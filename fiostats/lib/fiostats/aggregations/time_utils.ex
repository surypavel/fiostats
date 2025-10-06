defmodule Fiostats.Aggregations.TimeUtils do
  @granularities ["month", "quarter", "year"]

  def get_granularities(), do: @granularities

  def buckets_between(d1, d2, granularity) when granularity in @granularities do
    {start_year, start_idx} = date_to_index(d1, granularity)
    {end_year, end_idx} = date_to_index(d2, granularity)

    for year <- start_year..end_year,
        idx <- granularity_range(granularity),
        within_range?({year, idx}, {start_year, start_idx}, {end_year, end_idx}) do
      {year, idx}
    end
  end

  def date_to_index(%Date{year: year, month: month}, "month") do
    {year, month - 1}
  end

  def date_to_index(%Date{year: year, month: month}, "quarter") do
    quarter = div(month - 1, 3)
    {year, quarter}
  end

  def date_to_index(%Date{year: year}, "year") do
    {year, 0}
  end

  def index_to_str({y, m}, "month") do
    "#{y}/#{m + 1}"
  end

  def index_to_str({y, m}, "quarter") do
    "#{y}/Q#{m + 1}"
  end

  def index_to_str({y, 0}, "year") do
    "#{y}"
  end

  defp granularity_range("month"), do: 0..11
  defp granularity_range("quarter"), do: 0..3
  defp granularity_range("year"), do: 0..0

  defp within_range?({year, idx}, {start_year, start_idx}, {end_year, end_idx}) do
    {year, idx} >= {start_year, start_idx} and {year, idx} <= {end_year, end_idx}
  end

  def bounds_from_index({year, index}, "month") do
    start_date = Date.new!(year, index + 1, 1)
    end_date = Date.end_of_month(start_date)
    {start_date, end_date}
  end

  def bounds_from_index({year, quarter_index}, "quarter") do
    month_start = quarter_index * 3 + 1
    start_date = Date.new!(year, month_start, 1)
    end_date = end_of_quarter(start_date)
    {start_date, end_date}
  end

  def bounds_from_index({year, 0}, "year") do
    start_date = Date.new!(year, 1, 1)
    end_date = Date.new!(year, 12, 31)
    {start_date, end_date}
  end

  defp end_of_quarter(%Date{year: year, month: month}) do
    month_end = month + 2
    Date.end_of_month(Date.new!(year, month_end, 1))
  end
end
