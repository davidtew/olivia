defmodule Olivia.Repo.Migrations.CreateVoiceNotes do
  use Ecto.Migration

  def change do
    create table(:voice_notes) do
      add :audio_url, :string, null: false

      add :anchor_key, :string, null: false
      add :anchor_meta, :map, null: false, default: %{}
      add :anchor_type, :string, null: false, default: "explicit"

      add :page_path, :string, null: false
      add :theme, :string, null: false

      add :visibility, :string, null: false, default: "private"
      add :group_id, :bigint

      add :user_id, references(:users, on_delete: :nilify_all)

      timestamps()
    end

    create index(:voice_notes, [:page_path, :theme])
    create index(:voice_notes, [:anchor_key])
    create index(:voice_notes, [:user_id])
    create index(:voice_notes, [:group_id])
  end
end
