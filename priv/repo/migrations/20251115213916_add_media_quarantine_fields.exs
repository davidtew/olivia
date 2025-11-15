defmodule Olivia.Repo.Migrations.AddMediaQuarantineFields do
  use Ecto.Migration

  def change do
    alter table(:media) do
      add :status, :string, default: "quarantine", null: false
      add :asset_type, :string
      add :asset_role, :string
      add :metadata, :map, default: %{}
    end

    create index(:media, [:status])
    create index(:media, [:asset_type])
  end
end
