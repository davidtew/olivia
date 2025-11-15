defmodule Olivia.Media.Image do
  use Ecto.Schema
  import Ecto.Changeset

  @roles ~w(main detail in_situ)

  schema "media_images" do
    field :role, :string, default: "main"
    field :original_url, :string
    field :large_url, :string
    field :medium_url, :string
    field :thumb_url, :string
    field :alt_text, :string
    field :position, :integer, default: 0

    belongs_to :artwork, Olivia.Content.Artwork
    belongs_to :media_file, Olivia.Media.MediaFile

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(image, attrs) do
    image
    |> cast(attrs, [
      :role,
      :original_url,
      :large_url,
      :medium_url,
      :thumb_url,
      :alt_text,
      :position,
      :artwork_id,
      :media_file_id
    ])
    |> validate_required([:role, :original_url, :artwork_id])
    |> validate_inclusion(:role, @roles)
    |> foreign_key_constraint(:artwork_id)
    |> foreign_key_constraint(:media_file_id)
  end

  def roles, do: @roles
end
