defmodule Olivia.Repo.Migrations.CreateMedia do
  use Ecto.Migration

  def change do
    create table(:media) do
      add :filename, :string, null: false
      add :url, :string, null: false
      add :content_type, :string
      add :file_size, :integer
      add :width, :integer
      add :height, :integer
      add :alt_text, :string
      add :caption, :text
      add :tags, {:array, :string}, default: []
      add :user_id, references(:users, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:media, [:user_id])
    create index(:media, [:tags], using: :gin)
    create index(:media, [:inserted_at])
  end
end
