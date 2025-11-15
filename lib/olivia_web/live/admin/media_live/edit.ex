defmodule OliviaWeb.Admin.MediaLive.Edit do
  use OliviaWeb, :live_view

  alias Olivia.Media

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    media = Media.get_media!(id)

    {:ok,
     socket
     |> assign(:page_title, "Edit Media")
     |> assign(:media, media)
     |> assign(:form, to_form(Media.change_media(media)))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Edit Media
        <:subtitle>Update media information</:subtitle>
      </.header>

      <div class="mt-8">
        <div class="mb-6">
          <img src={@media.url} alt={@media.alt_text || @media.filename} class="max-w-md rounded-lg shadow-lg" />
        </div>

        <form phx-submit="save" class="space-y-6">
          <.input field={@form[:filename]} type="text" label="Filename" disabled />

          <.input field={@form[:alt_text]} type="text" label="Alt Text" placeholder="Describe this image for accessibility" />

          <.input field={@form[:caption]} type="textarea" label="Caption" placeholder="Optional caption for this image" />

          <.input
            field={@form[:tags]}
            type="text"
            label="Tags"
            placeholder="Separate tags with commas"
            value={Enum.join(@media.tags || [], ", ")}
          />

          <div class="text-sm text-gray-600 p-4 bg-gray-50 rounded">
            <p>File size: <%= format_size(@media.file_size) %></p>
            <p>Content type: <%= @media.content_type %></p>
            <%= if @media.width && @media.height do %>
              <p>Dimensions: <%= @media.width %>×<%= @media.height %></p>
            <% end %>
          </div>

          <div class="flex items-center gap-4">
            <.button phx-disable-with="Saving...">Save Changes</.button>
            <.link navigate={~p"/admin/media"} class="text-sm font-semibold text-gray-900">
              Cancel
            </.link>
          </div>
        </form>

        <%= if @media.asset_type || @media.metadata != %{} do %>
          <div class="mt-10 border-t pt-8">
            <h2 class="text-2xl font-bold text-gray-900 mb-6">AI-Generated Metadata</h2>

            <div class="space-y-6">
              <%= if @media.status do %>
                <div class="bg-blue-50 p-4 rounded-lg">
                  <h3 class="text-sm font-semibold text-blue-900 mb-2">Status</h3>
                  <p class="text-blue-700">
                    <span class={"px-3 py-1 rounded-full text-sm font-medium #{status_color(@media.status)}"}>
                      <%= String.upcase(@media.status) %>
                    </span>
                  </p>
                </div>
              <% end %>

              <%= if @media.asset_type do %>
                <div class="bg-purple-50 p-4 rounded-lg">
                  <h3 class="text-sm font-semibold text-purple-900 mb-2">Asset Classification</h3>
                  <div class="text-purple-700 space-y-1">
                    <p><strong>Type:</strong> <%= @media.asset_type %></p>
                    <%= if @media.asset_role do %>
                      <p><strong>Role:</strong> <%= @media.asset_role %></p>
                    <% end %>
                  </div>
                </div>
              <% end %>

              <%= if @media.metadata["subject"] do %>
                <div class="bg-green-50 p-4 rounded-lg">
                  <h3 class="text-sm font-semibold text-green-900 mb-2">Subject Matter</h3>
                  <p class="text-green-700"><%= @media.metadata["subject"] %></p>
                </div>
              <% end %>

              <%= if @media.metadata["style_or_medium"] do %>
                <div class="bg-amber-50 p-4 rounded-lg">
                  <h3 class="text-sm font-semibold text-amber-900 mb-2">Style & Medium</h3>
                  <p class="text-amber-700"><%= @media.metadata["style_or_medium"] %></p>
                </div>
              <% end %>

              <%= if @media.metadata["composition"] do %>
                <div class="bg-pink-50 p-4 rounded-lg">
                  <h3 class="text-sm font-semibold text-pink-900 mb-2">Composition</h3>
                  <p class="text-pink-700"><%= @media.metadata["composition"] %></p>
                </div>
              <% end %>

              <%= if @media.metadata["color_palette"] do %>
                <div class="bg-indigo-50 p-4 rounded-lg">
                  <h3 class="text-sm font-semibold text-indigo-900 mb-2">Color Palette</h3>
                  <div class="flex flex-wrap gap-2 mt-2">
                    <%= for color <- @media.metadata["color_palette"] do %>
                      <span class="px-3 py-1 bg-indigo-100 text-indigo-800 rounded-full text-sm">
                        <%= color %>
                      </span>
                    <% end %>
                  </div>
                </div>
              <% end %>

              <%= if @media.metadata["artistic_period"] do %>
                <div class="bg-teal-50 p-4 rounded-lg">
                  <h3 class="text-sm font-semibold text-teal-900 mb-2">Artistic Period</h3>
                  <p class="text-teal-700"><%= @media.metadata["artistic_period"] %></p>
                </div>
              <% end %>

              <%= if @media.metadata["claude_analysis"] do %>
                <div class="bg-slate-50 p-6 rounded-lg">
                  <h3 class="text-lg font-semibold text-slate-900 mb-4">Full Claude Analysis</h3>
                  <div class="text-slate-700 whitespace-pre-wrap font-mono text-sm leading-relaxed">
                    <%= @media.metadata["claude_analysis"] %>
                  </div>
                </div>
              <% end %>

              <div class="bg-gray-50 p-6 rounded-lg">
                <h3 class="text-lg font-semibold text-gray-900 mb-4">Raw Metadata JSON</h3>
                <pre class="text-xs text-gray-600 overflow-x-auto bg-white p-4 rounded border"><%= Jason.encode!(@media.metadata, pretty: true) %></pre>
              </div>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("save", %{"media_file" => media_params}, socket) do
    # Parse tags from comma-separated string
    tags =
      case media_params["tags"] do
        nil -> []
        "" -> []
        tags_string ->
          tags_string
          |> String.split(",")
          |> Enum.map(&String.trim/1)
          |> Enum.reject(&(&1 == ""))
      end

    media_params = Map.put(media_params, "tags", tags)

    case Media.update_media(socket.assigns.media, media_params) do
      {:ok, _media} ->
        {:noreply,
         socket
         |> put_flash(:info, "Media updated successfully")
         |> push_navigate(to: ~p"/admin/media")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  defp format_size(nil), do: "Unknown"
  defp format_size(bytes) when bytes < 1024, do: "#{bytes} B"
  defp format_size(bytes) when bytes < 1024 * 1024, do: "#{Float.round(bytes / 1024, 1)} KB"
  defp format_size(bytes), do: "#{Float.round(bytes / (1024 * 1024), 1)} MB"

  defp status_color("approved"), do: "bg-green-100 text-green-800"
  defp status_color("quarantine"), do: "bg-yellow-100 text-yellow-800"
  defp status_color("archived"), do: "bg-gray-100 text-gray-800"
  defp status_color(_), do: "bg-blue-100 text-blue-800"
end
