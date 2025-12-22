defmodule Fiostats.Transactions do
  use Ash.Domain

  resources do
    resource Fiostats.Transactions.Transaction
    resource Fiostats.Transactions.Account
  end
end
