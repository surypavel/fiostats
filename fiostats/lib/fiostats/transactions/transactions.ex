defmodule Fiostats.Transactions do
  use Ash.Domain

  resources do
    resource Fiostats.Transactions.Transaction
  end
end
