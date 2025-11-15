defmodule OliviaWeb.Admin.NewsletterLive.Index do
  use OliviaWeb, :live_view

  alias Olivia.Communications

  on_mount {OliviaWeb.OliviaWeb.UserAuth, :ensure_authenticated}

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Newsletters
      <:subtitle>Create and send newsletters to your subscribers</:subtitle>
      <:actions>
        <.link navigate={~p"/admin/newsletters/new"}>
          <.button>New Newsletter</.button>
        </.link>
      </:actions>
    </.header>

    <div class="mb-4 flex items-center gap-4">
      <div class="bg-white rounded-lg shadow p-4 flex-1">
        <dt class="text-sm font-medium text-gray-500 truncate">
          Total Newsletters
        </dt>
        <dd class="mt-1 text-3xl font-semibold text-gray-900">
          <%= @total_count %>
        </dd>
      </div>
      <div class="bg-white rounded-lg shadow p-4 flex-1">
        <dt class="text-sm font-medium text-gray-500 truncate">
          Sent Newsletters
        </dt>
        <dd class="mt-1 text-3xl font-semibold text-gray-900">
          <%= @sent_count %>
        </dd>
      </div>
    </div>

    <.table
      id="newsletters"
      rows={@streams.newsletters}
    >
      <:col :let={{_id, newsletter}} label="Subject"><%= newsletter.subject %></:col>
      <:col :let={{_id, newsletter}} label="Status">
        <span class={[
          "inline-flex items-center rounded-md px-2 py-1 text-xs font-medium",
          newsletter.status == "sent" && "bg-green-50 text-green-700 ring-1 ring-inset ring-green-600/20",
          newsletter.status == "draft" && "bg-gray-50 text-gray-600 ring-1 ring-inset ring-gray-500/10"
        ]}>
          <%= String.capitalize(newsletter.status) %>
        </span>
      </:col>
      <:col :let={{_id, newsletter}} label="Sent Count">
        <%= if newsletter.sent_count > 0, do: newsletter.sent_count, else: "-" %>
      </:col>
      <:col :let={{_id, newsletter}} label="Created">
        <%= Calendar.strftime(newsletter.inserted_at, "%d %b %Y") %>
      </:col>
      <:col :let={{_id, newsletter}} label="Sent At">
        <%= if newsletter.sent_at do
          Calendar.strftime(newsletter.sent_at, "%d %b %Y %H:%M")
        else
          "-"
        end %>
      </:col>
      <:action :let={{_id, newsletter}}>
        <.link navigate={~p"/admin/newsletters/#{newsletter}/edit"}>
          Edit
        </.link>
      </:action>
      <:action :let={{id, newsletter}}>
        <.link
          :if={newsletter.status == "draft"}
          phx-click={JS.push("send", value: %{id: newsletter.id})}
          data-confirm="Send this newsletter to all subscribers?"
          class="font-semibold text-green-600 hover:text-green-700"
        >
          Send
        </.link>
      </:action>
      <:action :let={{id, newsletter}}>
        <.link
          phx-click={JS.push("delete", value: %{id: newsletter.id}) |> hide("##{id}")}
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
    newsletters = Communications.list_newsletters()
    sent_count = Enum.count(newsletters, &(&1.status == "sent"))

    {:ok,
     socket
     |> assign(:total_count, length(newsletters))
     |> assign(:sent_count, sent_count)
     |> stream(:newsletters, newsletters)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, assign(socket, :page_title, "Newsletters")}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    newsletter = Communications.get_newsletter!(id)
    {:ok, _} = Communications.delete_newsletter(newsletter)

    {:noreply,
     socket
     |> stream_delete(:newsletters, newsletter)
     |> assign(:total_count, socket.assigns.total_count - 1)
     |> put_flash(:info, "Newsletter deleted")}
  end

  def handle_event("send", %{"id" => id}, socket) do
    newsletter = Communications.get_newsletter!(id)

    case Communications.send_newsletter(newsletter) do
      {:ok, updated_newsletter} ->
        {:noreply,
         socket
         |> stream_insert(:newsletters, updated_newsletter)
         |> assign(:sent_count, socket.assigns.sent_count + 1)
         |> put_flash(:info, "Newsletter sent to #{updated_newsletter.sent_count} subscribers")}

      {:error, :already_sent} ->
        {:noreply, put_flash(socket, :error, "Newsletter has already been sent")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to send newsletter")}
    end
  end
end
