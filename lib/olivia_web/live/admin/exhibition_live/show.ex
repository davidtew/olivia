defmodule OliviaWeb.Admin.ExhibitionLive.Show do
  use OliviaWeb, :live_view

  alias Olivia.Exhibitions

  on_mount {OliviaWeb.OliviaWeb.UserAuth, :ensure_authenticated}

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      <%= @exhibition.title %>
      <:subtitle>Exhibition details</:subtitle>
      <:actions>
        <.link navigate={~p"/admin/exhibitions"}>
          <.button>Back to list</.button>
        </.link>
        <.link navigate={~p"/admin/exhibitions/#{@exhibition}/edit"}>
          <.button>Edit</.button>
        </.link>
      </:actions>
    </.header>

    <.list>
      <:item title="Title"><%= @exhibition.title %></:item>
      <:item title="Venue"><%= @exhibition.venue %></:item>
      <:item title="City"><%= @exhibition.city %></:item>
      <:item title="Country"><%= @exhibition.country %></:item>
      <:item title="Start Date">
        <%= Calendar.strftime(@exhibition.start_date, "%d %B %Y") %>
      </:item>
      <:item title="End Date">
        <%= Calendar.strftime(@exhibition.end_date, "%d %B %Y") %>
      </:item>
      <:item title="Description">
        <div class="prose max-w-none"><%= raw(@exhibition.description_md || "") %></div>
      </:item>
      <:item title="Position"><%= @exhibition.position %></:item>
      <:item title="Published">
        <%= if @exhibition.published, do: "Yes", else: "No" %>
      </:item>
    </.list>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:exhibition, Exhibitions.get_exhibition!(id))}
  end

  @impl true
  def handle_params(_params, _, socket) do
    {:noreply, assign(socket, :page_title, "Show Exhibition")}
  end
end
