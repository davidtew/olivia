defmodule Olivia.CMS do
  @moduledoc """
  The CMS context - manages pages and editable content sections.
  """

  import Ecto.Query, warn: false
  alias Olivia.Repo
  alias Olivia.CMS.{Page, PageSection}

  ## Pages

  @doc """
  Returns the list of pages.
  """
  def list_pages(opts \\ []) do
    Page
    |> order_by([p], asc: p.slug)
    |> maybe_preload(opts)
    |> Repo.all()
  end

  @doc """
  Gets a single page.

  Raises `Ecto.NoResultsError` if the Page does not exist.
  """
  def get_page!(id, opts \\ []) do
    Page
    |> maybe_preload(opts)
    |> Repo.get!(id)
  end

  @doc """
  Gets a page by slug.

  Raises `Ecto.NoResultsError` if the Page does not exist.
  """
  def get_page_by_slug!(slug, opts \\ []) do
    Page
    |> where([p], p.slug == ^slug)
    |> maybe_preload(opts)
    |> Repo.one!()
  end

  @doc """
  Creates a page.
  """
  def create_page(attrs \\ %{}) do
    %Page{}
    |> Page.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a page.
  """
  def update_page(%Page{} = page, attrs) do
    page
    |> Page.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a page.
  """
  def delete_page(%Page{} = page) do
    Repo.delete(page)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking page changes.
  """
  def change_page(%Page{} = page, attrs \\ %{}) do
    Page.changeset(page, attrs)
  end

  ## Page Sections

  @doc """
  Gets a page section by page slug and section key.

  Returns nil if not found.
  """
  def get_page_section(page_slug, section_key) do
    from(ps in PageSection,
      join: p in assoc(ps, :page),
      where: p.slug == ^page_slug and ps.key == ^section_key,
      select: ps
    )
    |> Repo.one()
  end

  @doc """
  Gets the content of a page section.

  Returns nil if not found.
  """
  def get_section_content(page_slug, section_key) do
    case get_page_section(page_slug, section_key) do
      nil -> nil
      section -> section.content_md
    end
  end

  @doc """
  Lists all sections for a page.
  """
  def list_sections_for_page(page_id) do
    PageSection
    |> where([ps], ps.page_id == ^page_id)
    |> order_by([ps], [asc: ps.position, asc: ps.key])
    |> Repo.all()
  end

  @doc """
  Creates a page section.
  """
  def create_page_section(attrs \\ %{}) do
    %PageSection{}
    |> PageSection.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a page section.
  """
  def update_page_section(%PageSection{} = page_section, attrs) do
    page_section
    |> PageSection.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates or creates a page section by page slug and key.
  """
  def upsert_page_section(page_slug, section_key, content_md) do
    page = get_page_by_slug!(page_slug)

    case get_page_section(page_slug, section_key) do
      nil ->
        create_page_section(%{
          page_id: page.id,
          key: section_key,
          content_md: content_md
        })

      section ->
        update_page_section(section, %{content_md: content_md})
    end
  end

  @doc """
  Deletes a page section.
  """
  def delete_page_section(%PageSection{} = page_section) do
    Repo.delete(page_section)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking page section changes.
  """
  def change_page_section(%PageSection{} = page_section, attrs \\ %{}) do
    PageSection.changeset(page_section, attrs)
  end

  ## Helpers

  defp maybe_preload(query, opts) do
    case Keyword.get(opts, :preload) do
      nil -> query
      preloads -> from(q in query, preload: ^preloads)
    end
  end
end
