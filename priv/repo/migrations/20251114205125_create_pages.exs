defmodule Olivia.Repo.Migrations.CreatePages do
  use Ecto.Migration

  def change do
    create table(:pages) do
      add :slug, :string, null: false
      add :title, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:pages, [:slug])
  end
end
