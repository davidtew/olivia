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

    # Thumbnail and processing fields
    field :thumb_url, :string
    field :medium_url, :string
    field :phash, :string

    belongs_to :user, Olivia.Accounts.User
    has_many :artworks, Olivia.Content.Artwork
    has_many :series, Olivia.Content.Series
    has_many :images, Olivia.Media.Image
    has_many :analyses, Olivia.Media.Analysis, foreign_key: :media_file_id
    has_many :duplicates, Olivia.Media.Duplicate, foreign_key: :source_media_id
    has_many :review_notes, Olivia.Media.ReviewNote, foreign_key: :media_id

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
      :metadata,
      :thumb_url,
      :medium_url,
      :phash
    ])
    |> validate_required([:filename, :url])
    |> validate_length(:alt_text, max: 255)
    |> validate_inclusion(:status, @statuses)
  end

  def statuses, do: @statuses
  def asset_types, do: @asset_types

  @doc """
  Returns the resolved URL for the media file.
  In production, prepends S3 URL to local paths.
  """
  def resolved_url(%__MODULE__{url: url}), do: OliviaWeb.AssetHelpers.resolve_asset_url(url)
  def resolved_url(_), do: nil

  @doc """
  Returns the resolved thumbnail URL for the media file.
  """
  def resolved_thumb_url(%__MODULE__{thumb_url: url}), do: OliviaWeb.AssetHelpers.resolve_asset_url(url)
  def resolved_thumb_url(_), do: nil

  @doc """
  Returns the resolved medium URL for the media file.
  """
  def resolved_medium_url(%__MODULE__{medium_url: url}), do: OliviaWeb.AssetHelpers.resolve_asset_url(url)
  def resolved_medium_url(_), do: nil
end
