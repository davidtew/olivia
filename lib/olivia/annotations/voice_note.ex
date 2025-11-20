defmodule Olivia.Annotations.VoiceNote do
  use Ecto.Schema
  import Ecto.Changeset

  schema "annotations" do
    field :audio_url, :string

    # New fields for multi-modal annotation support
    field :type, :string, default: "voice"
    field :content, :map, default: %{}

    field :anchor_key, :string
    field :anchor_meta, :map, default: %{}
    field :anchor_type, :string, default: "explicit"

    field :page_path, :string
    field :theme, :string

    field :visibility, :string, default: "private"
    field :group_id, :integer

    belongs_to :user, Olivia.Accounts.User

    timestamps()
  end

  @required ~w(audio_url anchor_key page_path theme)a
  @optional ~w(anchor_meta anchor_type visibility group_id user_id type content)a

  def changeset(voice_note, attrs) do
    voice_note
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> validate_inclusion(:visibility, ~w(private group public))
    |> validate_inclusion(:anchor_type, ~w(explicit computed))
    |> validate_inclusion(:type, ~w(voice text boolean rating))
  end
end
