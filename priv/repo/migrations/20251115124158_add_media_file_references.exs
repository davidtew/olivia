defmodule Olivia.Repo.Migrations.AddMediaFileReferences do
  use Ecto.Migration

  def change do
    alter table(:media_images) do
      add :media_file_id, references(:media, on_delete: :nilify_all)
    end

    alter table(:artworks) do
      add :media_file_id, references(:media, on_delete: :nilify_all)
    end

    alter table(:series) do
      add :media_file_id, references(:media, on_delete: :nilify_all)
    end

    create index(:media_images, [:media_file_id])
    create index(:artworks, [:media_file_id])
    create index(:series, [:media_file_id])
  end
end
