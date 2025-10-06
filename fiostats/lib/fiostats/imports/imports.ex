defmodule Fiostats.Imports do
  alias Fiostats.Imports.FioApi

  def read_from_file() do
    path = Path.join(:code.priv_dir(:fiostats), "response.json")

    data = File.read!(path) |> JSON.decode!()
    data |> Fiostats.Imports.FioParser.parse_payments()
  end

  def read_from_fio() do
    {:ok, [last_transaction]} = read_last_transaction()
    FioApi.set_last_id(last_transaction.external_id)

    with {:ok, json} <- FioApi.get_transactions_json() do
      {:ok, Fiostats.Imports.FioParser.parse_payments(json)}
    end
  end

  def insert_to_db(payments) do
    Ash.bulk_create(
      payments |> Enum.map(&make_payment(&1)),
      Fiostats.Transactions.Transaction,
      :create,
      transaction: :all
    )
  end

  def read_last_transaction() do
    Fiostats.Transactions.Transaction
    |> Ash.Query.for_read(:read_last)
    |> Ash.read()
  end

  def make_payment(payment) do
    %{
      date: payment.date,
      title: payment.comment,
      amount: payment.amount,
      original_json: payment.original_json,
      external_id: payment.external_id,
      account: payment.account
    }
  end
end
