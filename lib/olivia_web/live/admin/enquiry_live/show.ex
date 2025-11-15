defmodule OliviaWeb.Admin.EnquiryLive.Show do
  use OliviaWeb, :live_view

  alias Olivia.Communications

  on_mount {OliviaWeb.OliviaWeb.UserAuth, :ensure_authenticated}

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Enquiry from <%= @enquiry.name %>
      <:subtitle><%= type_label(@enquiry.type) %> · Received <%= Calendar.strftime(@enquiry.inserted_at, "%d %B %Y at %H:%M") %></:subtitle>
      <:actions>
        <a
          href={"mailto:#{@enquiry.email}?subject=Re: #{@enquiry.type} enquiry"}
          class="rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
        >
          Reply by Email
        </a>
      </:actions>
    </.header>

    <div class="mt-8 bg-white shadow rounded-lg p-6">
      <dl class="space-y-6">
        <div>
          <dt class="text-sm font-medium text-gray-500">Name</dt>
          <dd class="mt-1 text-sm text-gray-900"><%= @enquiry.name %></dd>
        </div>

        <div>
          <dt class="text-sm font-medium text-gray-500">Email</dt>
          <dd class="mt-1 text-sm text-gray-900">
            <a href={"mailto:#{@enquiry.email}"} class="text-blue-600 hover:text-blue-800">
              <%= @enquiry.email %>
            </a>
          </dd>
        </div>

        <div>
          <dt class="text-sm font-medium text-gray-500">Type</dt>
          <dd class="mt-1">
            <span class={[
              "inline-flex items-center rounded-md px-2 py-1 text-xs font-medium",
              @enquiry.type == "artwork" && "bg-blue-50 text-blue-700 ring-1 ring-inset ring-blue-600/20",
              @enquiry.type == "commission" && "bg-purple-50 text-purple-700 ring-1 ring-inset ring-purple-600/20",
              @enquiry.type == "project" && "bg-green-50 text-green-700 ring-1 ring-inset ring-green-600/20",
              @enquiry.type == "general" && "bg-gray-50 text-gray-600 ring-1 ring-inset ring-gray-500/10"
            ]}>
              <%= type_label(@enquiry.type) %>
            </span>
          </dd>
        </div>

        <div>
          <dt class="text-sm font-medium text-gray-500">Received</dt>
          <dd class="mt-1 text-sm text-gray-900">
            <%= Calendar.strftime(@enquiry.inserted_at, "%d %B %Y at %H:%M") %>
          </dd>
        </div>

        <div>
          <dt class="text-sm font-medium text-gray-500 mb-2">Message</dt>
          <dd class="mt-2 bg-gray-50 rounded-lg p-4 border-l-4 border-gray-300">
            <div class="text-sm text-gray-900 whitespace-pre-wrap">
              <%= @enquiry.message %>
            </div>
          </dd>
        </div>
      </dl>

      <div class="mt-8 flex items-center justify-between gap-6 border-t border-gray-200 pt-6">
        <.link
          navigate={~p"/admin/enquiries"}
          class="text-sm font-semibold leading-6 text-zinc-900 hover:text-zinc-700"
        >
          ← Back to enquiries
        </.link>

        <.link
          phx-click="delete"
          data-confirm="Are you sure you want to delete this enquiry?"
          class="text-sm font-semibold text-red-600 hover:text-red-800"
        >
          Delete
        </.link>
      </div>
    </div>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    enquiry = Communications.get_enquiry!(id)

    {:ok,
     socket
     |> assign(:page_title, "Enquiry from #{enquiry.name}")
     |> assign(:enquiry, enquiry)}
  end

  @impl true
  def handle_event("delete", _params, socket) do
    {:ok, _} = Communications.delete_enquiry(socket.assigns.enquiry)

    {:noreply,
     socket
     |> put_flash(:info, "Enquiry deleted successfully")
     |> push_navigate(to: ~p"/admin/enquiries")}
  end

  defp type_label("artwork"), do: "Artwork Purchase"
  defp type_label("commission"), do: "Commission"
  defp type_label("project"), do: "Project Collaboration"
  defp type_label("general"), do: "General"
  defp type_label(_), do: "General"
end
