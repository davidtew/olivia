defmodule Olivia.Repo.Migrations.CreateArtworks do
  use Ecto.Migration

  def change do
    create table(:artworks) do
      add :title, :string, null: false
      add :slug, :string, null: false
      add :year, :integer
      add :medium, :string
      add :dimensions, :string
      add :status, :string, null: false, default: "available"
      add :price_cents, :integer
      add :currency, :string, default: "GBP"
      add :location, :string
      add :description_md, :text
      add :position, :integer, default: 0, null: false
      add :featured, :boolean, default: false, null: false
      add :published, :boolean, default: false, null: false
      add :series_id, references(:series, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:artworks, [:slug])
    create index(:artworks, [:series_id])
    create index(:artworks, [:status])
    create index(:artworks, [:featured])
    create index(:artworks, [:published])
    create index(:artworks, [:position])
  end
end
