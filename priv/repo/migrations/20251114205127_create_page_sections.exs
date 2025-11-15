defmodule Olivia.Repo.Migrations.CreatePageSections do
  use Ecto.Migration

  def change do
    create table(:page_sections) do
      add :key, :string, null: false
      add :content_md, :text
      add :position, :integer, default: 0, null: false
      add :page_id, references(:pages, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:page_sections, [:page_id])
    create unique_index(:page_sections, [:page_id, :key])
    create index(:page_sections, [:position])
  end
end
