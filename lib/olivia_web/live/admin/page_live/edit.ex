defmodule OliviaWeb.Admin.PageLive.Edit do
  use OliviaWeb, :live_view

  alias Olivia.CMS

  on_mount {OliviaWeb.OliviaWeb.UserAuth, :ensure_authenticated}

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      <%= @page.title %> Page
      <:subtitle>Edit content sections for this page</:subtitle>
      <:actions>
        <.link navigate={~p"/admin/pages"}>
          <.button>Back to Pages</.button>
        </.link>
      </:actions>
    </.header>

    <div class="space-y-6 mt-8">
      <div :for={section <- @sections} class="bg-white shadow rounded-lg p-6">
        <.form
          :let={f}
          for={section.form}
          id={"section-form-#{section.id}"}
          phx-change="validate"
          phx-submit={"save_section_#{section.id}"}
        >
          <input type="hidden" name="section_id" value={section.id} />

          <div class="mb-4">
            <h3 class="text-lg font-medium text-gray-900"><%= section.key %></h3>
            <p class="text-sm text-gray-500">Section key: <%= section.key %></p>
          </div>

          <.input
            field={f[:content_md]}
            type="textarea"
            label="Content (Markdown)"
            rows="8"
            phx-debounce="300"
          />

          <div class="mt-4">
            <.button type="submit" phx-disable-with="Saving...">
              Save <%= section.key %>
            </.button>
          </div>
        </.form>
      </div>
    </div>

    <div class="mt-8 p-4 bg-yellow-50 rounded">
      <h3 class="text-sm font-medium text-yellow-800 mb-2">Markdown Tips</h3>
      <ul class="text-sm text-yellow-700 list-disc list-inside space-y-1">
        <li># Heading 1, ## Heading 2, ### Heading 3</li>
        <li>**bold text** or *italic text*</li>
        <li>[link text](URL) for links</li>
        <li>- item for bullet lists</li>
      </ul>
    </div>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    page = CMS.get_page!(id, preload: [:sections])
    sections = Enum.map(page.sections, fn section ->
      %{
        id: section.id,
        key: section.key,
        position: section.position,
        form: to_form(CMS.change_page_section(section))
      }
    end)
    |> Enum.sort_by(& &1.position)

    {:ok,
     socket
     |> assign(:page, page)
     |> assign(:sections, sections)}
  end

  @impl true
  def handle_params(_params, _, socket) do
    {:noreply, assign(socket, :page_title, "Edit #{socket.assigns.page.title}")}
  end

  @impl true
  def handle_event("validate", %{"page_section" => _section_params}, socket) do
    {:noreply, socket}
  end

  def handle_event("save_section_" <> section_id, %{"page_section" => section_params}, socket) do
    section_id = String.to_integer(section_id)
    section = Enum.find(socket.assigns.page.sections, &(&1.id == section_id))

    case CMS.update_page_section(section, section_params) do
      {:ok, updated_section} ->
        sections = Enum.map(socket.assigns.sections, fn s ->
          if s.id == section_id do
            %{s | form: to_form(CMS.change_page_section(updated_section))}
          else
            s
          end
        end)

        {:noreply,
         socket
         |> assign(:sections, sections)
         |> put_flash(:info, "Section '#{updated_section.key}' updated successfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        sections = Enum.map(socket.assigns.sections, fn s ->
          if s.id == section_id do
            %{s | form: to_form(changeset)}
          else
            s
          end
        end)

        {:noreply, assign(socket, :sections, sections)}
    end
  end
end
