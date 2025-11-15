defmodule Olivia.Media.MediaFile do
  use Ecto.Schema
  import Ecto.Changeset

  @statuses ~w(quarantine approved archived)
  @asset_types ~w(artwork brand audio video document)

  schema "media" do
    field :filename, :string
    field :url, :string
    field :content_type, :string
    field :file_size, :integer
    field :width, :integer
    field :height, :integer
    field :alt_text, :string
    field :caption, :string
    field :tags, {:array, :string}, default: []

    # Quarantine and classification fields
    field :status, :string, default: "quarantine"
    field :asset_type, :string
    field :asset_role, :string
    field :metadata, :map, default: %{}

    belongs_to :user, Olivia.Accounts.User
    has_many :artworks, Olivia.Content.Artwork
    has_many :series, Olivia.Content.Series
    has_many :images, Olivia.Media.Image

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(media_file, attrs) do
    media_file
    |> cast(attrs, [
      :filename,
      :url,
      :content_type,
      :file_size,
      :width,
      :height,
      :alt_text,
      :caption,
      :tags,
      :user_id,
      :status,
      :asset_type,
      :asset_role,
      :metadata
    ])
    |> validate_required([:filename, :url])
    |> validate_length(:alt_text, max: 255)
    |> validate_inclusion(:status, @statuses)
    |> maybe_auto_approve()
  end

  # Auto-approve if sufficient metadata is provided
  defp maybe_auto_approve(changeset) do
    status = get_field(changeset, :status)
    asset_type = get_field(changeset, :asset_type)
    alt_text = get_field(changeset, :alt_text)

    # If asset_type and alt_text are present, auto-approve
    if status == "quarantine" && asset_type && alt_text do
      put_change(changeset, :status, "approved")
    else
      changeset
    end
  end

  def statuses, do: @statuses
  def asset_types, do: @asset_types
end
