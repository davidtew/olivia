defmodule Olivia.Repo.Migrations.AddQuarantineEnhancements do
  use Ecto.Migration

  def change do
    # Add thumbnail URL to media table
    alter table(:media) do
      add :thumb_url, :string
      add :medium_url, :string
      # Store perceptual hash for duplicate detection
      add :phash, :string
    end

    # Create index for duplicate detection
    create index(:media, [:phash])

    # Create table for duplicate detection results
    create table(:media_duplicates) do
      add :source_media_id, references(:media, on_delete: :delete_all), null: false
      add :target_media_id, references(:media, on_delete: :delete_all), null: false
      add :similarity_score, :float, null: false
      add :detection_method, :string, default: "phash"

      timestamps(type: :utc_datetime)
    end

    create index(:media_duplicates, [:source_media_id])
    create index(:media_duplicates, [:target_media_id])
    create unique_index(:media_duplicates, [:source_media_id, :target_media_id])

    # Create table for review notes/audit trail
    create table(:media_review_notes) do
      add :media_id, references(:media, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :nilify_all)
      add :action, :string, null: false
      add :note, :text
      add :previous_status, :string
      add :new_status, :string

      timestamps(type: :utc_datetime)
    end

    create index(:media_review_notes, [:media_id])
    create index(:media_review_notes, [:user_id])
  end
end
