defmodule Olivia.Press do
  @moduledoc """
  The Press context - manages press features and media mentions.
  """

  import Ecto.Query, warn: false
  alias Olivia.Repo
  alias Olivia.Press.PressFeature

  @doc """
  Returns the list of press features.

  ## Options
    * `:published` - Filter by published status (true/false)
  """
  def list_press_features(opts \\ []) do
    PressFeature
    |> apply_filters(opts)
    |> order_by([p], [desc: p.date, asc: p.position])
    |> Repo.all()
  end

  @doc """
  Lists published press features, ordered by date.
  """
  def list_published_press do
    list_press_features(published: true)
  end

  defp apply_filters(query, opts) do
    Enum.reduce(opts, query, fn
      {:published, published}, query ->
        where(query, [p], p.published == ^published)

      _, query ->
        query
    end)
  end

  @doc """
  Gets a single press feature.

  Raises `Ecto.NoResultsError` if the Press feature does not exist.
  """
  def get_press_feature!(id), do: Repo.get!(PressFeature, id)

  @doc """
  Creates a press feature.
  """
  def create_press_feature(attrs \\ %{}) do
    %PressFeature{}
    |> PressFeature.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a press feature.
  """
  def update_press_feature(%PressFeature{} = press_feature, attrs) do
    press_feature
    |> PressFeature.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a press feature.
  """
  def delete_press_feature(%PressFeature{} = press_feature) do
    Repo.delete(press_feature)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking press feature changes.
  """
  def change_press_feature(%PressFeature{} = press_feature, attrs \\ %{}) do
    PressFeature.changeset(press_feature, attrs)
  end
end
