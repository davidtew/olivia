defmodule Olivia.Repo.Migrations.AddImageUrlsToArtworksAndSeries do
  use Ecto.Migration

  def change do
    alter table(:artworks) do
      add :image_url, :text
    end

    alter table(:series) do
      add :cover_image_url, :text
    end
  end
end
