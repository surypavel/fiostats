defmodule Fiostats.Transactions.AccountTest do
  use Fiostats.DataCase, async: true

  alias Fiostats.Transactions.Account

  describe "CRUD operations" do
    test "creates and finds account with all attributes" do
      assert {:ok, account} =
               Account.create("1234567890", "Test Account", "rent_and_apartment_received")

      assert account.account_number == "1234567890"
      assert account.name == "Test Account"
      assert account.classification == "rent_and_apartment_received"

      # Verify we can find it
      assert {:ok, found} = Account.by_account_number("1234567890")
      assert found.id == account.id
    end

    test "enforces unique account numbers" do
      {:ok, _account} = Account.create("1234567890", "First", "ignored")

      assert {:error, %Ash.Error.Invalid{}} =
               Account.create("1234567890", "Duplicate", "earnings")
    end

    test "updates and deletes accounts" do
      {:ok, account} = Account.create("1234567890", "Original", "ignored")

      # Update
      assert {:ok, updated} =
               Account.update(account, "1234567890", "Updated Name", "earnings")

      assert updated.name == "Updated Name"
      assert updated.classification == "earnings"

      # Delete
      assert :ok = Account.destroy(updated)
      assert {:error, %Ash.Error.Invalid{}} = Account.by_account_number("1234567890")
    end
  end

  describe "edge cases" do
    test "handles hyphenated account numbers" do
      assert {:ok, account} =
               Account.create("51-1744430227", "Hyphenated", "rent_and_apartment")

      assert {:ok, found} = Account.by_account_number("51-1744430227")
      assert found.id == account.id
    end

    test "returns error for non-existent accounts" do
      assert {:error, %Ash.Error.Invalid{}} =
               Account.by_account_number("9999999999")
    end
  end
end
