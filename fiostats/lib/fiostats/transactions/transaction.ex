defmodule Fiostats.Transactions.Transaction do
  require Ash.Resource.Change.Builtins
  require Ash.Query
  require Ash.Sort

  use Ash.Resource,
    extensions: [AshAi, AshOban],
    domain: Fiostats.Transactions,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  vectorize do
    full_text do
      text(fn record ->
        """
        Comment of the card transaction: #{record.title}
        """
      end)

      used_attributes([:title])
    end

    strategy :ash_oban
    ash_oban_trigger_name(:my_vectorize_trigger)

    embedding_model(Fiostats.LLM.GeminiEmbedding)
  end

  oban do
    triggers do
      trigger :my_vectorize_trigger do
        action :ash_ai_update_embeddings
        worker_module_name __MODULE__.AshOban.Worker.UpdateEmbeddings
        scheduler_module_name __MODULE__.AshOban.Scheduler.UpdateEmbeddings
        worker_read_action :read_list
        record_limit 5
        where expr(is_nil(full_text_vector))
        scheduler_cron "* * * * *"
      end

      trigger :my_classification_trigger do
        action :calculate_classification
        worker_module_name __MODULE__.AshOban.Worker.UpdateClassification
        scheduler_module_name __MODULE__.AshOban.Scheduler.UpdateClassification
        worker_read_action :read_list
        record_limit 5
        sort external_id: :desc
        where expr(is_nil(classification) and not is_nil(full_text_vector))
        scheduler_cron "* * * * *"
      end
    end
  end

  postgres do
    table "transactions"
    repo Fiostats.Repo
  end

  actions do
    defaults [:destroy, :read]

    read :read_list do
      prepare build(load: :has_embedding?)

      pagination do
        required? false
        keyset? true
        countable true
      end
    end

    read :keyset do
      prepare build(sort: [external_id: :desc], load: :has_embedding?)
      pagination keyset?: true
    end

    read :similar do
      argument :vector, Ash.Type.Vector
      argument :except, :uuid

      filter expr(
               not is_nil(full_text_vector) and not is_nil(classification) and id != ^arg(:except)
             )

      filter expr(fragment("? <-> ? <= ?", ^arg(:vector), full_text_vector, 0.3))

      prepare build(
                load: {:distance, %{vector: arg(:vector)}},
                sort: [
                  distance: {%{vector: arg(:vector)}, :asc}
                ]
              )
    end

    create :create do
      primary? true
      accept [:date, :title, :amount, :original_json, :external_id, :account]
    end

    read :read_last do
      prepare build(sort: [external_id: :desc], limit: 1)
    end

    update :manually_set_classification do
      accept [:classification]

      change set_attribute(:validation_source, :human)
      change set_attribute(:classification_reason, nil)
      change set_attribute(:classification_based_on_id, nil)

      change Fiostats.Changes.HumanValidationChange
    end

    update :reset_classification do
      change set_attribute(:validation_source, nil)
      change set_attribute(:classification, nil)
      change set_attribute(:classification_reason, nil)
      change set_attribute(:classification_based_on_id, nil)
    end

    update :calculate_classification do
      require_atomic? false
      change Fiostats.Changes.CompletionChange
    end
  end

  pub_sub do
    module FiostatsWeb.Endpoint

    prefix "transactions"

    publish_all :update, [[:id, nil]]
    publish_all :create, [[:id, nil]]
    publish_all :destroy, [[:id, nil]]
  end

  attributes do
    uuid_primary_key :id

    attribute :external_id, :integer do
      allow_nil? false
    end

    attribute :date, :date do
      allow_nil? false
    end

    attribute :title, :ci_string do
      allow_nil? true
    end

    attribute :account, :string do
      allow_nil? true
    end

    attribute :amount, :decimal do
      allow_nil? false
    end

    attribute :original_json, :map

    attribute :classification, :string do
      allow_nil? true
    end

    attribute :classification_reason, :string do
      allow_nil? true
    end

    attribute :validation_source, Fiostats.Types.ValidationSource do
      allow_nil? true
    end
  end

  relationships do
    belongs_to :classification_based_on, Fiostats.Transactions.Transaction do
      attribute_type :uuid
      attribute_writable? true
    end
  end

  calculations do
    calculate :has_embedding?, :boolean, expr(not is_nil(full_text_vector))

    calculate :distance, :float do
      argument :vector, Ash.Type.Vector, allow_nil?: true

      calculation expr(
                    fragment(
                      "(?::vector <-> ?::vector)",
                      ^arg(:vector),
                      full_text_vector
                    )
                  )
    end
  end

  identities do
    identity :unique_external_id, [:external_id]
  end
end
