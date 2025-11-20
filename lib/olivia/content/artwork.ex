defmodule Olivia.Content.Artwork do
  use Ecto.Schema
  import Ecto.Changeset

  @statuses ~w(available sold reserved)

  schema "artworks" do
    field :title, :string
    field :slug, :string
    field :year, :integer
    field :medium, :string
    field :dimensions, :string
    field :status, :string, default: "available"
    field :price_cents, :integer
    field :currency, :string, default: "GBP"
    field :location, :string
    field :description_md, :string
    field :position, :integer, default: 0
    field :featured, :boolean, default: false
    field :published, :boolean, default: false
    field :image_url, :string

    belongs_to :series, Olivia.Content.Series
    belongs_to :media_file, Olivia.Media.MediaFile
    has_many :images, Olivia.Media.Image

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(artwork, attrs) do
    artwork
    |> cast(attrs, [
      :title,
      :slug,
      :year,
      :medium,
      :dimensions,
      :status,
      :price_cents,
      :currency,
      :location,
      :description_md,
      :position,
      :featured,
      :published,
      :image_url,
      :series_id,
      :media_file_id
    ])
    |> validate_required([:title, :status])
    |> validate_inclusion(:status, @statuses)
    |> maybe_generate_slug()
    |> validate_required([:slug])
    |> unique_constraint(:slug)
    |> foreign_key_constraint(:series_id)
    |> foreign_key_constraint(:media_file_id)
  end

  defp maybe_generate_slug(changeset) do
    slug = get_change(changeset, :slug)

    case slug do
      s when s in [nil, ""] ->
        case get_change(changeset, :title) do
          nil -> changeset
          "" -> changeset
          title -> put_change(changeset, :slug, slugify(title))
        end

      _slug ->
        changeset
    end
  end

  defp do_slugify(str) when is_binary(str) do
    str
    |> String.downcase()
    |> String.replace(~r/[^\w\s-]/, "")
    |> String.replace(~r/\s+/, "-")
    |> String.replace(~r/-+/, "-")
    |> String.trim("-")
  end

  defp do_slugify(_), do: "artwork"

  # Public function for both internal and external use
  def slugify(str), do: do_slugify(str)

  def statuses, do: @statuses

  @doc """
  Returns the resolved image URL for the artwork.
  In production, prepends S3 URL to local paths.
  """
  def resolved_image_url(%__MODULE__{image_url: url}), do: OliviaWeb.AssetHelpers.resolve_asset_url(url)
  def resolved_image_url(_), do: nil
end
