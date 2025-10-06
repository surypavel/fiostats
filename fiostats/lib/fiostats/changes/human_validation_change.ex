defmodule Fiostats.Changes.HumanValidationChange do
  use Ash.Resource.Change

  def reset_neighbours(_changeset, record, _context) do
    updated_transaction = record |> Ash.load!(:full_text_vector)

    Fiostats.Transactions.Transaction
    |> Ash.Query.for_read(:similar, %{
      vector: updated_transaction.full_text_vector,
      except: updated_transaction.id
    })
    |> Ash.Query.filter(validation_source == :embedding or validation_source == :llm)
    |> Ash.bulk_update(:reset_classification, %{})

    {:ok, record}
  end

  def change(changeset, _, context) do
    Ash.Changeset.after_action(changeset, &reset_neighbours(&1, &2, context))
  end

  def atomic(changeset, opts, context) do
    {:ok, change(changeset, opts, context)}
  end
end
