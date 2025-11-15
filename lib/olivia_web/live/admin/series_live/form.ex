defmodule OliviaWeb.Admin.SeriesLive.Form do
  use OliviaWeb, :live_view

  alias Olivia.Content
  alias Olivia.Content.Series
  alias Olivia.Media
  alias Olivia.Uploads

  on_mount {OliviaWeb.OliviaWeb.UserAuth, :ensure_authenticated}

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      <%= @page_title %>
      <:subtitle>Use this form to manage series records in your database.</:subtitle>
    </.header>

    <.form
      for={@form}
      id="series-form"
      phx-change="validate"
      phx-submit="save"
    >
      <.input field={@form[:title]} type="text" label="Title" phx-debounce="300" />
      <.input
        field={@form[:slug]}
        type="text"
        label="Slug (click to customize)"
        placeholder="Auto-generated from title"
        phx-focus="enable_slug_edit"
      />
      <.input field={@form[:summary]} type="textarea" label="Summary" rows="3" />
      <.input field={@form[:body_md]} type="textarea" label="Description (Markdown)" rows="10" />

      <div class="grid grid-cols-2 gap-4">
        <.input field={@form[:position]} type="number" label="Position" />
        <.input field={@form[:published]} type="checkbox" label="Published" />
      </div>

      <div class="mt-6">
        <label class="block text-sm font-semibold leading-6 text-zinc-800">
          Cover Image
        </label>

        <div :if={@series.cover_image_url || @selected_media} class="mt-2 mb-4">
          <img
            src={@selected_media && @selected_media.url || @series.cover_image_url}
            alt={@series.title}
            class="max-w-md rounded-lg shadow"
          />
          <button
            type="button"
            phx-click="remove_image"
            class="mt-2 text-sm text-red-600 hover:text-red-800"
          >
            Remove current image
          </button>
        </div>

        <div class="mt-4">
          <button
            type="button"
            phx-click="toggle_media_picker"
            class="text-sm font-semibold text-indigo-600 hover:text-indigo-500"
          >
            <%= if @show_media_picker, do: "Hide", else: "Choose from" %> Media Library
          </button>
        </div>

        <div :if={@show_media_picker} class="mt-4 border rounded-lg p-4 bg-gray-50">
          <div class="grid grid-cols-3 gap-3 max-h-96 overflow-y-auto">
            <div
              :for={media <- @media_list}
              class={"relative aspect-square rounded-lg overflow-hidden cursor-pointer border-2 #{if @selected_media && @selected_media.id == media.id, do: "border-indigo-600", else: "border-transparent hover:border-gray-300"}"}
              phx-click="select_media"
              phx-value-id={media.id}
            >
              <img src={media.url} alt={media.alt_text || media.filename} class="w-full h-full object-cover" />
              <div :if={@selected_media && @selected_media.id == media.id} class="absolute inset-0 bg-indigo-600 bg-opacity-20 flex items-center justify-center">
                <.icon name="hero-check-circle" class="w-8 h-8 text-white" />
              </div>
            </div>
          </div>
          <p class="mt-2 text-xs text-gray-600">
            Click an image to select it. <.link navigate={~p"/admin/media"} class="text-indigo-600 hover:text-indigo-500">Manage media library</.link>
          </p>
        </div>

        <div class="mt-4">
          <p class="text-sm font-medium text-gray-700 mb-2">Or upload a new image:</p>
          <.live_file_input upload={@uploads.cover_image} class="block w-full text-sm" />
          <p class="mt-2 text-sm text-gray-600">
            Upload JPG, PNG, or WEBP. Max 10MB. Recommended: 1200×900px landscape.
          </p>

          <div :for={entry <- @uploads.cover_image.entries} class="mt-4">
            <div class="flex items-center gap-2">
              <div class="flex-1">
                <div class="text-sm font-medium"><%= entry.client_name %></div>
                <progress value={entry.progress} max="100" class="w-full">
                  <%= entry.progress %>%
                </progress>
              </div>
              <button
                type="button"
                phx-click="cancel_upload"
                phx-value-ref={entry.ref}
                class="text-red-600 hover:text-red-800"
              >
                Cancel
              </button>
            </div>

            <div :for={err <- upload_errors(@uploads.cover_image, entry)} class="mt-1 text-sm text-red-600">
              <%= error_to_string(err) %>
            </div>
          </div>
        </div>
      </div>

      <div class="mt-6 flex items-center justify-between gap-6">
        <.button phx-disable-with="Saving...">Save Series</.button>
        <.link navigate={~p"/admin/series"} class="text-sm font-semibold leading-6 text-zinc-900 hover:text-zinc-700">
          Cancel
        </.link>
      </div>
    </.form>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    media_list = Media.list_media()

    {:ok,
     socket
     |> assign(:media_list, media_list)
     |> assign(:show_media_picker, false)
     |> assign(:selected_media, nil)
     |> assign(:slug_manually_edited, false)
     |> allow_upload(:cover_image,
       accept: ~w(.jpg .jpeg .png .webp),
       max_entries: 1,
       max_file_size: 10_000_000
     )
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    series = Content.get_series!(id)

    selected_media =
      if series.media_file_id do
        Media.get_media!(series.media_file_id)
      else
        nil
      end

    socket
    |> assign(:page_title, "Edit Series")
    |> assign(:series, series)
    |> assign(:selected_media, selected_media)
    |> assign(:form, to_form(Content.change_series(series)))
  end

  defp apply_action(socket, :new, _params) do
    series = %Series{}

    socket
    |> assign(:page_title, "New Series")
    |> assign(:series, series)
    |> assign(:form, to_form(Content.change_series(series)))
  end

  @impl true
  def handle_event("validate", %{"series" => series_params} = params, socket) do
    # Track if user has manually edited the slug field
    slug_manually_edited =
      case params["_target"] do
        ["series", "slug"] -> true
        _ -> socket.assigns.slug_manually_edited
      end

    # If slug hasn't been manually edited and title is changing, always clear slug to regenerate
    series_params =
      if not slug_manually_edited and params["_target"] == ["series", "title"] do
        # Always clear slug when title changes (unless manually edited)
        Map.put(series_params, "slug", "")
      else
        series_params
      end

    changeset = Content.change_series(socket.assigns.series, series_params)

    # Apply the changeset changes to get updated values for the form
    updated_series = Ecto.Changeset.apply_changes(changeset)

    {:noreply,
     socket
     |> assign(:series, updated_series)
     |> assign(:slug_manually_edited, slug_manually_edited)
     |> assign(:form, to_form(changeset, action: :validate))}
  end

  def handle_event("enable_slug_edit", _params, socket) do
    {:noreply, assign(socket, :slug_manually_edited, true)}
  end

  def handle_event("cancel_upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :cover_image, ref)}
  end

  def handle_event("toggle_media_picker", _params, socket) do
    {:noreply, assign(socket, :show_media_picker, !socket.assigns.show_media_picker)}
  end

  def handle_event("select_media", %{"id" => id}, socket) do
    media = Media.get_media!(id)
    {:noreply, assign(socket, :selected_media, media)}
  end

  def handle_event("remove_image", _params, socket) do
    series = socket.assigns.series

    if series.cover_image_url do
      Uploads.delete_by_url(series.cover_image_url)
    end

    case Content.update_series(series, %{cover_image_url: nil, media_file_id: nil}) do
      {:ok, updated_series} ->
        {:noreply,
         socket
         |> assign(:series, updated_series)
         |> assign(:selected_media, nil)
         |> put_flash(:info, "Cover image removed successfully")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to remove image")}
    end
  end

  def handle_event("save", %{"series" => series_params}, socket) do
    save_series(socket, socket.assigns.live_action, series_params)
  end

  defp save_series(socket, :edit, series_params) do
    series = socket.assigns.series

    series_params =
      if socket.assigns.selected_media do
        series_params
        |> Map.put("media_file_id", socket.assigns.selected_media.id)
        |> Map.put("cover_image_url", socket.assigns.selected_media.url)
      else
        maybe_upload_cover_image(socket, series_params, series.slug)
      end

    if series.cover_image_url && series_params["cover_image_url"] &&
         series.cover_image_url != series_params["cover_image_url"] do
      Uploads.delete_by_url(series.cover_image_url)
    end

    case Content.update_series(series, series_params) do
      {:ok, series} ->
        {:noreply,
         socket
         |> put_flash(:info, "Series updated successfully")
         |> push_navigate(to: ~p"/admin/series/#{series}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_series(socket, :new, series_params) do
    temp_slug = Series.slugify(series_params["title"] || "series")

    series_params =
      if socket.assigns.selected_media do
        series_params
        |> Map.put("media_file_id", socket.assigns.selected_media.id)
        |> Map.put("cover_image_url", socket.assigns.selected_media.url)
      else
        maybe_upload_cover_image(socket, series_params, temp_slug)
      end

    case Content.create_series(series_params) do
      {:ok, series} ->
        {:noreply,
         socket
         |> put_flash(:info, "Series created successfully")
         |> push_navigate(to: ~p"/admin/series/#{series}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp maybe_upload_cover_image(socket, params, slug) do
    uploaded_files =
      consume_uploaded_entries(socket, :cover_image, fn %{path: path}, entry ->
        filename = Uploads.generate_filename(entry.client_name)
        key = Uploads.series_key(slug, filename)
        content_type = entry.client_type || "image/jpeg"

        case Uploads.upload_file(path, key, content_type) do
          {:ok, url} -> {:ok, url}
          {:error, _reason} -> {:postpone, :error}
        end
      end)

    case uploaded_files do
      [url | _] -> Map.put(params, "cover_image_url", url)
      [] -> params
    end
  end

  defp error_to_string(:too_large), do: "File is too large (max 10MB)"
  defp error_to_string(:not_accepted), do: "File type not accepted (use JPG, PNG, or WEBP)"
  defp error_to_string(:too_many_files), do: "Too many files (max 1)"
  defp error_to_string(_), do: "Unknown error"
end
