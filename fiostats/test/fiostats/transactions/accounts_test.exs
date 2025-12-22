defmodule Fiostats.Transactions.AccountsTest do
  use Fiostats.DataCase, async: true

  alias Fiostats.Transactions.{Account, Accounts}

  setup do
    {:ok, account1} = Account.create("1234567890", "Test Account", "rent_and_apartment_received")
    {:ok, account2} = Account.create("0987654321", "Another Account", "earnings")
    %{account1: account1, account2: account2}
  end

  test "get_classification/1 returns correct classification" do
    assert "rent_and_apartment_received" = Accounts.get_classification("1234567890")
    assert "earnings" = Accounts.get_classification("0987654321")
    assert nil == Accounts.get_classification("9999999999")
    assert nil == Accounts.get_classification(nil)
  end

  test "get_options/0 returns legacy tuple format for backwards compatibility" do
    options = Accounts.get_options()

    assert is_list(options)
    assert length(options) == 2

    # Verify tuple structure matches old format
    for {atom_key, account_number, classification} <- options do
      assert is_atom(atom_key)
      assert is_binary(account_number)
      assert is_binary(classification)
    end

    # Verify can be used with old Enum.find pattern
    found = Enum.find(options, fn {_, acc, _} -> acc == "1234567890" end)
    assert {_atom_key, "1234567890", "rent_and_apartment_received"} = found
  end
end
