defmodule OliviaWeb.Admin.ArtworkLive.Show do
  use OliviaWeb, :live_view

  alias Olivia.Content

  on_mount {OliviaWeb.OliviaWeb.UserAuth, :ensure_authenticated}

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      <%= @artwork.title %>
      <:subtitle>Artwork details</:subtitle>
      <:actions>
        <.link navigate={~p"/admin/artworks"}>
          <.button>Back to list</.button>
        </.link>
        <.link navigate={~p"/admin/artworks/#{@artwork}/edit"}>
          <.button>Edit</.button>
        </.link>
      </:actions>
    </.header>

    <div :if={@artwork.image_url} class="mt-6 mb-8">
      <h3 class="text-lg font-medium text-gray-900 mb-4">Artwork Image</h3>
      <img src={@artwork.image_url} alt={@artwork.title} class="max-w-2xl rounded-lg shadow-lg" />
    </div>

    <.list>
      <:item title="Title"><%= @artwork.title %></:item>
      <:item title="Slug"><%= @artwork.slug %></:item>
      <:item title="Series">
        <%= if @artwork.series do %>
          <.link navigate={~p"/admin/series/#{@artwork.series}"} class="text-indigo-600 hover:text-indigo-900">
            <%= @artwork.series.title %>
          </.link>
        <% else %>
          —
        <% end %>
      </:item>
      <:item title="Year"><%= @artwork.year %></:item>
      <:item title="Medium"><%= @artwork.medium %></:item>
      <:item title="Dimensions"><%= @artwork.dimensions %></:item>
      <:item title="Status">
        <span class="capitalize"><%= @artwork.status %></span>
      </:item>
      <:item title="Price">
        <%= if @artwork.price_cents do %>
          <%= @artwork.currency %> <%= format_price(@artwork.price_cents) %>
        <% else %>
          Not for sale
        <% end %>
      </:item>
      <:item title="Location"><%= @artwork.location %></:item>
      <:item title="Description">
        <div class="prose max-w-none"><%= raw(@artwork.description_md || "") %></div>
      </:item>
      <:item title="Position"><%= @artwork.position %></:item>
      <:item title="Featured">
        <%= if @artwork.featured, do: "Yes", else: "No" %>
      </:item>
      <:item title="Published">
        <%= if @artwork.published, do: "Yes", else: "No" %>
      </:item>
    </.list>

    <div :if={@artwork.images && length(@artwork.images) > 0} class="mt-8">
      <h3 class="text-lg font-medium text-gray-900 mb-4">Images</h3>
      <div class="grid grid-cols-3 gap-4">
        <div :for={image <- @artwork.images} class="border rounded p-2">
          <p class="text-sm font-medium"><%= image.role %></p>
          <p class="text-xs text-gray-500">Alt: <%= image.alt_text || "—" %></p>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:artwork, Content.get_artwork!(id, preload: [:series, :images]))}
  end

  @impl true
  def handle_params(_params, _, socket) do
    {:noreply, assign(socket, :page_title, "Show Artwork")}
  end

  defp format_price(cents) do
    pounds = cents / 100
    :erlang.float_to_binary(pounds, decimals: 2)
  end
end
