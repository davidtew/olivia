defmodule Olivia.Repo.Migrations.CreateClientProjects do
  use Ecto.Migration

  def change do
    create table(:client_projects) do
      add :name, :string, null: false
      add :client_name, :string
      add :location, :string
      add :status, :string
      add :description_md, :text
      add :position, :integer, default: 0, null: false
      add :published, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:client_projects, [:published])
    create index(:client_projects, [:position])
    create index(:client_projects, [:status])
  end
end
