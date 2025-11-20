defmodule OliviaWeb.Admin.MediaLive.Spatial do
  @moduledoc """
  Spatial organizer for creating visual relationships between artworks.
  Uses Cytoscape.js for interactive canvas with drag-and-drop.
  """

  use OliviaWeb, :live_view

  alias Olivia.{Media, Spatial}

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex h-screen overflow-hidden bg-gray-50">
      <!-- Left: Thumbnail Palette -->
      <div class="w-80 overflow-y-auto border-r border-gray-200 bg-white p-4">
        <div class="mb-4">
          <h2 class="text-lg font-semibold text-gray-900">Media Library</h2>
          <p class="text-sm text-gray-600 mt-1">
            Drag images onto the canvas to create connections
          </p>
        </div>

        <!-- Filters -->
        <div class="mb-4">
          <form phx-change="filter_status">
            <select
              name="status_filter"
              class="w-full rounded-md border-gray-300 text-sm"
            >
              <option value="all" selected={@status_filter == "all"}>All Media</option>
              <option value="approved" selected={@status_filter == "approved"}>
                Approved Only
              </option>
              <option value="quarantine" selected={@status_filter == "quarantine"}>
                Quarantine
              </option>
            </select>
          </form>
        </div>

        <!-- Palette Grid -->
        <div class="grid grid-cols-2 gap-3">
          <div
            :for={media <- @palette_media}
            phx-hook="DraggableMedia"
            id={"draggable-#{media.id}"}
            data-media-id={media.id}
            data-image-url={media.url}
            draggable="true"
            class="group relative aspect-square cursor-grab overflow-hidden rounded-lg bg-gray-100 active:cursor-grabbing"
          >
            <img src={Olivia.Media.MediaFile.resolved_url(media)} alt={media.alt_text || media.filename} class="h-full w-full object-cover" loading="lazy" />

            <div class="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent opacity-0 group-hover:opacity-100 transition-opacity">
              <div class="absolute bottom-0 left-0 right-0 p-2 text-white">
                <div class="text-xs font-medium truncate"><%= media.filename %></div>
              </div>
            </div>

            <!-- Already in canvas indicator -->
            <%= if media.id in @current_media_ids do %>
              <div class="absolute top-1 right-1">
                <span class="inline-flex items-center rounded-full bg-green-600 px-2 py-1 text-xs font-medium text-white">
                  ✓
                </span>
              </div>
            <% end %>
          </div>
        </div>

        <%= if @has_more_media do %>
          <div class="mt-4 text-center">
            <button
              type="button"
              phx-click="load_more_media"
              class="text-sm text-indigo-600 hover:text-indigo-700 font-medium"
            >
              Load More...
            </button>
          </div>
        <% end %>
      </div>

      <!-- Right: Cytoscape Canvas -->
      <div class="flex-1 flex flex-col">
        <!-- Toolbar -->
        <div class="flex items-center justify-between border-b border-gray-200 bg-white px-6 py-4">
          <div class="flex items-center gap-4">
            <h1 class="text-2xl font-bold text-gray-900">
              <%= if @current_collection, do: @current_collection.name, else: "Spatial Organizer" %>
            </h1>

            <%= if @current_collection do %>
              <span class="inline-flex items-center rounded-full bg-green-100 px-3 py-1 text-sm font-medium text-green-800">
                <%= length(@canvas_nodes) %> items
              </span>
            <% end %>
          </div>

          <div class="flex items-center gap-2">
            <!-- Layout Options -->
            <div class="relative" x-data="{ open: false }">
              <button
                type="button"
                @click="open = !open"
                class="inline-flex items-center rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
              >
                <.icon name="hero-squares-2x2" class="w-4 h-4 mr-2" />
                Layout
                <.icon name="hero-chevron-down" class="w-4 h-4 ml-1" />
              </button>

              <div
                x-show="open"
                @click.away="open = false"
                class="absolute right-0 z-10 mt-2 w-48 origin-top-right rounded-md bg-white shadow-lg ring-1 ring-black ring-opacity-5"
                style="display: none;"
              >
                <div class="py-1">
                  <button
                    type="button"
                    phx-click="apply_layout"
                    phx-value-layout="grid"
                    class="block w-full px-4 py-2 text-left text-sm text-gray-700 hover:bg-gray-100"
                  >
                    Grid Layout
                  </button>
                  <button
                    type="button"
                    phx-click="apply_layout"
                    phx-value-layout="circle"
                    class="block w-full px-4 py-2 text-left text-sm text-gray-700 hover:bg-gray-100"
                  >
                    Circle Layout
                  </button>
                  <button
                    type="button"
                    phx-click="apply_layout"
                    phx-value-layout="concentric"
                    class="block w-full px-4 py-2 text-left text-sm text-gray-700 hover:bg-gray-100"
                  >
                    Concentric Layout
                  </button>
                </div>
              </div>
            </div>

            <!-- Clear Canvas -->
            <button
              type="button"
              phx-click="clear_canvas"
              data-confirm="Are you sure you want to clear the entire canvas?"
              class="inline-flex items-center rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
            >
              <.icon name="hero-trash" class="w-4 h-4 mr-2" />
              Clear
            </button>

            <!-- Save/Load -->
            <button
              type="button"
              phx-click="show_save_modal"
              class="inline-flex items-center rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500"
            >
              <.icon name="hero-folder-arrow-down" class="w-4 h-4 mr-2" />
              Save
            </button>

            <button
              type="button"
              phx-click="show_load_modal"
              class="inline-flex items-center rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
            >
              <.icon name="hero-folder-open" class="w-4 h-4 mr-2" />
              Load
            </button>

            <button
              type="button"
              id="export-spatial-data-btn"
              phx-hook="CopyToClipboard"
              data-copy-text=""
              class="inline-flex items-center rounded-md bg-emerald-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-emerald-500"
            >
              <.icon name="hero-clipboard-document" class="w-4 h-4 mr-2" />
              Export Data
            </button>
          </div>
        </div>

        <!-- Canvas Instructions -->
        <div class="bg-blue-50 border-b border-blue-100 px-6 py-2">
          <p class="text-sm text-blue-700">
            <span class="font-medium">Tips:</span>
            Drag images from the left palette onto the canvas •
            Right-click a node, then right-click another to create a connection •
            Select nodes and press Delete to remove them •
            Drag nodes to rearrange
          </p>
        </div>

        <!-- Cytoscape Canvas -->
        <div class="flex-1 relative min-h-[500px]">
          <div
            id="cytoscape-canvas"
            phx-hook="SpatialCanvas"
            phx-update="ignore"
            data-initial-data={if @current_collection, do: Jason.encode!(@graph_data), else: "{}"}
            class="absolute inset-0 bg-white"
            style="border: 2px dashed #E5E7EB; transition: border-color 0.2s; min-height: 100%;"
          >
          </div>
        </div>
      </div>

      <!-- Right: Qualification Panel -->
      <%= if @selected_media do %>
        <div class="w-96 overflow-y-auto border-l border-gray-200 bg-white">
          <div class="sticky top-0 z-10 bg-white border-b border-gray-200 px-4 py-3">
            <div class="flex items-center justify-between">
              <h3 class="text-lg font-semibold text-gray-900">Qualify Image</h3>
              <button
                phx-click="close_qualification"
                class="text-gray-400 hover:text-gray-600"
              >
                <.icon name="hero-x-mark" class="w-5 h-5" />
              </button>
            </div>
          </div>

          <div class="p-4 space-y-6">
            <!-- Image Preview -->
            <div class="aspect-square overflow-hidden rounded-lg bg-gray-100">
              <img src={Olivia.Media.MediaFile.resolved_url(@selected_media)} alt={@selected_media.filename} class="w-full h-full object-cover" />
            </div>

            <!-- Deterministic Data Section -->
            <div class="space-y-3">
              <h4 class="text-sm font-semibold text-gray-900 uppercase tracking-wide">File Information</h4>

              <div>
                <label class="block text-xs font-medium text-gray-700 mb-1">Filename</label>
                <p class="text-sm text-gray-900"><%= @selected_media.filename %></p>
              </div>

              <div>
                <label class="block text-xs font-medium text-gray-700 mb-1">Dimensions</label>
                <p class="text-sm text-gray-900"><%= @selected_media.width %> × <%= @selected_media.height %>px</p>
              </div>

              <div>
                <label class="block text-xs font-medium text-gray-700 mb-1">Status</label>
                <select
                  name="status"
                  phx-change="update_media_status"
                  phx-value-media-id={@selected_media.id}
                  class="w-full rounded-md border-gray-300 text-sm"
                >
                  <option value="quarantine" selected={@selected_media.status == "quarantine"}>Quarantine</option>
                  <option value="approved" selected={@selected_media.status == "approved"}>Approved</option>
                  <option value="archived" selected={@selected_media.status == "archived"}>Archived</option>
                </select>
              </div>

              <div>
                <label class="block text-xs font-medium text-gray-700 mb-1">Alt Text</label>
                <form phx-submit="update_media_alt_text" phx-value-media-id={@selected_media.id}>
                  <input
                    type="text"
                    name="alt_text"
                    value={@selected_media.alt_text}
                    placeholder="Describe this image..."
                    class="w-full rounded-md border-gray-300 text-sm"
                  />
                </form>
              </div>

              <div>
                <label class="block text-xs font-medium text-gray-700 mb-1">Tags</label>
                <div class="flex flex-wrap gap-1">
                  <%= for tag <- @selected_media.tags || [] do %>
                    <span class="inline-flex items-center gap-1 rounded-full bg-indigo-100 px-2 py-1 text-xs text-indigo-700">
                      <%= tag %>
                    </span>
                  <% end %>
                </div>
              </div>
            </div>

            <!-- Spatial Context Section -->
            <%= if @spatial_context do %>
              <div class="space-y-3">
                <h4 class="text-sm font-semibold text-gray-900 uppercase tracking-wide">Spatial Context</h4>

                <div>
                  <label class="block text-xs font-medium text-gray-700 mb-1">Canvas Position</label>
                  <p class="text-sm text-gray-600">
                    x: <%= Float.round(@spatial_context.position["x"] * 1.0, 1) %>,
                    y: <%= Float.round(@spatial_context.position["y"] * 1.0, 1) %>
                  </p>
                </div>

                <%= if @spatial_context.nearby_nodes && length(@spatial_context.nearby_nodes) > 0 do %>
                  <div>
                    <label class="block text-xs font-medium text-gray-700 mb-1">Nearby Images</label>
                    <p class="text-sm text-gray-600"><%= length(@spatial_context.nearby_nodes) %> within proximity</p>
                  </div>
                <% end %>

                <%= if @spatial_context.connections && length(@spatial_context.connections) > 0 do %>
                  <div>
                    <label class="block text-xs font-medium text-gray-700 mb-1">Connections</label>
                    <p class="text-sm text-gray-600"><%= length(@spatial_context.connections) %> edges</p>
                  </div>
                <% end %>
              </div>
            <% end %>

            <!-- LLM Analysis Section -->
            <div class="space-y-3">
              <div class="flex items-center justify-between">
                <h4 class="text-sm font-semibold text-gray-900 uppercase tracking-wide">AI Analysis</h4>
                <button
                  phx-click="trigger_llm_analysis"
                  phx-value-media-id={@selected_media.id}
                  class="text-xs text-indigo-600 hover:text-indigo-700 font-medium"
                >
                  + New Analysis
                </button>
              </div>

              <%= if @selected_analyses && length(@selected_analyses) > 0 do %>
                <%= for analysis <- Enum.take(@selected_analyses, 1) do %>
                  <div class="rounded-lg bg-purple-50 p-3 space-y-2">
                    <div class="flex items-center justify-between">
                      <span class="text-xs font-medium text-purple-900">Iteration <%= analysis.iteration %></span>
                      <span class="text-xs text-purple-600"><%= analysis.model_used %></span>
                    </div>

                    <%= if analysis.llm_response["interpretation"] do %>
                      <div>
                        <p class="text-xs font-medium text-purple-900 mb-1">Interpretation</p>
                        <p class="text-xs text-purple-800"><%= analysis.llm_response["interpretation"] %></p>
                      </div>
                    <% end %>

                    <%= if analysis.llm_response["contexts"] && is_list(analysis.llm_response["contexts"]) && length(analysis.llm_response["contexts"]) > 0 do %>
                      <div>
                        <p class="text-xs font-medium text-purple-900 mb-1">Suggested Contexts</p>
                        <ul class="text-xs text-purple-800 space-y-1">
                          <%= for context <- Enum.take(analysis.llm_response["contexts"], 3) do %>
                            <li>• <%= if is_binary(context), do: context, else: context["name"] || inspect(context) %></li>
                          <% end %>
                        </ul>
                      </div>
                    <% end %>
                  </div>
                <% end %>
              <% else %>
                <p class="text-sm text-gray-500 italic">No AI analysis yet. Click "+ New Analysis" to generate insights.</p>
              <% end %>
            </div>

            <!-- Actions -->
            <div class="pt-4 border-t border-gray-200">
              <button
                phx-click="trigger_llm_analysis_with_context"
                phx-value-media-id={@selected_media.id}
                class="w-full inline-flex items-center justify-center rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500"
              >
                <.icon name="hero-sparkles" class="w-4 h-4 mr-2" />
                Analyze with Spatial Context
              </button>
            </div>
          </div>
        </div>
      <% end %>

      <!-- Save Modal -->
      <%= if @show_save_modal do %>
        <div class="fixed inset-0 z-50 overflow-y-auto" phx-click="hide_save_modal">
          <div class="flex min-h-full items-end justify-center p-4 text-center sm:items-center sm:p-0">
            <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity"></div>

            <div
              class="relative transform overflow-hidden rounded-lg bg-white px-4 pb-4 pt-5 text-left shadow-xl transition-all sm:my-8 sm:w-full sm:max-w-lg sm:p-6"
              phx-click="stop_propagation"
            >
              <div>
                <h3 class="text-lg font-semibold leading-6 text-gray-900 mb-4">
                  <%= if @current_collection, do: "Update Collection", else: "Save Collection" %>
                </h3>

                <form phx-submit="save_collection">
                  <div class="mb-4">
                    <label for="collection_name" class="block text-sm font-medium text-gray-700 mb-2">
                      Collection Name
                    </label>
                    <input
                      type="text"
                      id="collection_name"
                      name="name"
                      value={if @current_collection, do: @current_collection.name, else: ""}
                      placeholder="e.g., Gallery Wall Ideas"
                      required
                      class="block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                    />
                  </div>

                  <div class="mb-4">
                    <label for="collection_description" class="block text-sm font-medium text-gray-700 mb-2">
                      Description (Optional)
                    </label>
                    <textarea
                      id="collection_description"
                      name="description"
                      rows="3"
                      placeholder="Add notes about this collection..."
                      class="block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                    ><%= if @current_collection, do: @current_collection.description, else: "" %></textarea>
                  </div>

                  <div class="flex gap-3 justify-end">
                    <button
                      type="button"
                      phx-click="hide_save_modal"
                      class="rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
                    >
                      Cancel
                    </button>
                    <button
                      type="submit"
                      class="rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500"
                    >
                      <.icon name="hero-check" class="w-4 h-4 inline mr-1" />
                      Save
                    </button>
                  </div>
                </form>
              </div>
            </div>
          </div>
        </div>
      <% end %>

      <!-- Load Modal -->
      <%= if @show_load_modal do %>
        <div class="fixed inset-0 z-50 overflow-y-auto" phx-click="hide_load_modal">
          <div class="flex min-h-full items-end justify-center p-4 text-center sm:items-center sm:p-0">
            <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity"></div>

            <div
              class="relative transform overflow-hidden rounded-lg bg-white px-4 pb-4 pt-5 text-left shadow-xl transition-all sm:my-8 sm:w-full sm:max-w-2xl sm:p-6"
              phx-click="stop_propagation"
            >
              <div>
                <h3 class="text-lg font-semibold leading-6 text-gray-900 mb-4">
                  Load Collection
                </h3>

                <%= if @collections == [] do %>
                  <p class="text-sm text-gray-600 py-8 text-center">
                    No saved collections yet. Create your first one by arranging images on the canvas and clicking Save.
                  </p>
                <% else %>
                  <div class="space-y-2 max-h-96 overflow-y-auto">
                    <div
                      :for={collection <- @collections}
                      class="flex items-center justify-between p-4 rounded-lg border border-gray-200 hover:bg-gray-50 cursor-pointer"
                      phx-click="load_collection"
                      phx-value-id={collection.id}
                    >
                      <div class="flex-1">
                        <h4 class="font-medium text-gray-900"><%= collection.name %></h4>
                        <%= if collection.description do %>
                          <p class="text-sm text-gray-600 mt-1"><%= collection.description %></p>
                        <% end %>
                        <p class="text-xs text-gray-500 mt-1">
                          Updated <%= Calendar.strftime(collection.updated_at, "%B %d, %Y at %I:%M %p") %>
                        </p>
                      </div>

                      <div class="flex items-center gap-2 ml-4">
                        <button
                          type="button"
                          phx-click="delete_collection"
                          phx-value-id={collection.id}
                          data-confirm="Are you sure you want to delete this collection?"
                          class="text-red-600 hover:text-red-800"
                        >
                          <.icon name="hero-trash" class="w-5 h-5" />
                        </button>
                      </div>
                    </div>
                  </div>
                <% end %>

                <div class="mt-6 flex justify-end">
                  <button
                    type="button"
                    phx-click="hide_load_modal"
                    class="rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
                  >
                    Close
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    user_id = socket.assigns.current_scope.user.id

    {:ok,
     socket
     |> assign(:page_title, "Spatial Organizer")
     |> assign(:status_filter, "approved")
     |> assign(:media_page, 1)
     |> assign(:media_per_page, 20)
     |> assign(:has_more_media, true)
     |> assign(:current_collection, nil)
     |> assign(:collections, Spatial.list_collections(user_id))
     |> assign(:canvas_nodes, [])
     |> assign(:canvas_edges, [])
     |> assign(:current_media_ids, [])
     |> assign(:graph_data, %{nodes: [], edges: []})
     |> assign(:show_save_modal, false)
     |> assign(:show_load_modal, false)
     |> assign(:selected_media, nil)
     |> assign(:selected_analyses, [])
     |> assign(:spatial_context, nil)
     |> load_palette_media()}
  end

  @impl true
  def handle_event("filter_status", %{"status_filter" => status}, socket) do
    {:noreply,
     socket
     |> assign(:status_filter, status)
     |> assign(:media_page, 1)
     |> load_palette_media()}
  end

  @impl true
  def handle_event("load_more_media", _, socket) do
    {:noreply,
     socket
     |> assign(:media_page, socket.assigns.media_page + 1)
     |> load_palette_media()}
  end

  @impl true
  def handle_event("add_node_from_palette", %{"media_id" => media_id, "image_url" => image_url, "position" => position}, socket) do
    # Generate temporary node ID
    node_id = "node_#{:erlang.unique_integer([:positive])}"

    node_data = %{
      id: node_id,
      media_id: media_id,
      image_url: image_url,
      position: position
    }

    # Add to canvas state
    nodes = [node_data | socket.assigns.canvas_nodes]
    media_ids = [media_id | socket.assigns.current_media_ids]

    {:noreply,
     socket
     |> assign(:canvas_nodes, nodes)
     |> assign(:current_media_ids, media_ids)
     |> push_event("add_node", node_data)}
  end

  @impl true
  def handle_event("node_moved", %{"id" => node_id, "position" => position}, socket) do
    # Update the node position in state
    nodes = Enum.map(socket.assigns.canvas_nodes, fn node ->
      if node.id == node_id do
        %{node | position: position}
      else
        node
      end
    end)

    {:noreply, assign(socket, :canvas_nodes, nodes)}
  end

  @impl true
  def handle_event("node_selected", %{"id" => node_id, "media_id" => media_id}, socket) do
    # Load full media record with analyses
    media = Media.get_media!(media_id)
    analyses = Olivia.Repo.preload(media, :analyses).analyses
    |> Enum.sort_by(& &1.iteration, :desc)

    # Calculate spatial context
    selected_node = Enum.find(socket.assigns.canvas_nodes, fn n -> n.id == node_id end)

    spatial_context = if selected_node do
      %{
        position: selected_node.position,
        nearby_nodes: calculate_nearby_nodes(selected_node, socket.assigns.canvas_nodes),
        connections: find_node_connections(node_id, socket.assigns.canvas_edges)
      }
    else
      nil
    end

    {:noreply,
     socket
     |> assign(:selected_media, media)
     |> assign(:selected_analyses, analyses)
     |> assign(:spatial_context, spatial_context)}
  end

  @impl true
  def handle_event("create_edge", %{"source_id" => source_id, "target_id" => target_id}, socket) do
    edge_id = "edge_#{:erlang.unique_integer([:positive])}"

    edge_data = %{
      id: edge_id,
      source_id: source_id,
      target_id: target_id
    }

    edges = [edge_data | socket.assigns.canvas_edges]

    {:noreply,
     socket
     |> assign(:canvas_edges, edges)
     |> push_event("add_edge", edge_data)}
  end

  @impl true
  def handle_event("delete_nodes", %{"node_ids" => node_ids}, socket) do
    # Remove from state
    nodes = Enum.reject(socket.assigns.canvas_nodes, fn n -> n.id in node_ids end)
    media_ids = Enum.map(nodes, & &1.media_id)

    # Also remove edges connected to these nodes
    edges = Enum.reject(socket.assigns.canvas_edges, fn e ->
      e.source_id in node_ids or e.target_id in node_ids
    end)

    {:noreply,
     socket
     |> assign(:canvas_nodes, nodes)
     |> assign(:canvas_edges, edges)
     |> assign(:current_media_ids, media_ids)
     |> push_event("remove_nodes", %{node_ids: node_ids})}
  end

  @impl true
  def handle_event("delete_edges", %{"edge_ids" => edge_ids}, socket) do
    edges = Enum.reject(socket.assigns.canvas_edges, fn e -> e.id in edge_ids end)

    {:noreply,
     socket
     |> assign(:canvas_edges, edges)
     |> push_event("remove_edges", %{edge_ids: edge_ids})}
  end

  @impl true
  def handle_event("clear_canvas", _, socket) do
    {:noreply,
     socket
     |> assign(:canvas_nodes, [])
     |> assign(:canvas_edges, [])
     |> assign(:current_media_ids, [])
     |> push_event("clear_canvas", %{})}
  end

  @impl true
  def handle_event("apply_layout", %{"layout" => layout_type}, socket) do
    {:noreply, push_event(socket, "apply_layout", %{layout_type: layout_type})}
  end

  @impl true
  def handle_event("show_save_modal", _, socket) do
    {:noreply, assign(socket, :show_save_modal, true)}
  end

  @impl true
  def handle_event("hide_save_modal", _, socket) do
    {:noreply, assign(socket, :show_save_modal, false)}
  end

  @impl true
  def handle_event("show_load_modal", _, socket) do
    user_id = socket.assigns.current_scope.user.id
    collections = Spatial.list_collections(user_id)

    {:noreply,
     socket
     |> assign(:show_load_modal, true)
     |> assign(:collections, collections)}
  end

  @impl true
  def handle_event("hide_load_modal", _, socket) do
    {:noreply, assign(socket, :show_load_modal, false)}
  end

  @impl true
  def handle_event("save_collection", %{"name" => name, "description" => description}, socket) do
    user_id = socket.assigns.current_scope.user.id

    attrs = %{
      name: name,
      description: if(description == "", do: nil, else: description),
      user_id: user_id
    }

    result =
      if socket.assigns.current_collection do
        Spatial.update_collection(socket.assigns.current_collection, attrs)
      else
        Spatial.create_collection(attrs)
      end

    case result do
      {:ok, collection} ->
        # Save nodes and edges
        save_graph_state(collection.id, socket.assigns.canvas_nodes, socket.assigns.canvas_edges)

        {:noreply,
         socket
         |> assign(:current_collection, collection)
         |> assign(:show_save_modal, false)
         |> put_flash(:info, "Collection saved successfully")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to save collection")}
    end
  end

  @impl true
  def handle_event("load_collection", %{"id" => id}, socket) do
    collection = Spatial.get_collection_with_data!(id)

    # Convert to graph data
    nodes =
      Enum.map(collection.nodes, fn node ->
        %{
          id: "node_#{node.id}",
          media_id: node.media_file_id,
          image_url: node.media_file.url,
          position: %{x: node.position_x, y: node.position_y}
        }
      end)

    edges =
      Enum.map(collection.edges, fn edge ->
        %{
          id: "edge_#{edge.id}",
          source_id: "node_#{edge.source_node_id}",
          target_id: "node_#{edge.target_node_id}"
        }
      end)

    media_ids = Enum.map(nodes, & &1.media_id)

    graph_data = %{nodes: nodes, edges: edges}

    {:noreply,
     socket
     |> assign(:current_collection, collection)
     |> assign(:canvas_nodes, nodes)
     |> assign(:canvas_edges, edges)
     |> assign(:current_media_ids, media_ids)
     |> assign(:graph_data, graph_data)
     |> assign(:show_load_modal, false)
     |> push_event("load_graph", graph_data)}
  end

  @impl true
  def handle_event("delete_collection", %{"id" => id}, socket) do
    collection = Spatial.get_collection!(id)
    user_id = socket.assigns.current_scope.user.id

    case Spatial.delete_collection(collection) do
      {:ok, _} ->
        collections = Spatial.list_collections(user_id)

        socket =
          if socket.assigns.current_collection && socket.assigns.current_collection.id == collection.id do
            assign(socket, :current_collection, nil)
          else
            socket
          end

        {:noreply,
         socket
         |> assign(:collections, collections)
         |> put_flash(:info, "Collection deleted")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to delete collection")}
    end
  end

  @impl true
  def handle_event("stop_propagation", _, socket), do: {:noreply, socket}

  defp load_palette_media(socket) do
    filters = build_media_filters(socket.assigns)
    media = Media.list_media(filters)

    socket
    |> assign(:palette_media, media)
    |> assign(:has_more_media, length(media) >= socket.assigns.media_per_page)
  end

  defp build_media_filters(assigns) do
    [
      limit: assigns.media_per_page,
      offset: (assigns.media_page - 1) * assigns.media_per_page,
      order_by: {:desc, :inserted_at}
    ]
    |> maybe_add_status_filter(assigns.status_filter)
  end

  defp maybe_add_status_filter(filters, "all"), do: filters
  defp maybe_add_status_filter(filters, status), do: Keyword.put(filters, :status, status)

  defp save_graph_state(collection_id, nodes, edges) do
    # Convert temporary IDs to database format
    nodes_data =
      Enum.map(nodes, fn node ->
        %{
          media_file_id: node.media_id,
          position_x: node.position["x"],
          position_y: node.position["y"],
          cytoscape_id: node.id,
          node_data: %{}
        }
      end)

    edges_data =
      Enum.map(edges, fn edge ->
        %{
          source_cytoscape_id: edge.source_id,
          target_cytoscape_id: edge.target_id,
          edge_data: %{}
        }
      end)

    Spatial.save_graph_state(collection_id, nodes_data, edges_data)
  end

  # Qualification Panel Event Handlers

  @impl true
  def handle_event("close_qualification", _, socket) do
    {:noreply,
     socket
     |> assign(:selected_media, nil)
     |> assign(:selected_analyses, [])
     |> assign(:spatial_context, nil)}
  end

  @impl true
  def handle_event("update_media_status", %{"media-id" => media_id, "value" => status}, socket) do
    media = Media.get_media!(String.to_integer(media_id))
    {:ok, updated_media} = Media.update_media(media, %{status: status})

    {:noreply, assign(socket, :selected_media, updated_media)}
  end

  @impl true
  def handle_event("update_media_alt_text", %{"media-id" => media_id, "alt_text" => alt_text}, socket) do
    media = Media.get_media!(String.to_integer(media_id))
    {:ok, updated_media} = Media.update_media(media, %{alt_text: alt_text})

    {:noreply, assign(socket, :selected_media, updated_media)}
  end

  @impl true
  def handle_event("trigger_llm_analysis", %{"media-id" => media_id}, socket) do
    media = Media.get_media!(String.to_integer(media_id))

    # Trigger async LLM analysis
    Task.start(fn ->
      # This will call your existing vision analyzer
      # The analysis will be stored in the database
      Olivia.Media.analyze_media(media.id)
    end)

    {:noreply,
     socket
     |> put_flash(:info, "AI analysis started. Refresh to see results.")}
  end

  @impl true
  def handle_event("trigger_llm_analysis_with_context", %{"media-id" => media_id}, socket) do
    media = Media.get_media!(String.to_integer(media_id))
    spatial_context = socket.assigns.spatial_context

    # Check if we have spatial context (media must be on canvas, not just selected from palette)
    if spatial_context do
      # Build context string from spatial positioning
      context_prompt = build_spatial_context_prompt(spatial_context, socket.assigns.canvas_nodes)

      # Trigger async LLM analysis with spatial context
      Task.start(fn ->
        Olivia.Media.analyze_with_context(media.id, context_prompt)
      end)

      {:noreply,
       socket
       |> put_flash(:info, "AI analysis with spatial context started. Refresh to see results.")}
    else
      # No spatial context - fall back to regular analysis
      Task.start(fn ->
        Olivia.Media.analyze_media(media.id)
      end)

      {:noreply,
       socket
       |> put_flash(:warning, "No spatial context available (add media to canvas first). Running standard analysis.")}
    end
  end

  # Helper Functions for Spatial Context

  defp calculate_nearby_nodes(selected_node, all_nodes, proximity_threshold \\ 200) do
    all_nodes
    |> Enum.reject(fn n -> n.id == selected_node.id end)
    |> Enum.filter(fn n ->
      distance = calculate_distance(selected_node.position, n.position)
      distance <= proximity_threshold
    end)
  end

  defp calculate_distance(pos1, pos2) do
    dx = pos1["x"] - pos2["x"]
    dy = pos1["y"] - pos2["y"]
    :math.sqrt(dx * dx + dy * dy)
  end

  defp find_node_connections(node_id, edges) do
    Enum.filter(edges, fn edge ->
      edge.source_id == node_id or edge.target_id == node_id
    end)
  end

  defp build_spatial_context_prompt(spatial_context, _all_nodes) do
    """
    This image is positioned on a spatial canvas at coordinates (#{Float.round(spatial_context.position["x"] * 1.0, 1)}, #{Float.round(spatial_context.position["y"] * 1.0, 1)}).

    #{if length(spatial_context.nearby_nodes) > 0 do
      "It has #{length(spatial_context.nearby_nodes)} nearby images within proximity, suggesting potential thematic or visual relationships."
    else
      "It is positioned in isolation, suggesting it may be a distinct or standalone piece."
    end}

    #{if length(spatial_context.connections) > 0 do
      "It has #{length(spatial_context.connections)} explicit connections to other images, indicating curatorial relationships."
    else
      "It has no explicit connections yet."
    end}

    Consider this spatial context when analyzing the image's role in the collection.
    """
  end
end
