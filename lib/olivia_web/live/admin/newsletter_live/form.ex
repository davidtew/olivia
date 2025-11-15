defmodule OliviaWeb.Admin.NewsletterLive.Form do
  use OliviaWeb, :live_view

  alias Olivia.Communications
  alias Olivia.Communications.Newsletter

  on_mount {OliviaWeb.OliviaWeb.UserAuth, :ensure_authenticated}

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      <%= @page_title %>
      <:subtitle>
        <%= if @newsletter.status == "sent" do %>
          This newsletter has been sent and cannot be edited.
        <% else %>
          Write your newsletter content in Markdown format.
        <% end %>
      </:subtitle>
    </.header>

    <.form
      :if={@newsletter.status != "sent"}
      for={@form}
      id="newsletter-form"
      phx-change="validate"
      phx-submit="save"
    >
      <.input field={@form[:subject]} type="text" label="Subject" />
      <.input field={@form[:body_md]} type="textarea" label="Content (Markdown)" rows="20" />

      <div class="mt-6 flex items-center justify-between gap-6">
        <.button phx-disable-with="Saving...">Save Newsletter</.button>
        <.link navigate={~p"/admin/newsletters"} class="text-sm font-semibold leading-6 text-zinc-900 hover:text-zinc-700">
          Cancel
        </.link>
      </div>
    </.form>

    <div :if={@newsletter.status == "sent"} class="mt-8">
      <h3 class="text-lg font-semibold text-gray-900 mb-4">Newsletter Details</h3>
      <dl class="space-y-4">
        <div>
          <dt class="text-sm font-medium text-gray-500">Subject</dt>
          <dd class="mt-1 text-sm text-gray-900"><%= @newsletter.subject %></dd>
        </div>
        <div>
          <dt class="text-sm font-medium text-gray-500">Sent At</dt>
          <dd class="mt-1 text-sm text-gray-900">
            <%= if @newsletter.sent_at do
              Calendar.strftime(@newsletter.sent_at, "%d %b %Y %H:%M")
            else
              "-"
            end %>
          </dd>
        </div>
        <div>
          <dt class="text-sm font-medium text-gray-500">Recipients</dt>
          <dd class="mt-1 text-sm text-gray-900"><%= @newsletter.sent_count %></dd>
        </div>
        <div>
          <dt class="text-sm font-medium text-gray-500">Content</dt>
          <dd class="mt-2 prose prose-gray max-w-none">
            <%= raw(Earmark.as_html!(@newsletter.body_md || "")) %>
          </dd>
        </div>
      </dl>
      <div class="mt-8">
        <.link navigate={~p"/admin/newsletters"} class="text-sm font-semibold leading-6 text-zinc-900 hover:text-zinc-700">
          ← Back to newsletters
        </.link>
      </div>
    </div>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    newsletter = Communications.get_newsletter!(id)

    socket
    |> assign(:page_title, "Edit Newsletter")
    |> assign(:newsletter, newsletter)
    |> assign(:form, to_form(Communications.change_newsletter(newsletter)))
  end

  defp apply_action(socket, :new, _params) do
    newsletter = %Newsletter{}

    socket
    |> assign(:page_title, "New Newsletter")
    |> assign(:newsletter, newsletter)
    |> assign(:form, to_form(Communications.change_newsletter(newsletter)))
  end

  @impl true
  def handle_event("validate", %{"newsletter" => newsletter_params}, socket) do
    changeset = Communications.change_newsletter(socket.assigns.newsletter, newsletter_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"newsletter" => newsletter_params}, socket) do
    save_newsletter(socket, socket.assigns.live_action, newsletter_params)
  end

  defp save_newsletter(socket, :edit, newsletter_params) do
    newsletter = socket.assigns.newsletter

    case Communications.update_newsletter(newsletter, newsletter_params) do
      {:ok, newsletter} ->
        {:noreply,
         socket
         |> put_flash(:info, "Newsletter updated successfully")
         |> push_navigate(to: ~p"/admin/newsletters")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_newsletter(socket, :new, newsletter_params) do
    case Communications.create_newsletter(newsletter_params) do
      {:ok, newsletter} ->
        {:noreply,
         socket
         |> put_flash(:info, "Newsletter created successfully")
         |> push_navigate(to: ~p"/admin/newsletters")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
