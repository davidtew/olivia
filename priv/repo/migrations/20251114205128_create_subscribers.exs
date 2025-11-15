defmodule Olivia.Repo.Migrations.CreateSubscribers do
  use Ecto.Migration

  def change do
    create table(:subscribers) do
      add :email, :citext, null: false
      add :source, :string, default: "website_form"

      timestamps(type: :utc_datetime)
    end

    create unique_index(:subscribers, [:email])
  end
end
