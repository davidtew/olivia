defmodule OliviaWeb.Admin.SubscriberLive.Index do
  use OliviaWeb, :live_view

  alias Olivia.Communications

  on_mount {OliviaWeb.OliviaWeb.UserAuth, :ensure_authenticated}

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Email Subscribers
      <:subtitle>Manage your mailing list</:subtitle>
      <:actions>
        <.button phx-click="export_csv">
          Export CSV
        </.button>
      </:actions>
    </.header>

    <div class="mb-4 flex items-center gap-4">
      <div class="bg-white rounded-lg shadow p-4 flex-1">
        <dt class="text-sm font-medium text-gray-500 truncate">
          Total Subscribers
        </dt>
        <dd class="mt-1 text-3xl font-semibold text-gray-900">
          <%= @total_count %>
        </dd>
      </div>
    </div>

    <.table
      id="subscribers"
      rows={@streams.subscribers}
    >
      <:col :let={{_id, subscriber}} label="Email"><%= subscriber.email %></:col>
      <:col :let={{_id, subscriber}} label="Source">
        <%= String.replace(subscriber.source || "unknown", "_", " ") |> String.capitalize() %>
      </:col>
      <:col :let={{_id, subscriber}} label="Subscribed">
        <%= Calendar.strftime(subscriber.inserted_at, "%d %b %Y") %>
      </:col>
      <:action :let={{id, subscriber}}>
        <.link
          phx-click={JS.push("delete", value: %{id: subscriber.id}) |> hide("##{id}")}
          data-confirm="Are you sure you want to remove this subscriber?"
        >
          Remove
        </.link>
      </:action>
    </.table>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    subscribers = Communications.list_subscribers()

    {:ok,
     socket
     |> assign(:total_count, length(subscribers))
     |> stream(:subscribers, subscribers)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, assign(socket, :page_title, "Email Subscribers")}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    subscriber = Communications.get_subscriber!(id)
    {:ok, _} = Communications.delete_subscriber(subscriber)

    {:noreply,
     socket
     |> stream_delete(:subscribers, subscriber)
     |> assign(:total_count, socket.assigns.total_count - 1)
     |> put_flash(:info, "Subscriber removed")}
  end

  def handle_event("export_csv", _params, socket) do
    csv_data = Communications.export_subscribers_csv()

    {:noreply,
     socket
     |> push_event("download_csv", %{
       data: csv_data,
       filename: "subscribers_#{Date.utc_today()}.csv"
     })}
  end
end
