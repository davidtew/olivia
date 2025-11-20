defmodule Olivia.Content.Series do
  use Ecto.Schema
  import Ecto.Changeset

  schema "series" do
    field :title, :string
    field :slug, :string
    field :summary, :string
    field :body_md, :string
    field :position, :integer, default: 0
    field :published, :boolean, default: false
    field :cover_image_url, :string

    belongs_to :media_file, Olivia.Media.MediaFile
    has_many :artworks, Olivia.Content.Artwork

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(series, attrs) do
    series
    |> cast(attrs, [:title, :slug, :summary, :body_md, :position, :published, :cover_image_url, :media_file_id])
    |> validate_required([:title])
    |> maybe_generate_slug()
    |> validate_required([:slug])
    |> unique_constraint(:title)
    |> unique_constraint(:slug)
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

  defp do_slugify(_), do: "series"

  # Public function for both internal and external use
  def slugify(str), do: do_slugify(str)

  @doc """
  Returns the resolved cover image URL for the series.
  Falls back to the first artwork's image if no cover_image_url is set.
  In production, prepends S3 URL to local paths.
  """
  def resolved_cover_image_url(%__MODULE__{cover_image_url: url}) when is_binary(url) and url != "" do
    OliviaWeb.AssetHelpers.resolve_asset_url(url)
  end

  def resolved_cover_image_url(%__MODULE__{artworks: artworks}) when is_list(artworks) do
    case artworks do
      [first | _] -> Olivia.Content.Artwork.resolved_image_url(first)
      [] -> nil
    end
  end

  def resolved_cover_image_url(_), do: nil
end
