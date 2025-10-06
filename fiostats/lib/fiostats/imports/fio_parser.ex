defmodule Fiostats.Imports.FioParser do
  def parse_payments(data) do
    transactions = data["accountStatement"]["transactionList"]["transaction"]

    classified_transactions =
      transactions
      |> Enum.map(fn t ->
        %{
          amount: t["column1"]["value"],
          date: t["column0"]["value"] |> String.slice(0, 10) |> Date.from_iso8601!(),
          external_id: t["column22"]["value"],
          comment: t["column25"]["value"],
          account: t["column2"]["value"],
          original_json: t
        }
      end)
      |> Enum.filter(fn t -> Date.compare(t.date, ~D[2020-01-01]) == :gt end)

    classified_transactions
  end
end
