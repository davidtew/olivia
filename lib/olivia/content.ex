defmodule Olivia.Content do
  @moduledoc """
  The Content context - manages Series and Artworks.
  """

  import Ecto.Query, warn: false
  alias Olivia.Repo
  alias Olivia.Content.{Series, Artwork}
  alias Olivia.Media.Image

  ## Series

  @doc """
  Returns the list of series.

  ## Options
    * `:published` - Filter by published status (true/false)
    * `:preload` - List of associations to preload
  """
  def list_series(opts \\ []) do
    Series
    |> apply_series_filters(opts)
    |> order_by([s], [asc: s.position, asc: s.title])
    |> maybe_preload(opts)
    |> Repo.all()
  end

  defp apply_series_filters(query, opts) do
    Enum.reduce(opts, query, fn
      {:published, published}, query ->
        where(query, [s], s.published == ^published)

      _, query ->
        query
    end)
  end

  @doc """
  Gets a single series.

  Raises `Ecto.NoResultsError` if the Series does not exist.
  """
  def get_series!(id, opts \\ []) do
    Series
    |> maybe_preload(opts)
    |> Repo.get!(id)
  end

  @doc """
  Gets a series by slug.

  Raises `Ecto.NoResultsError` if the Series does not exist.
  """
  def get_series_by_slug!(slug, opts \\ []) do
    Series
    |> where([s], s.slug == ^slug)
    |> maybe_preload(opts)
    |> Repo.one!()
  end

  @doc """
  Creates a series.
  """
  def create_series(attrs \\ %{}) do
    %Series{}
    |> Series.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a series.
  """
  def update_series(%Series{} = series, attrs) do
    series
    |> Series.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a series.
  """
  def delete_series(%Series{} = series) do
    Repo.delete(series)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking series changes.
  """
  def change_series(%Series{} = series, attrs \\ %{}) do
    Series.changeset(series, attrs)
  end

  ## Artworks

  @doc """
  Returns the list of artworks.

  ## Options
    * `:published` - Filter by published status
    * `:featured` - Filter by featured status
    * `:status` - Filter by status (:available, :sold, :reserved)
    * `:series_id` - Filter by series
    * `:preload` - List of associations to preload
  """
  def list_artworks(opts \\ []) do
    Artwork
    |> apply_artwork_filters(opts)
    |> order_by([a], [asc: a.position, asc: a.title])
    |> maybe_preload(opts)
    |> Repo.all()
  end

  defp apply_artwork_filters(query, opts) do
    Enum.reduce(opts, query, fn
      {:published, published}, query ->
        where(query, [a], a.published == ^published)

      {:featured, featured}, query ->
        where(query, [a], a.featured == ^featured)

      {:status, status}, query when is_atom(status) ->
        where(query, [a], a.status == ^to_string(status))

      {:status, status}, query ->
        where(query, [a], a.status == ^status)

      {:series_id, series_id}, query ->
        where(query, [a], a.series_id == ^series_id)

      _, query ->
        query
    end)
  end

  @doc """
  Gets a single artwork.

  Raises `Ecto.NoResultsError` if the Artwork does not exist.
  """
  def get_artwork!(id, opts \\ []) do
    Artwork
    |> maybe_preload(opts)
    |> Repo.get!(id)
  end

  @doc """
  Gets an artwork by slug.

  Raises `Ecto.NoResultsError` if the Artwork does not exist.
  """
  def get_artwork_by_slug!(slug, opts \\ []) do
    Artwork
    |> where([a], a.slug == ^slug)
    |> maybe_preload(opts)
    |> Repo.one!()
  end

  @doc """
  Lists artworks for a specific series.
  """
  def list_artworks_for_series(series_id, opts \\ []) do
    opts
    |> Keyword.put(:series_id, series_id)
    |> list_artworks()
  end

  @doc """
  Lists featured artworks (for home page hero, etc).
  """
  def list_featured_artworks(opts \\ []) do
    opts
    |> Keyword.put(:featured, true)
    |> list_artworks()
  end

  @doc """
  Lists available artworks (for collection page).
  """
  def list_available_artworks(opts \\ []) do
    opts
    |> Keyword.put(:status, :available)
    |> list_artworks()
  end

  @doc """
  Creates an artwork.
  """
  def create_artwork(attrs \\ %{}) do
    %Artwork{}
    |> Artwork.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an artwork.
  """
  def update_artwork(%Artwork{} = artwork, attrs) do
    artwork
    |> Artwork.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes an artwork.
  """
  def delete_artwork(%Artwork{} = artwork) do
    Repo.delete(artwork)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking artwork changes.
  """
  def change_artwork(%Artwork{} = artwork, attrs \\ %{}) do
    Artwork.changeset(artwork, attrs)
  end

  ## Images

  @doc """
  Creates an image for an artwork.
  """
  def create_image(attrs \\ %{}) do
    %Image{}
    |> Image.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an image.
  """
  def update_image(%Image{} = image, attrs) do
    image
    |> Image.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes an image.
  """
  def delete_image(%Image{} = image) do
    Repo.delete(image)
  end

  @doc """
  Lists images for an artwork.
  """
  def list_images_for_artwork(artwork_id) do
    Image
    |> where([i], i.artwork_id == ^artwork_id)
    |> order_by([i], [asc: i.position, asc: i.inserted_at])
    |> Repo.all()
  end

  @doc """
  Gets the main image for an artwork.
  """
  def get_main_image(artwork_id) do
    Image
    |> where([i], i.artwork_id == ^artwork_id and i.role == "main")
    |> order_by([i], asc: i.position)
    |> limit(1)
    |> Repo.one()
  end

  ## Helpers

  defp maybe_preload(query, opts) do
    case Keyword.get(opts, :preload) do
      nil -> query
      preloads -> from(q in query, preload: ^preloads)
    end
  end
end
