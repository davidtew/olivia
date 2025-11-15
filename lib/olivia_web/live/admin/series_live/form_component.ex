defmodule OliviaWeb.Admin.SeriesLive.FormComponent do
  use OliviaWeb, :live_component

  alias Olivia.Content

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage series records in your database.</:subtitle>
      </.header>

      <.form
        for={@form}
        id="series-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="Title" />
        <.input
          field={@form[:slug]}
          type="text"
          label="Slug"
          phx-debounce="blur"
          placeholder="Leave blank to auto-generate from title"
        />
        <.input field={@form[:summary]} type="textarea" label="Summary" rows="3" />
        <.input field={@form[:body_md]} type="textarea" label="Description (Markdown)" rows="10" />
        <.input field={@form[:position]} type="number" label="Position" />
        <.input field={@form[:published]} type="checkbox" label="Published" />
        <div class="mt-2 flex items-center justify-between gap-6">
          <.button phx-disable-with="Saving...">Save Series</.button>
        </div>
      </.form>
    </div>
    """
  end

  @impl true
  def update(%{series: series} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Content.change_series(series))
     end)}
  end

  @impl true
  def handle_event("validate", %{"series" => series_params}, socket) do
    changeset = Content.change_series(socket.assigns.series, series_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"series" => series_params}, socket) do
    save_series(socket, socket.assigns.action, series_params)
  end

  defp save_series(socket, :edit, series_params) do
    case Content.update_series(socket.assigns.series, series_params) do
      {:ok, series} ->
        notify_parent({:saved, series})

        {:noreply,
         socket
         |> put_flash(:info, "Series updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_series(socket, :new, series_params) do
    case Content.create_series(series_params) do
      {:ok, series} ->
        notify_parent({:saved, series})

        {:noreply,
         socket
         |> put_flash(:info, "Series created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
