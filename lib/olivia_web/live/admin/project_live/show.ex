defmodule OliviaWeb.Admin.ProjectLive.Show do
  use OliviaWeb, :live_view

  alias Olivia.Projects

  on_mount {OliviaWeb.OliviaWeb.UserAuth, :ensure_authenticated}

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      <%= @project.name %>
      <:subtitle>Client project details</:subtitle>
      <:actions>
        <.link navigate={~p"/admin/projects"}>
          <.button>Back to list</.button>
        </.link>
        <.link navigate={~p"/admin/projects/#{@project}/edit"}>
          <.button>Edit</.button>
        </.link>
      </:actions>
    </.header>

    <.list>
      <:item title="Project Name"><%= @project.name %></:item>
      <:item title="Client"><%= @project.client_name %></:item>
      <:item title="Location"><%= @project.location || "—" %></:item>
      <:item title="Status">
        <span class="capitalize"><%= @project.status %></span>
      </:item>
      <:item title="Description">
        <div class="prose max-w-none"><%= raw(@project.description_md || "") %></div>
      </:item>
      <:item title="Position"><%= @project.position %></:item>
      <:item title="Published">
        <%= if @project.published, do: "Yes", else: "No" %>
      </:item>
    </.list>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:project, Projects.get_client_project!(id))}
  end

  @impl true
  def handle_params(_params, _, socket) do
    {:noreply, assign(socket, :page_title, "Show Project")}
  end
end
