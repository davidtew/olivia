defmodule OliviaWeb.Admin.MediaLive.Index do
  use OliviaWeb, :live_view

  alias Olivia.Media
  alias Olivia.Uploads

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Media Library
        <:subtitle>Upload and manage images for your artworks and series</:subtitle>
        <:actions>
          <.button phx-click="show_upload_modal">
            <.icon name="hero-arrow-up-tray" class="w-4 h-4 mr-2" />
            Upload Images
          </.button>
        </:actions>
      </.header>

      <div class="mt-6 mb-4 flex items-center gap-4">
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
          <span class="text-sm text-gray-600">
            <%= @stats.total_count %> images
            · <%= format_size(@stats.total_size) %>
          </span>
        </div>
      </div>

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

                <form phx-change="validate" phx-submit="save_uploads">
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

      <div class="mt-8 grid grid-cols-2 gap-4 sm:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5">
        <div
          :for={media <- @media_list}
          class="group relative aspect-square overflow-hidden rounded-lg bg-gray-100"
        >
          <img src={media.url} alt={media.alt_text || media.filename} class="h-full w-full object-cover" />

          <div class="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent opacity-0 group-hover:opacity-100 transition-opacity">
            <div class="absolute bottom-0 left-0 right-0 p-3 text-white">
              <div class="text-xs font-medium truncate"><%= media.filename %></div>
              <div class="text-xs opacity-75"><%= format_size(media.file_size) %></div>
            </div>
          </div>

          <div class="absolute top-2 right-2 opacity-0 group-hover:opacity-100 transition-opacity flex gap-1">
            <button
              type="button"
              phx-click="edit_media"
              phx-value-id={media.id}
              class="rounded bg-white p-1.5 shadow-sm hover:bg-gray-50"
              title="Edit"
            >
              <.icon name="hero-pencil" class="w-4 h-4 text-gray-700" />
            </button>

            <button
              type="button"
              phx-click="delete_media"
              phx-value-id={media.id}
              data-confirm="Are you sure you want to delete this image?"
              class="rounded bg-white p-1.5 shadow-sm hover:bg-gray-50"
              title="Delete"
            >
              <.icon name="hero-trash" class="w-4 h-4 text-red-600" />
            </button>
          </div>
        </div>
      </div>

      <%= if length(@media_list) == 0 do %>
        <div class="text-center py-12">
          <.icon name="hero-photo" class="mx-auto h-12 w-12 text-gray-400" />
          <h3 class="mt-2 text-sm font-semibold text-gray-900">No images</h3>
          <p class="mt-1 text-sm text-gray-500">Get started by uploading your first image.</p>
          <div class="mt-6">
            <button
              type="button"
              phx-click="show_upload_modal"
              class="inline-flex items-center rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500"
            >
              <.icon name="hero-plus" class="w-5 h-5 mr-2" />
              Upload Images
            </button>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    media_list = Media.list_media()
    stats = Media.get_stats()

    {:ok,
     socket
     |> assign(:page_title, "Media Library")
     |> assign(:media_list, media_list)
     |> assign(:stats, stats)
     |> assign(:show_upload_modal, false)
     |> assign(:search_query, "")
     |> assign(:alt_texts, %{})
     |> allow_upload(:images,
       accept: ~w(.jpg .jpeg .png .webp),
       max_entries: 10,
       max_file_size: 10_000_000
     )}
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
  def handle_event("stop_propagation", _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", _params, socket) do
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
  def handle_event("search", %{"q" => query}, socket) do
    media_list =
      if query == "" do
        Media.list_media()
      else
        Media.search_media(query)
      end

    {:noreply, assign(socket, media_list: media_list, search_query: query)}
  end

  @impl true
  def handle_event("save_uploads", _, socket) do
    user_id = socket.assigns.current_scope.user.id

    uploaded_files =
      consume_uploaded_entries(socket, :images, fn %{path: path}, entry ->
        filename = Uploads.generate_filename(entry.client_name)
        key = "media/#{filename}"
        content_type = entry.client_type || "image/jpeg"

        case Uploads.upload_file(path, key, content_type) do
          {:ok, url} ->
            alt_text = Map.get(socket.assigns.alt_texts, entry.ref, "")

            attrs = %{
              filename: entry.client_name,
              url: url,
              content_type: content_type,
              file_size: entry.client_size,
              alt_text: if(alt_text != "", do: alt_text, else: nil),
              user_id: user_id
            }

            case Media.create_media(attrs) do
              {:ok, media} -> {:ok, media}
              {:error, _} -> {:postpone, :error}
            end

          {:error, _reason} ->
            {:postpone, :error}
        end
      end)

    media_list = Media.list_media()
    stats = Media.get_stats()

    {:noreply,
     socket
     |> assign(:media_list, media_list)
     |> assign(:stats, stats)
     |> assign(:show_upload_modal, false)
     |> assign(:alt_texts, %{})
     |> put_flash(:info, "Uploaded #{length(uploaded_files)} #{if length(uploaded_files) == 1, do: "image", else: "images"} successfully")}
  end

  @impl true
  def handle_event("delete_media", %{"id" => id}, socket) do
    media = Media.get_media!(id)

    case Media.delete_media(media) do
      {:ok, _} ->
        media_list = Media.list_media()
        stats = Media.get_stats()

        {:noreply,
         socket
         |> assign(:media_list, media_list)
         |> assign(:stats, stats)
         |> put_flash(:info, "Image deleted successfully")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to delete image")}
    end
  end

  @impl true
  def handle_event("edit_media", %{"id" => id}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/admin/media/#{id}/edit")}
  end

  defp format_size(nil), do: "Unknown size"
  defp format_size(bytes) when bytes < 1024, do: "#{bytes} B"
  defp format_size(bytes) when bytes < 1024 * 1024, do: "#{Float.round(bytes / 1024, 1)} KB"
  defp format_size(bytes), do: "#{Float.round(bytes / (1024 * 1024), 1)} MB"

  defp error_to_string(:too_large), do: "File is too large (max 10MB)"
  defp error_to_string(:not_accepted), do: "File type not accepted (use JPG, PNG, or WEBP)"
  defp error_to_string(:too_many_files), do: "Too many files (max 10)"
  defp error_to_string(_), do: "Unknown error"
end
