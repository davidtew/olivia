defmodule OliviaWeb.Admin.ExhibitionLive.Form do
  use OliviaWeb, :live_view

  alias Olivia.Exhibitions
  alias Olivia.Exhibitions.Exhibition

  on_mount {OliviaWeb.OliviaWeb.UserAuth, :ensure_authenticated}

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      <%= @page_title %>
      <:subtitle>Use this form to manage exhibition records in your database.</:subtitle>
    </.header>

    <.form
      for={@form}
      id="exhibition-form"
      phx-change="validate"
      phx-submit="save"
    >
      <.input field={@form[:title]} type="text" label="Title" />

      <div class="grid grid-cols-2 gap-4">
        <.input field={@form[:venue]} type="text" label="Venue" />
        <.input field={@form[:city]} type="text" label="City" />
      </div>

      <.input field={@form[:country]} type="text" label="Country" />

      <div class="grid grid-cols-2 gap-4">
        <.input field={@form[:start_date]} type="date" label="Start Date" />
        <.input field={@form[:end_date]} type="date" label="End Date" />
      </div>

      <.input
        field={@form[:description_md]}
        type="textarea"
        label="Description (Markdown)"
        rows="8"
      />

      <div class="grid grid-cols-2 gap-4">
        <.input field={@form[:position]} type="number" label="Position" />
        <.input field={@form[:published]} type="checkbox" label="Published" />
      </div>

      <div class="mt-2 flex items-center justify-between gap-6">
        <.button phx-disable-with="Saving...">Save Exhibition</.button>
        <.link
          navigate={~p"/admin/exhibitions"}
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
    exhibition = Exhibitions.get_exhibition!(id)

    socket
    |> assign(:page_title, "Edit Exhibition")
    |> assign(:exhibition, exhibition)
    |> assign(:form, to_form(Exhibitions.change_exhibition(exhibition)))
  end

  defp apply_action(socket, :new, _params) do
    exhibition = %Exhibition{}

    socket
    |> assign(:page_title, "New Exhibition")
    |> assign(:exhibition, exhibition)
    |> assign(:form, to_form(Exhibitions.change_exhibition(exhibition)))
  end

  @impl true
  def handle_event("validate", %{"exhibition" => exhibition_params}, socket) do
    changeset = Exhibitions.change_exhibition(socket.assigns.exhibition, exhibition_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"exhibition" => exhibition_params}, socket) do
    save_exhibition(socket, socket.assigns.live_action, exhibition_params)
  end

  defp save_exhibition(socket, :edit, exhibition_params) do
    case Exhibitions.update_exhibition(socket.assigns.exhibition, exhibition_params) do
      {:ok, exhibition} ->
        {:noreply,
         socket
         |> put_flash(:info, "Exhibition updated successfully")
         |> push_navigate(to: ~p"/admin/exhibitions/#{exhibition}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_exhibition(socket, :new, exhibition_params) do
    case Exhibitions.create_exhibition(exhibition_params) do
      {:ok, exhibition} ->
        {:noreply,
         socket
         |> put_flash(:info, "Exhibition created successfully")
         |> push_navigate(to: ~p"/admin/exhibitions/#{exhibition}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
