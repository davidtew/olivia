defmodule OliviaWeb.Admin.DashboardLive do
  use OliviaWeb, :live_view

  on_mount {OliviaWeb.OliviaWeb.UserAuth, :ensure_authenticated}

  @impl true
  def mount(_params, _session, socket) do
    stats = %{
      series_count: Olivia.Content.list_series() |> length(),
      artwork_count: Olivia.Content.list_artworks() |> length(),
      published_artworks: Olivia.Content.list_artworks(published: true) |> length(),
      subscribers: Olivia.Communications.list_subscribers() |> length(),
      newsletters: Olivia.Communications.list_newsletters() |> length(),
      enquiries: Olivia.Communications.list_enquiries() |> length()
    }

    {:ok, assign(socket, stats: stats, page_title: "Admin Dashboard")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h1 class="text-3xl font-bold text-gray-900 mb-8">Dashboard</h1>

      <div class="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-3">
        <div class="bg-white overflow-hidden shadow rounded-lg">
          <div class="p-5">
            <div class="flex items-center">
              <div class="flex-1">
                <dt class="text-sm font-medium text-gray-500 truncate">
                  Total Series
                </dt>
                <dd class="mt-1 text-3xl font-semibold text-gray-900">
                  <%= @stats.series_count %>
                </dd>
              </div>
            </div>
          </div>
          <div class="bg-gray-50 px-5 py-3">
            <.link navigate={~p"/admin/series"} class="text-sm text-indigo-600 hover:text-indigo-900">
              View all
            </.link>
          </div>
        </div>

        <div class="bg-white overflow-hidden shadow rounded-lg">
          <div class="p-5">
            <div class="flex items-center">
              <div class="flex-1">
                <dt class="text-sm font-medium text-gray-500 truncate">
                  Total Artworks
                </dt>
                <dd class="mt-1 text-3xl font-semibold text-gray-900">
                  <%= @stats.artwork_count %>
                </dd>
              </div>
            </div>
          </div>
          <div class="bg-gray-50 px-5 py-3">
            <span class="text-sm text-gray-500">
              <%= @stats.published_artworks %> published
            </span>
          </div>
        </div>

        <div class="bg-white overflow-hidden shadow rounded-lg">
          <div class="p-5">
            <div class="flex items-center">
              <div class="flex-1">
                <dt class="text-sm font-medium text-gray-500 truncate">
                  Email Subscribers
                </dt>
                <dd class="mt-1 text-3xl font-semibold text-gray-900">
                  <%= @stats.subscribers %>
                </dd>
              </div>
            </div>
          </div>
          <div class="bg-gray-50 px-5 py-3">
            <.link navigate={~p"/admin/subscribers"} class="text-sm text-indigo-600 hover:text-indigo-900">
              Manage subscribers
            </.link>
          </div>
        </div>

        <div class="bg-white overflow-hidden shadow rounded-lg">
          <div class="p-5">
            <div class="flex items-center">
              <div class="flex-1">
                <dt class="text-sm font-medium text-gray-500 truncate">
                  Newsletters
                </dt>
                <dd class="mt-1 text-3xl font-semibold text-gray-900">
                  <%= @stats.newsletters %>
                </dd>
              </div>
            </div>
          </div>
          <div class="bg-gray-50 px-5 py-3">
            <.link navigate={~p"/admin/newsletters"} class="text-sm text-indigo-600 hover:text-indigo-900">
              Manage newsletters
            </.link>
          </div>
        </div>

        <div class="bg-white overflow-hidden shadow rounded-lg">
          <div class="p-5">
            <div class="flex items-center">
              <div class="flex-1">
                <dt class="text-sm font-medium text-gray-500 truncate">
                  Enquiries
                </dt>
                <dd class="mt-1 text-3xl font-semibold text-gray-900">
                  <%= @stats.enquiries %>
                </dd>
              </div>
            </div>
          </div>
          <div class="bg-gray-50 px-5 py-3">
            <.link navigate={~p"/admin/enquiries"} class="text-sm text-indigo-600 hover:text-indigo-900">
              View enquiries
            </.link>
          </div>
        </div>
      </div>

      <div class="mt-8 bg-white shadow rounded-lg p-6">
        <h2 class="text-lg font-medium text-gray-900 mb-4">Welcome to Olivia Admin</h2>
        <p class="text-gray-600">
          Use the navigation above to manage your gallery content.
        </p>
      </div>
    </div>
    """
  end
end
