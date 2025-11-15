defmodule Olivia.Projects do
  @moduledoc """
  The Projects context - manages client/hospitality projects.
  """

  import Ecto.Query, warn: false
  alias Olivia.Repo
  alias Olivia.Projects.ClientProject

  @doc """
  Returns the list of client projects.

  ## Options
    * `:published` - Filter by published status (true/false)
    * `:status` - Filter by project status
  """
  def list_client_projects(opts \\ []) do
    ClientProject
    |> apply_filters(opts)
    |> order_by([p], [asc: p.position, desc: p.inserted_at])
    |> Repo.all()
  end

  @doc """
  Lists published client projects.
  """
  def list_published_projects do
    list_client_projects(published: true)
  end

  defp apply_filters(query, opts) do
    Enum.reduce(opts, query, fn
      {:published, published}, query ->
        where(query, [p], p.published == ^published)

      {:status, status}, query ->
        where(query, [p], p.status == ^status)

      _, query ->
        query
    end)
  end

  @doc """
  Gets a single client project.

  Raises `Ecto.NoResultsError` if the Client project does not exist.
  """
  def get_client_project!(id), do: Repo.get!(ClientProject, id)

  @doc """
  Creates a client project.
  """
  def create_client_project(attrs \\ %{}) do
    %ClientProject{}
    |> ClientProject.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a client project.
  """
  def update_client_project(%ClientProject{} = client_project, attrs) do
    client_project
    |> ClientProject.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a client project.
  """
  def delete_client_project(%ClientProject{} = client_project) do
    Repo.delete(client_project)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking client project changes.
  """
  def change_client_project(%ClientProject{} = client_project, attrs \\ %{}) do
    ClientProject.changeset(client_project, attrs)
  end
end
