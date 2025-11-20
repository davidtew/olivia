defmodule Olivia.Repo.Migrations.RenameVoiceNotesToAnnotations do
  use Ecto.Migration

  def up do
    # Rename table
    rename table(:voice_notes), to: table(:annotations)

    # Add new columns for multi-modal annotation support
    alter table(:annotations) do
      add :type, :string, default: "voice", null: false
      add :content, :jsonb, default: "{}", null: false
    end

    # Backfill existing voice notes: move audio_url into content field
    execute """
    UPDATE annotations
    SET content = jsonb_build_object('audio_url', audio_url)
    WHERE content = '{}'::jsonb
    """

    # Create index on type for efficient filtering
    create index(:annotations, [:type])
  end

  def down do
    # Remove the new columns
    alter table(:annotations) do
      remove :type
      remove :content
    end

    # Rename table back
    rename table(:annotations), to: table(:voice_notes)
  end
end
