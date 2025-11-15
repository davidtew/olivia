defmodule OliviaWeb.Admin.SeriesLive.Show do
  use OliviaWeb, :live_view

  alias Olivia.Content

  on_mount {OliviaWeb.OliviaWeb.UserAuth, :ensure_authenticated}

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      <%= @series.title %>
      <:subtitle>Series details</:subtitle>
      <:actions>
        <.link navigate={~p"/admin/series"}>
          <.button>Back to list</.button>
        </.link>
        <.link navigate={~p"/admin/series/#{@series}/edit"}>
          <.button>Edit</.button>
        </.link>
      </:actions>
    </.header>

    <.list>
      <:item title="Title"><%= @series.title %></:item>
      <:item title="Slug"><%= @series.slug %></:item>
      <:item title="Summary"><%= @series.summary %></:item>
      <:item title="Description">
        <div class="prose max-w-none"><%= raw(@series.body_md || "") %></div>
      </:item>
      <:item title="Position"><%= @series.position %></:item>
      <:item title="Published">
        <%= if @series.published, do: "Yes", else: "No" %>
      </:item>
    </.list>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:series, Content.get_series!(id))}
  end

  @impl true
  def handle_params(_params, _, socket) do
    {:noreply, assign(socket, :page_title, "Show Series")}
  end
end
