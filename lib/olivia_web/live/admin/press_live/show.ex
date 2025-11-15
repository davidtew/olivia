defmodule OliviaWeb.Admin.PressLive.Show do
  use OliviaWeb, :live_view

  alias Olivia.Press

  on_mount {OliviaWeb.OliviaWeb.UserAuth, :ensure_authenticated}

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      <%= @press_feature.title %>
      <:subtitle>Press feature details</:subtitle>
      <:actions>
        <.link navigate={~p"/admin/press"}>
          <.button>Back to list</.button>
        </.link>
        <.link navigate={~p"/admin/press/#{@press_feature}/edit"}>
          <.button>Edit</.button>
        </.link>
      </:actions>
    </.header>

    <.list>
      <:item title="Title"><%= @press_feature.title %></:item>
      <:item title="Publication"><%= @press_feature.publication %></:item>
      <:item title="Issue"><%= @press_feature.issue || "—" %></:item>
      <:item title="Date">
        <%= Calendar.strftime(@press_feature.date, "%d %B %Y") %>
      </:item>
      <:item title="URL">
        <%= if @press_feature.url do %>
          <.link href={@press_feature.url} target="_blank" class="text-indigo-600 hover:text-indigo-900">
            <%= @press_feature.url %>
          </.link>
        <% else %>
          —
        <% end %>
      </:item>
      <:item title="Excerpt">
        <div class="prose max-w-none"><%= raw(@press_feature.excerpt_md || "") %></div>
      </:item>
      <:item title="Position"><%= @press_feature.position %></:item>
      <:item title="Published">
        <%= if @press_feature.published, do: "Yes", else: "No" %>
      </:item>
    </.list>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:press_feature, Press.get_press_feature!(id))}
  end

  @impl true
  def handle_params(_params, _, socket) do
    {:noreply, assign(socket, :page_title, "Show Press Feature")}
  end
end
