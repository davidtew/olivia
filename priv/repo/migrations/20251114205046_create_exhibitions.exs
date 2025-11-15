defmodule Olivia.Repo.Migrations.CreateExhibitions do
  use Ecto.Migration

  def change do
    create table(:exhibitions) do
      add :title, :string, null: false
      add :venue, :string
      add :city, :string
      add :country, :string
      add :start_date, :date
      add :end_date, :date
      add :description_md, :text
      add :position, :integer, default: 0, null: false
      add :published, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:exhibitions, [:published])
    create index(:exhibitions, [:position])
    create index(:exhibitions, [:start_date])
  end
end
