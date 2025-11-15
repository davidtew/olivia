defmodule Olivia.Repo.Migrations.CreateSeries do
  use Ecto.Migration

  def change do
    create table(:series) do
      add :title, :string, null: false
      add :slug, :string, null: false
      add :summary, :text
      add :body_md, :text
      add :position, :integer, default: 0, null: false
      add :published, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:series, [:slug])
    create unique_index(:series, [:title])
    create index(:series, [:published])
    create index(:series, [:position])
  end
end
