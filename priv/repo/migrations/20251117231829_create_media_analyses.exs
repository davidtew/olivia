defmodule Olivia.Repo.Migrations.CreateMediaAnalyses do
  use Ecto.Migration

  def change do
    create table(:media_analyses) do
      add :media_file_id, references(:media, on_delete: :delete_all), null: false
      add :iteration, :integer, null: false
      add :user_context, :text
      add :llm_response, :map, default: %{}
      add :model_used, :string

      timestamps(type: :utc_datetime)
    end

    create index(:media_analyses, [:media_file_id])
    create index(:media_analyses, [:iteration])
    create unique_index(:media_analyses, [:media_file_id, :iteration])
  end
end
