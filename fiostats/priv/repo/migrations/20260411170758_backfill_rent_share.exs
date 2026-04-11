defmodule Fiostats.Repo.Migrations.BackfillRentShare do
  use Ecto.Migration

  def up do
    execute("UPDATE transactions SET share = 3 WHERE classification = 'rent_and_apartment'")
  end

  def down do
    execute("UPDATE transactions SET share = 1 WHERE classification = 'rent_and_apartment'")
  end
end
