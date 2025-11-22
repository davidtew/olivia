defmodule OliviaWeb.Admin.MediaLive.Workspace do
  @moduledoc """
  Unified media workspace for managing all images.

  Features:
  - Infinite scrolling grid of all media
  - Filter by status (quarantine, approved, archived)
  - Sort by date, filename, status
  - RHS panel with selected image details
  - Modal for AI analysis workflow
  - Expandable analysis history
  """

  use OliviaWeb, :live_view

  alias Olivia.Media
  alias Olivia.Media.Events
  alias Olivia.Uploads

  # Helper functions for error messages (must be defined before render)
  defp error_to_string(:too_large), do: "File is too large (max 10MB)"
  defp error_to_string(:not_accepted), do: "File type not accepted (use JPG, PNG, or WEBP)"
  defp error_to_string(:too_many_files), do: "Too many files (max 10)"
  defp error_to_string(_), do: "Unknown error"

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex h-screen overflow-hidden">
      <!-- Left: Image Grid -->
      <div class="flex-1 overflow-y-auto p-6">
        <div class="mb-6 flex items-start justify-between">
          <div>
            <h1 class="text-3xl font-bold text-gray-900 mb-2">Media Workspace</h1>
            <p class="text-sm text-gray-600">
              Manage, analyze, and organize all your images
            </p>
          </div>
          <div class="flex gap-2">
            <a
              href="/admin/media/spatial"
              class="inline-flex items-center rounded-md bg-white px-4 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
            >
              <.icon name="hero-squares-plus" class="w-4 h-4 mr-2" />
              Spatial Organizer
            </a>
            <button
              type="button"
              phx-click="show_upload_modal"
              class="inline-flex items-center rounded-md bg-indigo-600 px-4 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500"
            >
              <.icon name="hero-arrow-up-tray" class="w-4 h-4 mr-2" />
              Upload Images
            </button>
          </div>
        </div>

        <!-- Filters & Sorting -->
        <div class="mb-6 flex items-center gap-4 bg-white p-4 rounded-lg shadow-sm">
          <div class="flex-1">
            <form phx-change="search" phx-submit="search">
              <input
                type="text"
                name="q"
                value={@search_query}
                placeholder="Search by filename, tags, or description..."
                class="block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
              />
            </form>
          </div>

          <div class="flex gap-2">
            <select
              name="status_filter"
              phx-change="filter_status"
              class="rounded-md border-gray-300 text-sm"
            >
              <option value="all" selected={@status_filter == "all"}>All Status</option>
              <option value="quarantine" selected={@status_filter == "quarantine"}>
                Quarantine
              </option>
              <option value="approved" selected={@status_filter == "approved"}>Approved</option>
              <option value="archived" selected={@status_filter == "archived"}>Archived</option>
            </select>

            <select name="sort_by" phx-change="sort" class="rounded-md border-gray-300 text-sm">
              <option value="newest" selected={@sort_by == "newest"}>Newest First</option>
              <option value="oldest" selected={@sort_by == "oldest"}>Oldest First</option>
              <option value="filename" selected={@sort_by == "filename"}>Filename A-Z</option>
              <option value="status" selected={@sort_by == "status"}>Status</option>
            </select>
          </div>

          <div class="text-sm text-gray-600">
            <%= @stats.total_count %> images
          </div>
        </div>

        <!-- Image Grid -->
        <div class="grid grid-cols-2 gap-4 sm:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5">
          <div
            :for={media <- @media_list}
            class={[
              "group relative aspect-square overflow-hidden rounded-lg bg-gray-100 cursor-pointer",
              @selected_media && @selected_media.id == media.id && "ring-4 ring-indigo-500"
            ]}
            phx-click="select_media"
            phx-value-id={media.id}
          >
            <img src={Olivia.Media.MediaFile.resolved_url(media)} alt={media.alt_text || media.filename} class="h-full w-full object-cover" />

            <!-- Status Badge -->
            <div class="absolute top-2 left-2">
              <span class={[
                "inline-flex items-center rounded-full px-2 py-1 text-xs font-medium",
                status_badge_class(media.status)
              ]}>
                <%= status_label(media.status) %>
              </span>
            </div>

            <!-- Hover Overlay -->
            <div class="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent opacity-0 group-hover:opacity-100 transition-opacity">
              <div class="absolute bottom-0 left-0 right-0 p-3 text-white">
                <div class="text-xs font-medium truncate"><%= media.filename %></div>
                <div class="text-xs opacity-75">
                  <%= if media.asset_type, do: media.asset_type, else: "Unclassified" %>
                </div>
              </div>
            </div>

            <!-- Analysis Count -->
            <%= if media.analyses && length(media.analyses) > 0 do %>
              <div class="absolute top-2 right-2">
                <span class="inline-flex items-center rounded-full bg-indigo-600 px-2 py-1 text-xs font-medium text-white">
                  <%= length(media.analyses) %> analysis
                </span>
              </div>
            <% end %>
          </div>
        </div>

        <!-- Load More (Infinite Scroll Trigger) -->
        <%= if @has_more do %>
          <div id="load-more" phx-hook="InfiniteScroll" class="mt-8 text-center">
            <div class="inline-block h-8 w-8 animate-spin rounded-full border-4 border-solid border-indigo-600 border-r-transparent"></div>
          </div>
        <% end %>
      </div>

      <!-- Right: Details Panel -->
      <%= if @selected_media do %>
        <div class="w-96 overflow-y-auto border-l border-gray-200 bg-gray-50 p-6">
          <div class="mb-4 flex items-start justify-between">
            <h2 class="text-lg font-semibold text-gray-900">Image Details</h2>
            <button
              type="button"
              phx-click="close_panel"
              class="text-gray-400 hover:text-gray-600"
            >
              <.icon name="hero-x-mark" class="w-5 h-5" />
            </button>
          </div>

          <!-- Image Preview -->
          <div class="mb-4 aspect-square overflow-hidden rounded-lg bg-white">
            <img
              src={Olivia.Media.MediaFile.resolved_url(@selected_media)}
              alt={@selected_media.alt_text || @selected_media.filename}
              class="h-full w-full object-contain"
            />
          </div>

          <!-- Basic Info -->
          <div class="mb-4 space-y-2 text-sm">
            <div>
              <span class="font-medium text-gray-700">Filename:</span>
              <span class="ml-2 text-gray-900"><%= @selected_media.filename %></span>
            </div>
            <div>
              <span class="font-medium text-gray-700">Status:</span>
              <span class={["ml-2 inline-flex items-center rounded-full px-2 py-1 text-xs font-medium", status_badge_class(@selected_media.status)]}>
                <%= status_label(@selected_media.status) %>
              </span>
            </div>
            <%= if @selected_media.asset_type do %>
              <div>
                <span class="font-medium text-gray-700">Type:</span>
                <span class="ml-2 text-gray-900"><%= @selected_media.asset_type %></span>
              </div>
            <% end %>
            <%= if @selected_media.asset_role do %>
              <div>
                <span class="font-medium text-gray-700">Role:</span>
                <span class="ml-2 text-gray-900"><%= @selected_media.asset_role %></span>
              </div>
            <% end %>
          </div>

          <!-- Actions -->
          <div class="mb-6 flex gap-2">
            <button
              type="button"
              phx-click="show_analysis_modal"
              class="flex-1 rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500"
            >
              <.icon name="hero-sparkles" class="w-4 h-4 inline mr-1" />
              Analyze
            </button>

            <%= if @selected_media.status == "quarantine" do %>
              <button
                type="button"
                phx-click="approve_media"
                phx-value-id={@selected_media.id}
                class="rounded-md bg-green-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-green-500"
              >
                Approve
              </button>
            <% end %>

            <%= if @selected_media.status != "archived" do %>
              <button
                type="button"
                phx-click="show_archive_modal"
                class="rounded-md bg-amber-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-amber-500"
              >
                <.icon name="hero-archive-box" class="w-4 h-4 inline mr-1" />
                Archive
              </button>
            <% end %>
          </div>

          <!-- Analysis History -->
          <%= if @analyses && length(@analyses) > 0 do %>
            <div class="mb-4">
              <h3 class="mb-3 text-sm font-semibold text-gray-900">Analysis History</h3>

              <div class="space-y-3">
                <div
                  :for={{analysis, idx} <- Enum.with_index(@analyses)}
                  class="rounded-lg bg-white p-4 shadow-sm"
                >
                  <div class="mb-2 flex items-center justify-between">
                    <span class="text-xs font-medium text-gray-500">
                      Iteration <%= analysis.iteration %>
                    </span>
                    <button
                      type="button"
                      phx-click="toggle_analysis"
                      phx-value-index={idx}
                      class="text-gray-400 hover:text-gray-600"
                    >
                      <.icon
                        name={if idx in @expanded_analyses, do: "hero-chevron-up", else: "hero-chevron-down"}
                        class="w-4 h-4"
                      />
                    </button>
                  </div>

                  <%= if analysis.user_context do %>
                    <div class="mb-2 text-xs text-gray-600">
                      <span class="font-medium">You said:</span>
                      "<%= analysis.user_context %>"
                    </div>
                  <% end %>

                  <%= if idx in @expanded_analyses do %>
                    <div class="mt-3 space-y-2 text-xs text-gray-700">
                      <div>
                        <span class="font-medium">Interpretation:</span>
                        <p class="mt-1 text-gray-600">
                          <%= get_in(analysis.llm_response, ["interpretation"]) || "N/A" %>
                        </p>
                      </div>

                      <%= if contexts = get_in(analysis.llm_response, ["contexts"]) do %>
                        <div>
                          <span class="font-medium">Contexts:</span>
                          <ul class="mt-1 space-y-1">
                            <li :for={context <- contexts} class="text-gray-600">
                              • <%= context["name"] %>
                            </li>
                          </ul>
                        </div>
                      <% end %>

                      <%= if provocations = get_in(analysis.llm_response, ["provocations"]) do %>
                        <div>
                          <span class="font-medium">Questions:</span>
                          <ul class="mt-1 space-y-1">
                            <li :for={question <- provocations} class="text-gray-600">
                              • <%= question %>
                            </li>
                          </ul>
                        </div>
                      <% end %>
                    </div>
                  <% else %>
                    <p class="text-xs text-gray-500">
                      Click to expand...
                    </p>
                  <% end %>
                </div>
              </div>
            </div>
          <% end %>

          <!-- Tags -->
          <%= if @selected_media.tags && length(@selected_media.tags) > 0 do %>
            <div class="mb-4">
              <h3 class="mb-2 text-sm font-semibold text-gray-900">Tags</h3>
              <div class="flex flex-wrap gap-2">
                <span
                  :for={tag <- @selected_media.tags}
                  class="inline-flex items-center rounded-full bg-indigo-100 px-2 py-1 text-xs font-medium text-indigo-800"
                >
                  <%= tag %>
                </span>
              </div>
            </div>
          <% end %>
        </div>
      <% end %>

      <!-- Analysis Modal -->
      <%= if @show_analysis_modal && @selected_media do %>
        <div class="fixed inset-0 z-50 overflow-y-auto" phx-click="hide_analysis_modal">
          <div class="flex min-h-full items-end justify-center p-4 text-center sm:items-center sm:p-0">
            <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity"></div>

            <div
              class="relative transform overflow-hidden rounded-lg bg-white px-4 pb-4 pt-5 text-left shadow-xl transition-all sm:my-8 sm:w-full sm:max-w-2xl sm:p-6"
              phx-click="stop_propagation"
            >
              <div>
                <h3 class="text-lg font-semibold leading-6 text-gray-900 mb-4">
                  AI Analysis via Tidewave
                </h3>

                <%= if @show_generated_prompt do %>
                  <div class="mb-4">
                    <div class="bg-gray-50 rounded-lg p-4 mb-4">
                      <div class="flex items-start justify-between mb-2">
                        <h4 class="text-sm font-medium text-gray-900">Generated Prompt</h4>
                        <button
                          type="button"
                          phx-hook="CopyToClipboard"
                          id="copy-prompt-btn"
                          class="text-sm text-indigo-600 hover:text-indigo-700 font-medium"
                        >
                          📋 Copy to Clipboard
                        </button>
                      </div>
                      <p class="text-xs text-gray-600 mb-3">
                        Copy this prompt and paste it into the Tidewave chat interface.
                      </p>
                      <div id="generated-prompt" class="bg-white rounded border border-gray-300 p-3 max-h-96 overflow-y-auto text-xs font-mono">
                        <%= @generated_prompt %>
                      </div>
                    </div>
                    <div class="flex gap-3 justify-end">
                      <button
                        type="button"
                        phx-click="hide_analysis_modal"
                        class="rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
                      >
                        Close
                      </button>
                    </div>
                  </div>
                <% else %>
                  <div class="mb-4">
                    <div class="bg-blue-50 border-l-4 border-blue-400 p-4 mb-4">
                      <div class="flex">
                        <div class="flex-shrink-0">
                          <.icon name="hero-information-circle" class="h-5 w-5 text-blue-400" />
                        </div>
                        <div class="ml-3">
                          <p class="text-sm text-blue-700">
                            This will generate a prompt for you to paste into Tidewave, where Claude will
                            analyze the image and save the results directly to the database.
                          </p>
                        </div>
                      </div>
                    </div>

                    <form phx-submit="generate_prompt">
                      <div class="mb-4">
                        <label for="user_context" class="block text-sm font-medium text-gray-700 mb-2">
                          Your Context (Optional)
                        </label>
                        <p class="text-xs text-gray-500 mb-2">
                          Add your thoughts, questions, or context to guide the analysis
                        </p>
                        <textarea
                          id="user_context"
                          name="user_context"
                          rows="4"
                          class="block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                          placeholder="e.g., This was inspired by my grandmother's garden..."
                        ><%= @user_context %></textarea>
                      </div>

                      <div class="flex gap-3 justify-end">
                        <button
                          type="button"
                          phx-click="hide_analysis_modal"
                          class="rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
                        >
                          Cancel
                        </button>
                        <button
                          type="submit"
                          class="rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500"
                        >
                          <.icon name="hero-document-text" class="w-4 h-4 inline mr-1" />
                          Generate Prompt
                        </button>
                      </div>
                    </form>
                  </div>
                <% end %>
              </div>
            </div>
          </div>
        </div>
      <% end %>

      <!-- Upload Modal -->
      <%= if @show_upload_modal do %>
        <div class="fixed inset-0 z-50 overflow-y-auto" phx-click="hide_upload_modal">
          <div class="flex min-h-full items-end justify-center p-4 text-center sm:items-center sm:p-0">
            <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity"></div>

            <div
              class="relative transform overflow-hidden rounded-lg bg-white px-4 pb-4 pt-5 text-left shadow-xl transition-all sm:my-8 sm:w-full sm:max-w-2xl sm:p-6"
              phx-click="stop_propagation"
            >
              <div>
                <h3 class="text-lg font-semibold leading-6 text-gray-900 mb-4">
                  Upload Images
                </h3>

                <form phx-change="validate_upload" phx-submit="save_uploads">
                  <div class="mt-4">
                    <.live_file_input upload={@uploads.images} class="block w-full text-sm" />
                    <p class="mt-2 text-sm text-gray-600">
                      Upload JPG, PNG, or WEBP. Max 10MB per file. Select multiple files at once.
                    </p>

                    <%= for entry <- @uploads.images.entries do %>
                      <div class="mt-4 border rounded-lg p-4">
                        <div class="flex items-center gap-4">
                          <div class="flex-shrink-0">
                            <.live_img_preview entry={entry} class="h-20 w-20 object-cover rounded" />
                          </div>

                          <div class="flex-1 min-w-0">
                            <div class="text-sm font-medium text-gray-900 truncate">
                              <%= entry.client_name %>
                            </div>
                            <progress value={entry.progress} max="100" class="w-full mt-2">
                              <%= entry.progress %>%
                            </progress>

                            <div class="mt-2">
                              <input
                                type="text"
                                name={"alt_text_#{entry.ref}"}
                                placeholder="Alt text (optional)"
                                phx-change="update_alt_text"
                                phx-value-ref={entry.ref}
                                class="block w-full rounded-md border-gray-300 text-sm"
                              />
                            </div>
                          </div>

                          <button
                            type="button"
                            phx-click="cancel_upload"
                            phx-value-ref={entry.ref}
                            class="text-red-600 hover:text-red-800"
                          >
                            <.icon name="hero-x-mark" class="w-5 h-5" />
                          </button>
                        </div>

                        <%= for err <- upload_errors(@uploads.images, entry) do %>
                          <div class="mt-2 text-sm text-red-600">
                            <%= error_to_string(err) %>
                          </div>
                        <% end %>
                      </div>
                    <% end %>
                  </div>

                  <%= for err <- upload_errors(@uploads.images) do %>
                    <div class="mt-4 text-sm text-red-600">
                      <%= error_to_string(err) %>
                    </div>
                  <% end %>

                  <div class="mt-6 flex gap-3 justify-end">
                    <button
                      type="button"
                      phx-click="hide_upload_modal"
                      class="rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
                    >
                      Cancel
                    </button>
                    <button
                      type="submit"
                      disabled={length(@uploads.images.entries) == 0}
                      class="rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                      Upload <%= length(@uploads.images.entries) %> <%= if length(@uploads.images.entries) == 1,
                        do: "Image",
                        else: "Images" %>
                    </button>
                  </div>
                </form>
              </div>
            </div>
          </div>
        </div>
      <% end %>

      <!-- Archive Confirmation Modal -->
      <%= if @show_archive_modal && @selected_media do %>
        <div class="fixed inset-0 z-50 overflow-y-auto" phx-click="hide_archive_modal">
          <div class="flex min-h-full items-end justify-center p-4 text-center sm:items-center sm:p-0">
            <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity"></div>

            <div
              class="relative transform overflow-hidden rounded-lg bg-white px-4 pb-4 pt-5 text-left shadow-xl transition-all sm:my-8 sm:w-full sm:max-w-lg sm:p-6"
              phx-click="stop_propagation"
            >
              <div class="sm:flex sm:items-start">
                <div class="mx-auto flex h-12 w-12 flex-shrink-0 items-center justify-center rounded-full bg-amber-100 sm:mx-0 sm:h-10 sm:w-10">
                  <.icon name="hero-exclamation-triangle" class="h-6 w-6 text-amber-600" />
                </div>
                <div class="mt-3 text-center sm:ml-4 sm:mt-0 sm:text-left">
                  <h3 class="text-base font-semibold leading-6 text-gray-900">
                    Archive Media
                  </h3>
                  <div class="mt-2">
                    <p class="text-sm text-gray-500">
                      Are you sure you want to archive "<%= @selected_media.filename %>"?
                    </p>
                    <p class="mt-2 text-sm text-gray-500">
                      Archived media will be hidden from the main views but can be restored later.
                      The file will remain on disk.
                    </p>
                  </div>
                </div>
              </div>
              <div class="mt-5 sm:mt-4 sm:flex sm:flex-row-reverse gap-3">
                <button
                  type="button"
                  phx-click="archive_media"
                  phx-value-id={@selected_media.id}
                  class="inline-flex w-full justify-center rounded-md bg-amber-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-amber-500 sm:w-auto"
                >
                  Yes, Archive
                </button>
                <button
                  type="button"
                  phx-click="hide_archive_modal"
                  class="mt-3 inline-flex w-full justify-center rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50 sm:mt-0 sm:w-auto"
                >
                  Cancel
                </button>
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
    if connected?(socket) do
      Events.subscribe_uploads()
      Events.subscribe_analysis()
    end

    {:ok,
     socket
     |> assign(:page_title, "Media Workspace")
     |> assign(:search_query, "")
     |> assign(:status_filter, "all")
     |> assign(:sort_by, "newest")
     |> assign(:page, 1)
     |> assign(:per_page, 50)
     |> assign(:has_more, true)
     |> assign(:selected_media, nil)
     |> assign(:analyses, [])
     |> assign(:expanded_analyses, [])
     |> assign(:show_analysis_modal, false)
     |> assign(:analyzing, false)
     |> assign(:user_context, "")
     |> assign(:show_generated_prompt, false)
     |> assign(:generated_prompt, "")
     |> assign(:show_upload_modal, false)
     |> assign(:show_archive_modal, false)
     |> assign(:alt_texts, %{})
     |> allow_upload(:images,
       accept: ~w(.jpg .jpeg .png .webp),
       max_entries: 10,
       max_file_size: 50_000_000
     )
     |> load_media()}
  end

  @impl true
  def handle_event("search", %{"q" => query}, socket) do
    {:noreply,
     socket
     |> assign(:search_query, query)
     |> assign(:page, 1)
     |> load_media()}
  end

  @impl true
  def handle_event("filter_status", %{"value" => status}, socket) do
    {:noreply,
     socket
     |> assign(:status_filter, status)
     |> assign(:page, 1)
     |> load_media()}
  end

  @impl true
  def handle_event("sort", %{"value" => sort_by}, socket) do
    {:noreply,
     socket
     |> assign(:sort_by, sort_by)
     |> assign(:page, 1)
     |> load_media()}
  end

  @impl true
  def handle_event("select_media", %{"id" => id}, socket) do
    media = Media.get_media!(id)
    analyses = Media.list_analyses(id)

    # Preload analyses relationship for the grid
    media_with_analyses = %{media | analyses: analyses}

    {:noreply,
     socket
     |> assign(:selected_media, media_with_analyses)
     |> assign(:analyses, analyses)
     |> assign(:expanded_analyses, [])}
  end

  @impl true
  def handle_event("close_panel", _, socket) do
    {:noreply, assign(socket, :selected_media, nil)}
  end

  @impl true
  def handle_event("toggle_analysis", %{"index" => index}, socket) do
    idx = String.to_integer(index)

    expanded =
      if idx in socket.assigns.expanded_analyses do
        List.delete(socket.assigns.expanded_analyses, idx)
      else
        [idx | socket.assigns.expanded_analyses]
      end

    {:noreply, assign(socket, :expanded_analyses, expanded)}
  end

  @impl true
  def handle_event("show_analysis_modal", _, socket) do
    {:noreply, assign(socket, show_analysis_modal: true, user_context: "", show_generated_prompt: false)}
  end

  @impl true
  def handle_event("hide_analysis_modal", _, socket) do
    {:noreply, assign(socket, show_analysis_modal: false, analyzing: false, show_generated_prompt: false)}
  end

  @impl true
  def handle_event("generate_prompt", %{"user_context" => user_context}, socket) do
    media_id = socket.assigns.selected_media.id
    context_to_use = if user_context == "", do: nil, else: user_context

    prompt = Olivia.PromptBase.MediaAnalysisPrompt.generate(media_id, context_to_use)

    {:noreply,
     socket
     |> assign(:show_generated_prompt, true)
     |> assign(:generated_prompt, prompt)
     |> assign(:user_context, user_context)}
  end

  @impl true
  def handle_event("copy_prompt", _, socket) do
    # This will be handled by JavaScript hook for clipboard copy
    {:noreply, put_flash(socket, :info, "Prompt copied to clipboard!")}
  end

  @impl true
  def handle_event("show_upload_modal", _, socket) do
    {:noreply, assign(socket, :show_upload_modal, true)}
  end

  @impl true
  def handle_event("hide_upload_modal", _, socket) do
    {:noreply, assign(socket, :show_upload_modal, false)}
  end

  @impl true
  def handle_event("validate_upload", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel_upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :images, ref)}
  end

  @impl true
  def handle_event("update_alt_text", %{"ref" => ref, "value" => value}, socket) do
    alt_texts = Map.put(socket.assigns.alt_texts, ref, value)
    {:noreply, assign(socket, :alt_texts, alt_texts)}
  end

  @impl true
  def handle_event("save_uploads", _, socket) do
    require Logger
    user_id = socket.assigns.current_scope.user.id

    Logger.info("=== Starting upload process ===")
    Logger.info("User ID: #{user_id}")

    uploaded_results =
      consume_uploaded_entries(socket, :images, fn %{path: path}, entry ->
        filename = Uploads.generate_filename(entry.client_name)
        key = "media/#{filename}"
        content_type = entry.client_type || "image/jpeg"

        Logger.info("Processing upload: #{entry.client_name}")
        Logger.info("  Generated filename: #{filename}")
        Logger.info("  S3 key: #{key}")
        Logger.info("  Content type: #{content_type}")
        Logger.info("  Original file size: #{entry.client_size} bytes")

        # Optimize image for web display
        {upload_path, optimized_size} = case Olivia.Media.ImageProcessor.optimize_for_web(path) do
          {:ok, optimized_path, stats} ->
            Logger.info("  ✓ Image optimized: #{stats.original_dimensions} → #{stats.new_dimensions}")
            Logger.info("    Size reduction: #{stats.savings_percent}% (#{div(stats.original_size, 1024)}KB → #{div(stats.optimized_size, 1024)}KB)")
            {optimized_path, stats.optimized_size}

          {:error, reason} ->
            Logger.warning("  Image optimization failed (#{inspect(reason)}), uploading original")
            {path, entry.client_size}
        end

        case Uploads.upload_file(upload_path, key, content_type) do
          {:ok, url} ->
            # Clean up temporary optimized file if it was created
            if upload_path != path, do: File.rm(upload_path)

            Logger.info("  S3 upload successful: #{url}")
            alt_text = Map.get(socket.assigns.alt_texts, entry.ref, "")

            attrs = %{
              filename: entry.client_name,
              url: url,
              content_type: content_type,
              file_size: optimized_size,
              alt_text: if(alt_text != "", do: alt_text, else: nil),
              user_id: user_id
            }

            Logger.info("  Attempting database insert with attrs: #{inspect(attrs)}")

            case Media.create_media(attrs) do
              {:ok, media} ->
                Logger.info("  ✓ Database insert successful - Media ID: #{media.id}")
                {:ok, media}

              {:error, changeset} ->
                Logger.error("  ✗ Database insert failed!")
                Logger.error("  Changeset errors: #{inspect(changeset.errors)}")
                {:postpone, {:db_error, changeset}}
            end

          {:error, reason} ->
            Logger.error("  ✗ S3 upload failed!")
            Logger.error("  Reason: #{inspect(reason)}")
            {:postpone, {:upload_error, reason}}
        end
      end)

    {successful, failed} =
      Enum.split_with(uploaded_results, fn
        %Olivia.Media.MediaFile{} -> true
        {:ok, _} -> true
        _ -> false
      end)

    success_count = length(successful)
    failed_count = length(failed)

    Logger.info("=== Upload process complete ===")
    Logger.info("Successful: #{success_count}")
    Logger.info("Failed: #{failed_count}")

    if failed_count > 0 do
      Logger.error("Failed uploads details:")
      Enum.each(failed, fn failure ->
        Logger.error("  #{inspect(failure)}")
      end)
    end

    socket =
      socket
      |> assign(:show_upload_modal, false)
      |> assign(:alt_texts, %{})
      |> load_media()

    socket =
      cond do
        success_count > 0 && failed_count == 0 ->
          put_flash(socket, :info, "Uploaded #{success_count} #{if success_count == 1, do: "image", else: "images"} successfully")

        success_count > 0 && failed_count > 0 ->
          put_flash(socket, :warning, "Uploaded #{success_count} #{if success_count == 1, do: "image", else: "images"}, but #{failed_count} failed")

        failed_count > 0 ->
          put_flash(socket, :error, "All #{failed_count} uploads failed. Check logs for details.")

        true ->
          put_flash(socket, :info, "No files to upload")
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("stop_propagation", _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("run_analysis", %{"user_context" => user_context}, socket) do
    media_id = socket.assigns.selected_media.id

    send(self(), {:run_analysis, media_id, user_context})

    {:noreply, assign(socket, analyzing: true)}
  end

  @impl true
  def handle_event("approve_media", %{"id" => id}, socket) do
    media = Media.get_media!(id)

    case Media.update_media(media, %{status: "approved"}) do
      {:ok, updated_media} ->
        {:noreply,
         socket
         |> assign(:selected_media, updated_media)
         |> load_media()
         |> put_flash(:info, "Media approved successfully")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to approve media")}
    end
  end

  @impl true
  def handle_event("show_archive_modal", _, socket) do
    {:noreply, assign(socket, :show_archive_modal, true)}
  end

  @impl true
  def handle_event("hide_archive_modal", _, socket) do
    {:noreply, assign(socket, :show_archive_modal, false)}
  end

  @impl true
  def handle_event("archive_media", %{"id" => id}, socket) do
    media = Media.get_media!(id)

    case Media.update_media(media, %{status: "archived"}) do
      {:ok, _updated_media} ->
        {:noreply,
         socket
         |> assign(:selected_media, nil)
         |> assign(:show_archive_modal, false)
         |> load_media()
         |> put_flash(:info, "Media archived successfully")}

      {:error, _} ->
        {:noreply,
         socket
         |> assign(:show_archive_modal, false)
         |> put_flash(:error, "Failed to archive media")}
    end
  end

  @impl true
  def handle_info({:run_analysis, media_id, user_context}, socket) do
    context_to_use = if user_context == "", do: nil, else: user_context

    case Media.analyze_with_context(media_id, context_to_use) do
      {:ok, {updated_media, _analysis}} ->
        analyses = Media.list_analyses(media_id)

        {:noreply,
         socket
         |> assign(:selected_media, %{updated_media | analyses: analyses})
         |> assign(:analyses, analyses)
         |> assign(:show_analysis_modal, false)
         |> assign(:analyzing, false)
         |> load_media()
         |> put_flash(:info, "Analysis completed successfully")}

      {:error, reason} ->
        {:noreply,
         socket
         |> assign(:analyzing, false)
         |> put_flash(:error, "Analysis failed: #{inspect(reason)}")}
    end
  end

  @impl true
  def handle_info({:media_uploaded, _payload}, socket) do
    {:noreply, load_media(socket)}
  end

  @impl true
  def handle_info({:media_analyzed, _payload}, socket) do
    {:noreply, load_media(socket)}
  end

  defp load_media(socket) do
    query_opts =
      build_query_opts(socket.assigns)
      |> Keyword.put(:preload, [:analyses])

    media_list = Media.list_media(query_opts)

    stats = Media.get_stats()

    socket
    |> assign(:media_list, media_list)
    |> assign(:stats, stats)
    |> assign(:has_more, length(media_list) >= socket.assigns.per_page)
  end

  defp build_query_opts(assigns) do
    opts = [
      limit: assigns.per_page,
      offset: (assigns.page - 1) * assigns.per_page
    ]

    opts =
      if assigns.status_filter != "all" do
        Keyword.put(opts, :status, assigns.status_filter)
      else
        opts
      end

    opts =
      case assigns.sort_by do
        "oldest" -> Keyword.put(opts, :order_by, {:asc, :inserted_at})
        "filename" -> Keyword.put(opts, :order_by, {:asc, :filename})
        "status" -> Keyword.put(opts, :order_by, {:asc, :status})
        _ -> Keyword.put(opts, :order_by, {:desc, :inserted_at})
      end

    opts
  end

  defp status_badge_class("quarantine"), do: "bg-yellow-100 text-yellow-800"
  defp status_badge_class("approved"), do: "bg-green-100 text-green-800"
  defp status_badge_class("archived"), do: "bg-gray-100 text-gray-800"
  defp status_badge_class(_), do: "bg-gray-100 text-gray-800"

  defp status_label("quarantine"), do: "Quarantine"
  defp status_label("approved"), do: "Approved"
  defp status_label("archived"), do: "Archived"
  defp status_label(status), do: status
end
