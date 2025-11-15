defmodule OliviaWeb.Admin.ProjectLive.Form do
  use OliviaWeb, :live_view

  alias Olivia.Projects
  alias Olivia.Projects.ClientProject

  on_mount {OliviaWeb.OliviaWeb.UserAuth, :ensure_authenticated}

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      <%= @page_title %>
      <:subtitle>Use this form to manage client project records in your database.</:subtitle>
    </.header>

    <.form
      for={@form}
      id="project-form"
      phx-change="validate"
      phx-submit="save"
    >
      <.input field={@form[:name]} type="text" label="Project Name" />

      <div class="grid grid-cols-2 gap-4">
        <.input field={@form[:client_name]} type="text" label="Client Name" />
        <.input field={@form[:location]} type="text" label="Location" placeholder="Optional" />
      </div>

      <.input
        field={@form[:status]}
        type="select"
        label="Status"
        options={[
          {"Completed", "completed"},
          {"In Progress", "in progress"},
          {"Upcoming", "upcoming"}
        ]}
      />

      <.input
        field={@form[:description_md]}
        type="textarea"
        label="Description (Markdown)"
        rows="10"
      />

      <div class="grid grid-cols-2 gap-4">
        <.input field={@form[:position]} type="number" label="Position" />
        <.input field={@form[:published]} type="checkbox" label="Published" />
      </div>

      <div class="mt-2 flex items-center justify-between gap-6">
        <.button phx-disable-with="Saving...">Save Project</.button>
        <.link
          navigate={~p"/admin/projects"}
          class="text-sm font-semibold leading-6 text-zinc-900 hover:text-zinc-700"
        >
          Cancel
        </.link>
      </div>
    </.form>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    project = Projects.get_client_project!(id)

    socket
    |> assign(:page_title, "Edit Project")
    |> assign(:project, project)
    |> assign(:form, to_form(Projects.change_client_project(project)))
  end

  defp apply_action(socket, :new, _params) do
    project = %ClientProject{}

    socket
    |> assign(:page_title, "New Project")
    |> assign(:project, project)
    |> assign(:form, to_form(Projects.change_client_project(project)))
  end

  @impl true
  def handle_event("validate", %{"client_project" => project_params}, socket) do
    changeset = Projects.change_client_project(socket.assigns.project, project_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"client_project" => project_params}, socket) do
    save_project(socket, socket.assigns.live_action, project_params)
  end

  defp save_project(socket, :edit, project_params) do
    case Projects.update_client_project(socket.assigns.project, project_params) do
      {:ok, project} ->
        {:noreply,
         socket
         |> put_flash(:info, "Project updated successfully")
         |> push_navigate(to: ~p"/admin/projects/#{project}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_project(socket, :new, project_params) do
    case Projects.create_client_project(project_params) do
      {:ok, project} ->
        {:noreply,
         socket
         |> put_flash(:info, "Project created successfully")
         |> push_navigate(to: ~p"/admin/projects/#{project}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
