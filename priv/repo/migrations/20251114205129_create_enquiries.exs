defmodule Olivia.Repo.Migrations.CreateEnquiries do
  use Ecto.Migration

  def change do
    create table(:enquiries) do
      add :type, :string, null: false
      add :name, :string, null: false
      add :email, :string, null: false
      add :message, :text, null: false
      add :meta, :map
      add :artwork_id, references(:artworks, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:enquiries, [:artwork_id])
    create index(:enquiries, [:type])
    create index(:enquiries, [:inserted_at])
  end
end
