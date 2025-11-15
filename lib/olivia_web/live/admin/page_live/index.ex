defmodule OliviaWeb.Admin.PageLive.Index do
  use OliviaWeb, :live_view

  alias Olivia.CMS

  on_mount {OliviaWeb.OliviaWeb.UserAuth, :ensure_authenticated}

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      CMS Pages
      <:subtitle>Manage content for public-facing pages</:subtitle>
    </.header>

    <.table
      id="pages"
      rows={@streams.pages}
      row_click={fn {_id, page} -> JS.navigate(~p"/admin/pages/#{page}") end}
    >
      <:col :let={{_id, page}} label="Page"><%= page.title %></:col>
      <:col :let={{_id, page}} label="Slug"><%= page.slug %></:col>
      <:col :let={{_id, page}} label="Sections">
        <%= if page.sections, do: length(page.sections), else: 0 %>
      </:col>
      <:action :let={{_id, page}}>
        <.link navigate={~p"/admin/pages/#{page}"}>Edit Sections</.link>
      </:action>
    </.table>

    <div class="mt-8 p-4 bg-blue-50 rounded">
      <h3 class="text-sm font-medium text-blue-800 mb-2">About CMS Pages</h3>
      <p class="text-sm text-blue-700">
        Each page is divided into sections (like "hero_title", "intro", etc.).
        Click "Edit Sections" to modify the content for each section.
      </p>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(:pages, CMS.list_pages(preload: [:sections]))}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, assign(socket, :page_title, "CMS Pages")}
  end
end
