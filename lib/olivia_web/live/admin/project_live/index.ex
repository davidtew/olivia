defmodule OliviaWeb.Admin.ProjectLive.Index do
  use OliviaWeb, :live_view

  alias Olivia.Projects

  on_mount {OliviaWeb.OliviaWeb.UserAuth, :ensure_authenticated}

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Client Projects
      <:actions>
        <.link navigate={~p"/admin/projects/new"}>
          <.button>New Project</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="projects"
      rows={@streams.projects}
      row_click={fn {_id, project} -> JS.navigate(~p"/admin/projects/#{project}") end}
    >
      <:col :let={{_id, project}} label="Name"><%= project.name %></:col>
      <:col :let={{_id, project}} label="Client"><%= project.client_name %></:col>
      <:col :let={{_id, project}} label="Location"><%= project.location || "—" %></:col>
      <:col :let={{_id, project}} label="Status">
        <span class={[
          "px-2 inline-flex text-xs leading-5 font-semibold rounded-full",
          status_badge_class(project.status)
        ]}>
          <%= String.capitalize(project.status) %>
        </span>
      </:col>
      <:col :let={{_id, project}} label="Published">
        <span class={[
          "px-2 inline-flex text-xs leading-5 font-semibold rounded-full",
          project.published && "bg-green-100 text-green-800" || "bg-gray-100 text-gray-800"
        ]}>
          <%= if project.published, do: "Yes", else: "No" %>
        </span>
      </:col>
      <:action :let={{_id, project}}>
        <.link navigate={~p"/admin/projects/#{project}"}>Show</.link>
      </:action>
      <:action :let={{_id, project}}>
        <.link navigate={~p"/admin/projects/#{project}/edit"}>Edit</.link>
      </:action>
      <:action :let={{id, project}}>
        <.link
          phx-click={JS.push("delete", value: %{id: project.id}) |> hide("##{id}")}
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
     |> stream(:projects, Projects.list_client_projects())}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, assign(socket, :page_title, "Client Projects")}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    project = Projects.get_client_project!(id)
    {:ok, _} = Projects.delete_client_project(project)

    {:noreply, stream_delete(socket, :projects, project)}
  end

  defp status_badge_class("completed"), do: "bg-green-100 text-green-800"
  defp status_badge_class("in progress"), do: "bg-blue-100 text-blue-800"
  defp status_badge_class("upcoming"), do: "bg-yellow-100 text-yellow-800"
  defp status_badge_class(_), do: "bg-gray-100 text-gray-800"
end
