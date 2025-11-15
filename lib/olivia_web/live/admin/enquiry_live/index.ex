defmodule OliviaWeb.Admin.EnquiryLive.Index do
  use OliviaWeb, :live_view

  alias Olivia.Communications

  on_mount {OliviaWeb.OliviaWeb.UserAuth, :ensure_authenticated}

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Enquiries
      <:subtitle>Messages from visitors and potential clients</:subtitle>
    </.header>

    <div class="mb-4 flex items-center gap-4">
      <div class="bg-white rounded-lg shadow p-4 flex-1">
        <dt class="text-sm font-medium text-gray-500 truncate">
          Total Enquiries
        </dt>
        <dd class="mt-1 text-3xl font-semibold text-gray-900">
          <%= @total_count %>
        </dd>
      </div>
      <div class="bg-white rounded-lg shadow p-4 flex-1">
        <dt class="text-sm font-medium text-gray-500 truncate">
          Artwork Enquiries
        </dt>
        <dd class="mt-1 text-3xl font-semibold text-gray-900">
          <%= @artwork_count %>
        </dd>
      </div>
      <div class="bg-white rounded-lg shadow p-4 flex-1">
        <dt class="text-sm font-medium text-gray-500 truncate">
          Commissions
        </dt>
        <dd class="mt-1 text-3xl font-semibold text-gray-900">
          <%= @commission_count %>
        </dd>
      </div>
    </div>

    <.table
      id="enquiries"
      rows={@streams.enquiries}
    >
      <:col :let={{_id, enquiry}} label="Name"><%= enquiry.name %></:col>
      <:col :let={{_id, enquiry}} label="Email">
        <a href={"mailto:#{enquiry.email}"} class="text-blue-600 hover:text-blue-800">
          <%= enquiry.email %>
        </a>
      </:col>
      <:col :let={{_id, enquiry}} label="Type">
        <span class={[
          "inline-flex items-center rounded-md px-2 py-1 text-xs font-medium",
          enquiry.type == "artwork" && "bg-blue-50 text-blue-700 ring-1 ring-inset ring-blue-600/20",
          enquiry.type == "commission" && "bg-purple-50 text-purple-700 ring-1 ring-inset ring-purple-600/20",
          enquiry.type == "project" && "bg-green-50 text-green-700 ring-1 ring-inset ring-green-600/20",
          enquiry.type == "general" && "bg-gray-50 text-gray-600 ring-1 ring-inset ring-gray-500/10"
        ]}>
          <%= type_label(enquiry.type) %>
        </span>
      </:col>
      <:col :let={{_id, enquiry}} label="Received">
        <%= Calendar.strftime(enquiry.inserted_at, "%d %b %Y") %>
      </:col>
      <:col :let={{_id, enquiry}} label="Message">
        <div class="max-w-xs truncate">
          <%= enquiry.message %>
        </div>
      </:col>
      <:action :let={{_id, enquiry}}>
        <.link navigate={~p"/admin/enquiries/#{enquiry}"}>
          View
        </.link>
      </:action>
      <:action :let={{id, enquiry}}>
        <.link
          phx-click={JS.push("delete", value: %{id: enquiry.id}) |> hide("##{id}")}
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
    enquiries = Communications.list_enquiries()
    artwork_count = Enum.count(enquiries, &(&1.type == "artwork"))
    commission_count = Enum.count(enquiries, &(&1.type == "commission"))

    {:ok,
     socket
     |> assign(:total_count, length(enquiries))
     |> assign(:artwork_count, artwork_count)
     |> assign(:commission_count, commission_count)
     |> stream(:enquiries, enquiries)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, assign(socket, :page_title, "Enquiries")}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    enquiry = Communications.get_enquiry!(id)
    {:ok, _} = Communications.delete_enquiry(enquiry)

    {:noreply,
     socket
     |> stream_delete(:enquiries, enquiry)
     |> assign(:total_count, socket.assigns.total_count - 1)
     |> put_flash(:info, "Enquiry deleted")}
  end

  defp type_label("artwork"), do: "Artwork"
  defp type_label("commission"), do: "Commission"
  defp type_label("project"), do: "Project"
  defp type_label("general"), do: "General"
  defp type_label(_), do: "General"
end
