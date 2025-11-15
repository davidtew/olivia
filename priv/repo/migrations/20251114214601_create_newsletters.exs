defmodule Olivia.Repo.Migrations.CreateNewsletters do
  use Ecto.Migration

  def change do
    create table(:newsletters) do
      add :subject, :string, null: false
      add :body_md, :text, null: false
      add :status, :string, null: false, default: "draft"
      add :sent_at, :utc_datetime
      add :sent_count, :integer, default: 0
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:newsletters, [:user_id])
    create index(:newsletters, [:status])
    create index(:newsletters, [:sent_at])
  end
end
