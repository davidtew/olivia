defmodule OliviaWeb.Admin.ArtworkLive.Index do
  use OliviaWeb, :live_view

  alias Olivia.Content

  on_mount {OliviaWeb.OliviaWeb.UserAuth, :ensure_authenticated}

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Listing Artworks
      <:actions>
        <.link navigate={~p"/admin/artworks/new"}>
          <.button>New Artwork</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="artworks"
      rows={@streams.artworks}
      row_click={fn {_id, artwork} -> JS.navigate(~p"/admin/artworks/#{artwork}") end}
    >
      <:col :let={{_id, artwork}} label="Title"><%= artwork.title %></:col>
      <:col :let={{_id, artwork}} label="Series">
        <%= if artwork.series, do: artwork.series.title, else: "—" %>
      </:col>
      <:col :let={{_id, artwork}} label="Year"><%= artwork.year %></:col>
      <:col :let={{_id, artwork}} label="Status">
        <span class={[
          "px-2 inline-flex text-xs leading-5 font-semibold rounded-full",
          status_badge_class(artwork.status)
        ]}>
          <%= String.capitalize(artwork.status) %>
        </span>
      </:col>
      <:col :let={{_id, artwork}} label="Published">
        <span class={[
          "px-2 inline-flex text-xs leading-5 font-semibold rounded-full",
          artwork.published && "bg-green-100 text-green-800" || "bg-gray-100 text-gray-800"
        ]}>
          <%= if artwork.published, do: "Yes", else: "No" %>
        </span>
      </:col>
      <:col :let={{_id, artwork}} label="Featured">
        <%= if artwork.featured, do: "⭐", else: "" %>
      </:col>
      <:action :let={{_id, artwork}}>
        <.link navigate={~p"/admin/artworks/#{artwork}"}>Show</.link>
      </:action>
      <:action :let={{_id, artwork}}>
        <.link navigate={~p"/admin/artworks/#{artwork}/edit"}>Edit</.link>
      </:action>
      <:action :let={{id, artwork}}>
        <.link
          phx-click={JS.push("delete", value: %{id: artwork.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </.table>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(:artworks, Content.list_artworks(preload: [:series]))}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, assign(socket, :page_title, "Listing Artworks")}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    artwork = Content.get_artwork!(id)
    {:ok, _} = Content.delete_artwork(artwork)

    {:noreply, stream_delete(socket, :artworks, artwork)}
  end

  defp status_badge_class("available"), do: "bg-green-100 text-green-800"
  defp status_badge_class("sold"), do: "bg-red-100 text-red-800"
  defp status_badge_class("reserved"), do: "bg-yellow-100 text-yellow-800"
  defp status_badge_class(_), do: "bg-gray-100 text-gray-800"
end
