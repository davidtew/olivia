defmodule Olivia.Repo.Migrations.CreateMediaImages do
  use Ecto.Migration

  def change do
    create table(:media_images) do
      add :role, :string, null: false, default: "main"
      add :original_url, :string, null: false
      add :large_url, :string
      add :medium_url, :string
      add :thumb_url, :string
      add :alt_text, :string
      add :position, :integer, default: 0, null: false
      add :artwork_id, references(:artworks, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:media_images, [:artwork_id])
    create index(:media_images, [:role])
    create index(:media_images, [:position])
  end
end
