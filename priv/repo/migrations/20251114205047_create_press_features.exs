defmodule Olivia.Repo.Migrations.CreatePressFeatures do
  use Ecto.Migration

  def change do
    create table(:press_features) do
      add :title, :string, null: false
      add :publication, :string
      add :issue, :string
      add :date, :date
      add :url, :string
      add :excerpt_md, :text
      add :position, :integer, default: 0, null: false
      add :published, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:press_features, [:published])
    create index(:press_features, [:position])
    create index(:press_features, [:date])
  end
end
