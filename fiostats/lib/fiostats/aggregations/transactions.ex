defmodule Fiostats.Aggregations.Transactions do
  require Ash.Query
  require Ash.Sort
  require Ecto.Query

  defp maybe_filter_search(query, "", _fuzzy, _field), do: query

  defp maybe_filter_search(query, value, false, :title),
    do: Ash.Query.filter(query, contains(title, ^value))

  defp maybe_filter_search(query, value, true, :title) do
    {:ok, [embedding]} = Fiostats.LLM.GeminiEmbedding.generate([value], %{})

    Ash.Query.filter(
      query,
      fragment("?::vector <-> ?::vector <= ?", full_text_vector, ^embedding, 1.1)
    )
  end

  defp maybe_filter_eq(query, "", _field), do: query

  defp maybe_filter_eq(query, value, :classification),
    do: Ash.Query.filter(query, classification == ^value)

  defp maybe_filter_eq(query, value, :account), do: Ash.Query.filter(query, account == ^value)

  defp maybe_filter_gte(query, "", _field), do: query
  defp maybe_filter_gte(query, value, :date), do: Ash.Query.filter(query, date >= ^value)

  defp maybe_filter_lte(query, "", _field), do: query
  defp maybe_filter_lte(query, value, :date), do: Ash.Query.filter(query, date <= ^value)

  defp apply_filter(query, filter) do
    query
    |> maybe_filter_search(filter.search, filter.is_fuzzy, :title)
    |> maybe_filter_eq(filter.classification, :classification)
    |> maybe_filter_eq(filter.account, :account)
    |> maybe_filter_gte(filter.date_from, :date)
    |> maybe_filter_lte(filter.date_to, :date)
  end

  def get_data(filter) do
    payments =
      Fiostats.Transactions.Transaction
      |> Ash.Query.for_read(:keyset)
      |> Ash.Query.page(limit: 100, count: true)
      |> apply_filter(filter)
      |> Ash.Query.sort(external_id: :desc)
      |> Ash.read!()

    {:ok, ash_read_query} =
      Fiostats.Transactions.Transaction
      |> Ash.Query.for_read(:read)
      |> apply_filter(filter)
      |> Ash.Query.data_layer_query()

    graph_data =
      ash_read_query
      |> Ecto.Query.subquery()
      |> Ecto.Query.select([p], [
        sum(p.amount),
        p.classification,
        fragment("date_part('month', ?)::int", p.date),
        fragment("date_part('year', ?)::int", p.date)
      ])
      |> Ecto.Query.group_by([p], [
        p.classification,
        fragment("date_part('month', ?)::int", p.date),
        fragment("date_part('year', ?)::int", p.date)
      ])
      |> Fiostats.Repo.all()

    %{payments: payments.results, payments_count: payments.count, graph_data: graph_data}
  end
end
