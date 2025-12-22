# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Fiostats.Repo.insert!(%Fiostats.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Fiostats.Transactions.Account

# Seed accounts from the old hardcoded list
# Note: Duplicate account number "51-1744430227" appears in the old list
# (both :zalohy_acc and :najem_old with same classification), keeping only one entry
accounts_data = [
  %{account_number: "2661060093", name: "Standa", classification: "rent_and_apartment_received"},
  %{account_number: "261427504", name: "Emil", classification: "rent_and_apartment_received"},
  %{account_number: "4042500001", name: "Degiro", classification: "ignored"},
  %{account_number: "2590410104", name: "Degiro CZ", classification: "ignored"},
  %{account_number: "242807376", name: "Moneta Old", classification: "ignored"},
  %{account_number: "251615456", name: "Moneta", classification: "ignored"},
  %{account_number: "243559351", name: "Moneta Bezny", classification: "ignored"},
  %{account_number: "2702252834", name: "FIO Sporici", classification: "ignored"},
  %{account_number: "2502252821", name: "FIO Konto", classification: "ignored"},
  %{account_number: "2600133623", name: "JT", classification: "ignored"},
  %{account_number: "51-1744430227", name: "Zalohy", classification: "rent_and_apartment"},
  %{account_number: "2202935348", name: "Otec", classification: "ignored"},
  %{account_number: "1085940011", name: "Ondra", classification: "rent"},
  %{account_number: "1800304007", name: "Invest", classification: "ignored"},
  %{account_number: "330593013", name: "Tata", classification: "ignored"},
  %{account_number: "274378289", name: "Potehy", classification: "ignored"},
  %{account_number: "317150293", name: "Rossum", classification: "earnings"},
  %{account_number: "131-1106640297", name: "Najem", classification: "rent_and_apartment"}
]

Enum.each(accounts_data, fn attrs ->
  case Account.by_account_number(attrs.account_number) do
    {:ok, _existing} ->
      IO.puts("Account #{attrs.account_number} (#{attrs.name}) already exists, skipping...")

    {:error, _} ->
      Account.create!(attrs.account_number, attrs.name, attrs.classification)
      IO.puts("Created account: #{attrs.name} (#{attrs.account_number})")
  end
end)
