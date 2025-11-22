defmodule Olivia.Repo.Migrations.MakeAudioUrlNullable do
  use Ecto.Migration

  def change do
    alter table(:annotations) do
      modify :audio_url, :text, null: true, from: {:text, null: false}
    end
  end
end
