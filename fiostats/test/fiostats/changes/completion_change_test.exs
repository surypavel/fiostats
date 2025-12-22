defmodule Fiostats.Changes.CompletionChangeTest do
  use Fiostats.DataCase, async: true

  alias Fiostats.Changes.CompletionChange
  alias Fiostats.Transactions.Account

  setup do
    {:ok, _} = Account.create("1234567890", "Test Account", "rent_and_apartment_received")
    {:ok, _} = Account.create("51-1744430227", "Hyphenated", "ignored")
    :ok
  end

  test "account_classify/1 returns classification for known accounts" do
    assert "rent_and_apartment_received" = CompletionChange.account_classify("1234567890")
    assert "ignored" = CompletionChange.account_classify("51-1744430227")
  end

  test "account_classify/1 returns nil for unknown and invalid inputs" do
    assert nil == CompletionChange.account_classify(nil)
    assert nil == CompletionChange.account_classify("9999999999")
    assert nil == CompletionChange.account_classify("")
  end

  test "integrates with transaction classification workflow" do
    # Simulates the real workflow in CompletionChange.change/3
    transaction_account = "1234567890"
    bank_classification = CompletionChange.account_classify(transaction_account)

    # Should get classification for use in changeset
    assert bank_classification == "rent_and_apartment_received"
    assert is_binary(bank_classification)
  end
end
