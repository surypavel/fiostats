defmodule Fiostats.Repo.Migrations.NewFullTextVector do
  use Ecto.Migration

  def change do
    rename table(:transactions), :full_text_vector, to: :full_text_vector_old

    alter table(:transactions) do
      add :full_text_vector, :vector, size: 768
    end
  end
end
