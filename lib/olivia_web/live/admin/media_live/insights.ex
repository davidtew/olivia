defmodule OliviaWeb.Admin.MediaLive.Insights do
  use OliviaWeb, :live_view

  alias Olivia.Media

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Analysis Insights")
     |> assign(:view, "overview")
     |> assign(:search_term, "")
     |> assign(:search_results, [])
     |> assign(:selected_media, nil)
     |> load_overview_data()}
  end

  defp load_overview_data(socket) do
    stats = Media.get_analysis_stats()
    series = Media.list_series_works()

    socket
    |> assign(:stats, stats)
    |> assign(:series_map, series)
    |> assign(:top_movements, stats.top_movements)
    |> assign(:top_contexts, stats.top_contexts)
  end

  @impl true
  def handle_event("change_view", %{"view" => view}, socket) do
    {:noreply, assign(socket, :view, view)}
  end

  @impl true
  def handle_event("search_movement", %{"term" => term}, socket) do
    results = if String.length(term) > 2 do
      Media.search_by_artistic_connection(term)
    else
      []
    end

    {:noreply,
     socket
     |> assign(:view, "search")
     |> assign(:search_term, term)
     |> assign(:search_results, results)
     |> assign(:search_type, "movement")}
  end

  @impl true
  def handle_event("search_theme", %{"term" => term}, socket) do
    results = if String.length(term) > 2 do
      Media.search_by_theme(term)
    else
      []
    end

    {:noreply,
     socket
     |> assign(:view, "search")
     |> assign(:search_term, term)
     |> assign(:search_results, results)
     |> assign(:search_type, "theme")}
  end

  @impl true
  def handle_event("view_provocations", %{"id" => id}, socket) do
    media_id = String.to_integer(id)
    media = Media.get_media!(media_id)
    provocations = Media.get_provocations(media_id)

    {:noreply,
     socket
     |> assign(:view, "provocations")
     |> assign(:selected_media, media)
     |> assign(:provocations, provocations)}
  end

  @impl true
  def handle_event("export_text", %{"id" => id, "format" => format}, socket) do
    media_id = String.to_integer(id)
    format_atom = String.to_atom(format)
    text = Media.export_exhibition_text(media_id, format_atom)

    # Copy to clipboard via JS hook
    {:noreply,
     socket
     |> push_event("copy-to-clipboard", %{text: text})
     |> put_flash(:info, "Exhibition text copied to clipboard!")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div class="mb-8">
        <h1 class="text-3xl font-bold text-gray-900">Analysis Insights</h1>
        <p class="mt-2 text-sm text-gray-600">
          Explore patterns, connections, and insights from your artwork analyses
        </p>
      </div>

      <div class="mb-6 flex space-x-4 border-b border-gray-200">
        <button
          phx-click="change_view"
          phx-value-view="overview"
          class={[
            "px-4 py-2 font-medium text-sm border-b-2 transition-colors",
            if(@view == "overview",
              do: "border-indigo-500 text-indigo-600",
              else: "border-transparent text-gray-500 hover:text-gray-700"
            )
          ]}
        >
          Overview
        </button>
        <button
          phx-click="change_view"
          phx-value-view="series"
          class={[
            "px-4 py-2 font-medium text-sm border-b-2 transition-colors",
            if(@view == "series",
              do: "border-indigo-500 text-indigo-600",
              else: "border-transparent text-gray-500 hover:text-gray-700"
            )
          ]}
        >
          Series & Collections
        </button>
        <button
          phx-click="change_view"
          phx-value-view="movements"
          class={[
            "px-4 py-2 font-medium text-sm border-b-2 transition-colors",
            if(@view == "movements",
              do: "border-indigo-500 text-indigo-600",
              else: "border-transparent text-gray-500 hover:text-gray-700"
            )
          ]}
        >
          Artistic Connections
        </button>
        <button
          phx-click="change_view"
          phx-value-view="themes"
          class={[
            "px-4 py-2 font-medium text-sm border-b-2 transition-colors",
            if(@view == "themes",
              do: "border-indigo-500 text-indigo-600",
              else: "border-transparent text-gray-500 hover:text-gray-700"
            )
          ]}
        >
          Themes
        </button>
      </div>

      <%= case @view do %>
        <% "overview" -> %>
          <%= render_overview(assigns) %>
        <% "series" -> %>
          <%= render_series(assigns) %>
        <% "movements" -> %>
          <%= render_movements(assigns) %>
        <% "themes" -> %>
          <%= render_themes(assigns) %>
        <% "search" -> %>
          <%= render_search_results(assigns) %>
        <% "provocations" -> %>
          <%= render_provocations(assigns) %>
      <% end %>
    </div>
    """
  end

  defp render_overview(assigns) do
    ~H"""
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
      <div class="bg-white rounded-lg shadow p-6">
        <div class="text-sm font-medium text-gray-500">Total Analyses</div>
        <div class="mt-2 text-3xl font-bold text-gray-900"><%= @stats.total_analyses %></div>
        <div class="mt-1 text-sm text-gray-600">
          across <%= @stats.total_media_analyzed %> artworks
        </div>
      </div>

      <div class="bg-white rounded-lg shadow p-6">
        <div class="text-sm font-medium text-gray-500">Series Identified</div>
        <div class="mt-2 text-3xl font-bold text-gray-900"><%= map_size(@series_map) %></div>
        <div class="mt-1 text-sm text-gray-600">distinct bodies of work</div>
      </div>

      <div class="bg-white rounded-lg shadow p-6">
        <div class="text-sm font-medium text-gray-500">Memorial Works</div>
        <div class="mt-2 text-3xl font-bold text-gray-900"><%= @stats.themes.memorial %></div>
        <div class="mt-1 text-sm text-gray-600">works exploring grief & memory</div>
      </div>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
      <div class="bg-white rounded-lg shadow p-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">
          Top Artistic Connections
        </h3>
        <div class="space-y-2">
          <%= for %{connection: connection, frequency: freq} <- @top_movements do %>
            <div class="flex items-center justify-between p-2 hover:bg-gray-50 rounded cursor-pointer">
              <span class="text-sm text-gray-700"><%= connection %></span>
              <span class="text-xs bg-indigo-100 text-indigo-800 px-2 py-1 rounded">
                <%= freq %>x
              </span>
            </div>
          <% end %>
        </div>
      </div>

      <div class="bg-white rounded-lg shadow p-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">Top Contexts</h3>
        <div class="space-y-2">
          <%= for %{context: context, frequency: freq} <- @top_contexts do %>
            <div class="flex items-center justify-between p-2 hover:bg-gray-50 rounded">
              <span class="text-sm text-gray-700"><%= context %></span>
              <span class="text-xs bg-green-100 text-green-800 px-2 py-1 rounded">
                <%= freq %>x
              </span>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  defp render_series(assigns) do
    ~H"""
    <div class="space-y-6">
      <%= for {series_name, works} <- @series_map do %>
        <div class="bg-white rounded-lg shadow p-6">
          <div class="flex items-center justify-between mb-4">
            <h3 class="text-lg font-semibold text-gray-900"><%= series_name %></h3>
            <span class="text-sm text-gray-500"><%= length(works) %> works</span>
          </div>
          <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
            <%= for media <- works do %>
              <div class="relative group">
                <img
                  src={Olivia.Media.MediaFile.resolved_thumb_url(media) || Olivia.Media.MediaFile.resolved_url(media)}
                  alt={media.filename}
                  class="w-full h-32 object-cover rounded"
                />
                <div class="absolute inset-0 bg-black bg-opacity-0 group-hover:bg-opacity-50 transition-opacity rounded flex items-end p-2">
                  <button
                    phx-click="view_provocations"
                    phx-value-id={media.id}
                    class="opacity-0 group-hover:opacity-100 text-white text-xs bg-indigo-600 px-2 py-1 rounded"
                  >
                    View Questions
                  </button>
                </div>
              </div>
            <% end %>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  defp render_movements(assigns) do
    ~H"""
    <div class="bg-white rounded-lg shadow p-6">
      <div class="mb-6">
        <label class="block text-sm font-medium text-gray-700 mb-2">
          Search by Artist or Movement
        </label>
        <form phx-change="search_movement">
          <input
            type="text"
            name="term"
            value={@search_term}
            placeholder="e.g., Matisse, Post-Impressionism, Scottish Colourists..."
            class="w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
          />
        </form>
      </div>

      <div class="space-y-3">
        <h4 class="text-sm font-medium text-gray-700">Frequently Referenced:</h4>
        <%= for %{connection: connection, frequency: freq} <- Media.get_top_artistic_connections(15) do %>
          <button
            phx-click="search_movement"
            phx-value-term={connection}
            class="inline-flex items-center px-3 py-1 rounded-full text-sm bg-gray-100 hover:bg-indigo-100 text-gray-800 hover:text-indigo-800 transition-colors mr-2 mb-2"
          >
            <%= connection %>
            <span class="ml-2 text-xs bg-white px-1.5 py-0.5 rounded-full"><%= freq %></span>
          </button>
        <% end %>
      </div>
    </div>
    """
  end

  defp render_themes(assigns) do
    ~H"""
    <div class="bg-white rounded-lg shadow p-6">
      <div class="mb-6">
        <label class="block text-sm font-medium text-gray-700 mb-2">
          Search by Theme
        </label>
        <form phx-change="search_theme">
          <input
            type="text"
            name="term"
            value={@search_term}
            placeholder="e.g., memorial, garden, travel, figure..."
            class="w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
          />
        </form>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div class="p-4 bg-purple-50 rounded-lg">
          <div class="text-sm font-medium text-purple-900">Memorial Works</div>
          <div class="text-2xl font-bold text-purple-600"><%= @stats.themes.memorial %></div>
        </div>
        <div class="p-4 bg-green-50 rounded-lg">
          <div class="text-sm font-medium text-green-900">Garden & Cultivation</div>
          <div class="text-2xl font-bold text-green-600"><%= @stats.themes.garden %></div>
        </div>
        <div class="p-4 bg-blue-50 rounded-lg">
          <div class="text-sm font-medium text-blue-900">Travel</div>
          <div class="text-2xl font-bold text-blue-600"><%= @stats.themes.travel %></div>
        </div>
        <div class="p-4 bg-orange-50 rounded-lg">
          <div class="text-sm font-medium text-orange-900">Portrait & Figure</div>
          <div class="text-2xl font-bold text-orange-600"><%= @stats.themes.portrait %></div>
        </div>
      </div>
    </div>
    """
  end

  defp render_search_results(assigns) do
    ~H"""
    <div>
      <div class="mb-4">
        <a
          href="#"
          phx-click="change_view"
          phx-value-view={if(@search_type == "movement", do: "movements", else: "themes")}
          class="text-sm text-indigo-600 hover:text-indigo-800"
        >
          ← Back
        </a>
      </div>

      <div class="bg-white rounded-lg shadow p-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">
          Found <%= length(@search_results) %> works for "<%= @search_term %>"
        </h3>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
          <%= for media <- @search_results do %>
            <div class="border rounded-lg p-4 hover:shadow-lg transition-shadow">
              <img
                src={Olivia.Media.MediaFile.resolved_thumb_url(media) || Olivia.Media.MediaFile.resolved_url(media)}
                alt={media.filename}
                class="w-full h-48 object-cover rounded mb-3"
              />
              <h4 class="font-medium text-gray-900 text-sm mb-2">
                <%= String.replace(media.filename, ~r/\.(jpg|png|jpeg)/i, "") %>
              </h4>
              <div class="flex flex-wrap gap-1 mb-3">
                <%= for tag <- Enum.take(media.tags || [], 3) do %>
                  <span class="text-xs bg-gray-100 text-gray-600 px-2 py-0.5 rounded">
                    <%= tag %>
                  </span>
                <% end %>
              </div>
              <div class="flex space-x-2">
                <button
                  phx-click="view_provocations"
                  phx-value-id={media.id}
                  class="text-xs bg-indigo-600 text-white px-3 py-1 rounded hover:bg-indigo-700"
                >
                  Questions
                </button>
                <button
                  phx-click="export_text"
                  phx-value-id={media.id}
                  phx-value-format="short"
                  class="text-xs bg-green-600 text-white px-3 py-1 rounded hover:bg-green-700"
                >
                  Export Text
                </button>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  defp render_provocations(assigns) do
    ~H"""
    <div>
      <div class="mb-4">
        <button
          phx-click="change_view"
          phx-value-view="overview"
          class="text-sm text-indigo-600 hover:text-indigo-800"
        >
          ← Back to Overview
        </button>
      </div>

      <div class="bg-white rounded-lg shadow p-6">
        <div class="flex items-start space-x-4 mb-6">
          <img
            src={Olivia.Media.MediaFile.resolved_thumb_url(@selected_media) || Olivia.Media.MediaFile.resolved_url(@selected_media)}
            alt={@selected_media.filename}
            class="w-48 h-48 object-cover rounded"
          />
          <div class="flex-1">
            <h3 class="text-xl font-semibold text-gray-900 mb-2">
              <%= String.replace(@selected_media.filename, ~r/\.(jpg|png|jpeg)/i, "") %>
            </h3>
            <div class="flex flex-wrap gap-2 mb-4">
              <%= for tag <- @selected_media.tags || [] do %>
                <span class="text-xs bg-gray-100 text-gray-600 px-2 py-1 rounded">
                  <%= tag %>
                </span>
              <% end %>
            </div>
            <div class="flex space-x-2">
              <button
                phx-click="export_text"
                phx-value-id={@selected_media.id}
                phx-value-format="short"
                class="text-sm bg-green-600 text-white px-4 py-2 rounded hover:bg-green-700"
              >
                Export Short Text
              </button>
              <button
                phx-click="export_text"
                phx-value-id={@selected_media.id}
                phx-value-format="long"
                class="text-sm bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700"
              >
                Export Full Text
              </button>
            </div>
          </div>
        </div>

        <div class="border-t pt-6">
          <h4 class="text-lg font-semibold text-gray-900 mb-4">
            Studio Questions (<%= length(@provocations) %>)
          </h4>
          <p class="text-sm text-gray-600 mb-4">
            These questions are designed to deepen your practice and push your work further.
          </p>
          <div class="space-y-4">
            <%= for {provocation, index} <- Enum.with_index(@provocations, 1) do %>
              <div class="bg-indigo-50 border-l-4 border-indigo-400 p-4">
                <div class="flex">
                  <div class="flex-shrink-0">
                    <span class="inline-flex items-center justify-center h-6 w-6 rounded-full bg-indigo-500 text-white text-xs font-bold">
                      <%= index %>
                    </span>
                  </div>
                  <div class="ml-3">
                    <p class="text-sm text-gray-800"><%= provocation %></p>
                  </div>
                </div>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
