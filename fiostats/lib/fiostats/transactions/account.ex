defmodule Fiostats.Transactions.Account do
  @moduledoc """
  Represents a bank account used for transaction classification.

  Accounts are matched against the `account` field in transactions to automatically
  classify transactions based on the account number. This replaces the previous
  hardcoded list and allows dynamic management of accounts through the database.
  """

  use Ash.Resource,
    domain: Fiostats.Transactions,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "accounts"
    repo Fiostats.Repo
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true
      accept [:account_number, :name, :classification]
    end

    update :update do
      primary? true
      accept [:account_number, :name, :classification]
    end

    read :by_account_number do
      description "Find an account by its account number"
      argument :account_number, :string, allow_nil?: false
      get? true
      filter expr(account_number == ^arg(:account_number))
    end

    read :list_active do
      description "List all accounts sorted by name"
      prepare build(sort: [name: :asc])
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :account_number, :string do
      allow_nil? false
      description "The bank account number to match against transaction.account"
    end

    attribute :name, :string do
      allow_nil? false
      description "Human-readable label for the account (e.g., 'Standa', 'FIO Sporici')"
    end

    attribute :classification, :string do
      allow_nil? false
      description "The classification to apply when this account is matched"
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  identities do
    identity :unique_account_number, [:account_number]
  end

  code_interface do
    define :create, args: [:account_number, :name, :classification]
    define :update, args: [:account_number, :name, :classification]
    define :by_account_number, args: [:account_number]
    define :list_active
    define :read
    define :destroy
  end
end
