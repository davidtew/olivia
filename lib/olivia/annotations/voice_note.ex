defmodule Olivia.Annotations.VoiceNote do
  use Ecto.Schema
  import Ecto.Changeset

  schema "voice_notes" do
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

  @required ~w(anchor_key page_path theme type)a
  @optional ~w(audio_url anchor_meta anchor_type visibility group_id user_id content)a

  def changeset(voice_note, attrs) do
    voice_note
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> validate_inclusion(:visibility, ~w(private group public))
    |> validate_inclusion(:anchor_type, ~w(explicit computed))
    |> validate_inclusion(:type, ~w(voice text boolean rating))
    |> validate_annotation_content()
  end

  defp validate_annotation_content(changeset) do
    type = get_field(changeset, :type)
    audio_url = get_field(changeset, :audio_url)
    content = get_field(changeset, :content)

    cond do
      type == "voice" and is_nil(audio_url) ->
        add_error(changeset, :audio_url, "is required for voice annotations")

      type == "text" and (is_nil(content) or content == %{}) ->
        add_error(changeset, :content, "is required for text annotations")

      true ->
        changeset
    end
  end
end
