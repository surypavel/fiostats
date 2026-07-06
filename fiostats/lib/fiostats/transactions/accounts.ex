defmodule Fiostats.Transactions.Accounts do
  @moduledoc """
  Functions for working with bank accounts used for transaction classification.

  Previously hardcoded, now database-backed via Fiostats.Transactions.Account resource.
  """

  alias Fiostats.Transactions.Account

  @doc """
  Returns all accounts in the legacy tuple format for backwards compatibility.

  Returns list of tuples: `{atom_key, account_number, classification}`

  This format is deprecated. Use `list_accounts/0` for the new format.
  """
  def get_options do
    Account
    |> Ash.read!()
    |> Enum.map(fn account ->
      # Convert name to atom key (e.g., "Standa" -> :standa)
      atom_key =
        account.name
        |> String.downcase()
        |> String.replace(" ", "_")
        |> String.to_atom()

      {atom_key, account.account_number, account.classification}
    end)
  end

  @doc """
  Returns all accounts as Account structs.
  """
  def list_accounts do
    Account.list_active!()
  end

  @doc """
  Finds an account by account number.
  Returns `{:ok, account}` or `{:error, :not_found}`.
  """
  def find_by_account_number(account_number) when is_binary(account_number) do
    case Account.by_account_number(account_number) do
      {:ok, account} -> {:ok, account}
      {:error, _} -> {:error, :not_found}
    end
  end

  def find_by_account_number(nil), do: {:error, :not_found}

  @doc """
  Gets the classification for a given account number.
  Returns the classification string or nil if not found.
  """
  def get_classification(account_number) do
    case find_by_account_number(account_number) do
      {:ok, account} -> account.classification
      {:error, :not_found} -> nil
    end
  end
end
