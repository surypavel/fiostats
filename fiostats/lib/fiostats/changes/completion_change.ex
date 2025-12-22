defmodule Fiostats.Changes.CompletionChange do
  use Ash.Resource.Change

  def account_classify(nil), do: nil

  def account_classify(bank_account) do
    Fiostats.Transactions.Accounts.get_classification(bank_account)
  end

  def change(changeset, _opts, _) do
    data = changeset.data |> Ash.load!(:full_text_vector)
    bank_classification = data.account |> account_classify()

    case bank_classification do
      classification when is_binary(classification) ->
        changeset
        |> Ash.Changeset.change_attribute(:classification, classification)
        |> Ash.Changeset.change_attribute(:validation_source, :bank)
        |> Ash.Changeset.change_attribute(:classification_based_on_id, nil)
        |> Ash.Changeset.change_attribute(
          :classification_reason,
          "Found completion via bank account"
        )

      nil ->
        similar_transactions =
          Fiostats.Transactions.Transaction
          |> Ash.Query.for_read(:similar, %{
            vector: data.full_text_vector,
            except: data.id
          })
          |> Ash.read!()

        case similar_transactions do
          [best_match | _] ->
            changeset
            |> Ash.Changeset.change_attribute(:classification, best_match.classification)
            |> Ash.Changeset.change_attribute(:classification_based_on_id, best_match.id)
            |> Ash.Changeset.change_attribute(:validation_source, :embedding)
            |> Ash.Changeset.change_attribute(
              :classification_reason,
              "Found completion via best match."
            )

          _ ->
            case Fiostats.LLM.GeminiCompletion.generate(data.title) do
              {:ok, completion, reason} ->
                changeset
                |> Ash.Changeset.change_attribute(:classification, completion)
                |> Ash.Changeset.change_attribute(:classification_based_on_id, nil)
                |> Ash.Changeset.change_attribute(:validation_source, :llm)
                |> Ash.Changeset.change_attribute(:classification_reason, reason)

              {:error, reason} ->
                Ash.Changeset.add_error(changeset,
                  message: "Failed to get LLM completion: #{inspect(reason)}"
                )
            end
        end
    end
  end
end
