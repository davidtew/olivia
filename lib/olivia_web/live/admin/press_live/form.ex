defmodule OliviaWeb.Admin.PressLive.Form do
  use OliviaWeb, :live_view

  alias Olivia.Press
  alias Olivia.Press.PressFeature

  on_mount {OliviaWeb.OliviaWeb.UserAuth, :ensure_authenticated}

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      <%= @page_title %>
      <:subtitle>Use this form to manage press feature records in your database.</:subtitle>
    </.header>

    <.form
      for={@form}
      id="press-form"
      phx-change="validate"
      phx-submit="save"
    >
      <.input field={@form[:title]} type="text" label="Title" />

      <div class="grid grid-cols-2 gap-4">
        <.input field={@form[:publication]} type="text" label="Publication" />
        <.input field={@form[:issue]} type="text" label="Issue" placeholder="Optional" />
      </div>

      <div class="grid grid-cols-2 gap-4">
        <.input field={@form[:date]} type="date" label="Date" />
        <.input field={@form[:url]} type="url" label="URL" placeholder="Optional" />
      </div>

      <.input
        field={@form[:excerpt_md]}
        type="textarea"
        label="Excerpt (Markdown)"
        rows="8"
        placeholder="Quote or excerpt from the article..."
      />

      <div class="grid grid-cols-2 gap-4">
        <.input field={@form[:position]} type="number" label="Position" />
        <.input field={@form[:published]} type="checkbox" label="Published" />
      </div>

      <div class="mt-2 flex items-center justify-between gap-6">
        <.button phx-disable-with="Saving...">Save Press Feature</.button>
        <.link
          navigate={~p"/admin/press"}
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
    press_feature = Press.get_press_feature!(id)

    socket
    |> assign(:page_title, "Edit Press Feature")
    |> assign(:press_feature, press_feature)
    |> assign(:form, to_form(Press.change_press_feature(press_feature)))
  end

  defp apply_action(socket, :new, _params) do
    press_feature = %PressFeature{}

    socket
    |> assign(:page_title, "New Press Feature")
    |> assign(:press_feature, press_feature)
    |> assign(:form, to_form(Press.change_press_feature(press_feature)))
  end

  @impl true
  def handle_event("validate", %{"press_feature" => press_params}, socket) do
    changeset = Press.change_press_feature(socket.assigns.press_feature, press_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"press_feature" => press_params}, socket) do
    save_press_feature(socket, socket.assigns.live_action, press_params)
  end

  defp save_press_feature(socket, :edit, press_params) do
    case Press.update_press_feature(socket.assigns.press_feature, press_params) do
      {:ok, press_feature} ->
        {:noreply,
         socket
         |> put_flash(:info, "Press feature updated successfully")
         |> push_navigate(to: ~p"/admin/press/#{press_feature}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_press_feature(socket, :new, press_params) do
    case Press.create_press_feature(press_params) do
      {:ok, press_feature} ->
        {:noreply,
         socket
         |> put_flash(:info, "Press feature created successfully")
         |> push_navigate(to: ~p"/admin/press/#{press_feature}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
