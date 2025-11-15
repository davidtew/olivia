defmodule Olivia.Exhibitions do
  @moduledoc """
  The Exhibitions context - manages exhibition records.
  """

  import Ecto.Query, warn: false
  alias Olivia.Repo
  alias Olivia.Exhibitions.Exhibition

  @doc """
  Returns the list of exhibitions.

  ## Options
    * `:published` - Filter by published status (true/false)
  """
  def list_exhibitions(opts \\ []) do
    Exhibition
    |> apply_filters(opts)
    |> order_by([e], [desc: e.start_date, asc: e.position])
    |> Repo.all()
  end

  @doc """
  Lists published exhibitions, ordered by date.
  """
  def list_published_exhibitions do
    list_exhibitions(published: true)
  end

  defp apply_filters(query, opts) do
    Enum.reduce(opts, query, fn
      {:published, published}, query ->
        where(query, [e], e.published == ^published)

      _, query ->
        query
    end)
  end

  @doc """
  Gets a single exhibition.

  Raises `Ecto.NoResultsError` if the Exhibition does not exist.
  """
  def get_exhibition!(id), do: Repo.get!(Exhibition, id)

  @doc """
  Creates an exhibition.
  """
  def create_exhibition(attrs \\ %{}) do
    %Exhibition{}
    |> Exhibition.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an exhibition.
  """
  def update_exhibition(%Exhibition{} = exhibition, attrs) do
    exhibition
    |> Exhibition.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes an exhibition.
  """
  def delete_exhibition(%Exhibition{} = exhibition) do
    Repo.delete(exhibition)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking exhibition changes.
  """
  def change_exhibition(%Exhibition{} = exhibition, attrs \\ %{}) do
    Exhibition.changeset(exhibition, attrs)
  end
end
