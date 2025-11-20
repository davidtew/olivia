defmodule OliviaWeb.Admin.ArtworkLive.Form do
  use OliviaWeb, :live_view

  alias Olivia.Content
  alias Olivia.Content.Artwork
  alias Olivia.Media
  alias Olivia.Uploads

  on_mount {OliviaWeb.OliviaWeb.UserAuth, :ensure_authenticated}

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      <%= @page_title %>
      <:subtitle>Use this form to manage artwork records in your database.</:subtitle>
    </.header>

    <.form
      for={@form}
      id="artwork-form"
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

      <.input
        field={@form[:series_id]}
        type="select"
        label="Series"
        options={series_options(@series_list)}
        prompt="Choose a series (optional)"
      />

      <div class="grid grid-cols-2 gap-4">
        <.input field={@form[:year]} type="number" label="Year" />
        <.input
          field={@form[:status]}
          type="select"
          label="Status"
          options={[
            {"Available", "available"},
            {"Sold", "sold"},
            {"Reserved", "reserved"}
          ]}
        />
      </div>

      <.input field={@form[:medium]} type="text" label="Medium" placeholder="e.g., Oil on canvas" />
      <.input
        field={@form[:dimensions]}
        type="text"
        label="Dimensions"
        placeholder="e.g., 80 × 60 cm"
      />

      <div class="grid grid-cols-2 gap-4">
        <.input
          field={@form[:price_cents]}
          type="number"
          label="Price (in pence/cents)"
          placeholder="e.g., 125000 for £1,250"
        />
        <.input
          field={@form[:currency]}
          type="select"
          label="Currency"
          options={[
            {"GBP (£)", "GBP"},
            {"USD ($)", "USD"},
            {"EUR (€)", "EUR"}
          ]}
        />
      </div>

      <.input field={@form[:location]} type="text" label="Location" placeholder="e.g., Studio, London" />

      <.input
        field={@form[:description_md]}
        type="textarea"
        label="Description (Markdown)"
        rows="8"
      />

      <div class="grid grid-cols-3 gap-4">
        <.input field={@form[:position]} type="number" label="Position" />
        <.input field={@form[:featured]} type="checkbox" label="Featured" />
        <.input field={@form[:published]} type="checkbox" label="Published" />
      </div>

      <div class="mt-6">
        <label class="block text-sm font-semibold leading-6 text-zinc-800">
          Artwork Image
        </label>

        <div :if={@artwork.image_url || @selected_media} class="mt-2 mb-4">
          <img
            src={@selected_media && Olivia.Media.MediaFile.resolved_url(@selected_media) || Olivia.Content.Artwork.resolved_image_url(@artwork)}
            alt={@artwork.title}
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
              <img src={Olivia.Media.MediaFile.resolved_url(media)} alt={media.alt_text || media.filename} class="w-full h-full object-cover" />
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
          <.live_file_input upload={@uploads.image} class="block w-full text-sm" />
          <p class="mt-2 text-sm text-gray-600">
            Upload JPG, PNG, or WEBP. Max 10MB. Recommended: 1200×1600px or similar ratio.
          </p>

          <div :for={entry <- @uploads.image.entries} class="mt-4">
            <div class="flex items-center gap-2">
              <div class="flex-1">
                <div class="text-sm font-medium"><%= entry.client_name %></div>
                <progress value={entry.progress} max="100" class="w-full"><%= entry.progress %>%</progress>
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

            <div :for={err <- upload_errors(@uploads.image, entry)} class="mt-1 text-sm text-red-600">
              <%= error_to_string(err) %>
            </div>
          </div>
        </div>
      </div>

      <div class="mt-6 flex items-center justify-between gap-6">
        <.button phx-disable-with="Saving...">Save Artwork</.button>
        <.link
          navigate={~p"/admin/artworks"}
          class="text-sm font-semibold leading-6 text-zinc-900 hover:text-zinc-700"
        >
          Cancel
        </.link>
      </div>
    </.form>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    series_list = Content.list_series()
    media_list = Media.list_media()

    {:ok,
     socket
     |> assign(:series_list, series_list)
     |> assign(:media_list, media_list)
     |> assign(:show_media_picker, false)
     |> assign(:selected_media, nil)
     |> assign(:slug_manually_edited, false)
     |> allow_upload(:image, accept: ~w(.jpg .jpeg .png .webp), max_entries: 1, max_file_size: 10_000_000)
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    artwork = Content.get_artwork!(id)

    selected_media =
      if artwork.media_file_id do
        Media.get_media!(artwork.media_file_id)
      else
        nil
      end

    socket
    |> assign(:page_title, "Edit Artwork")
    |> assign(:artwork, artwork)
    |> assign(:selected_media, selected_media)
    |> assign(:form, to_form(Content.change_artwork(artwork)))
  end

  defp apply_action(socket, :new, _params) do
    artwork = %Artwork{}

    socket
    |> assign(:page_title, "New Artwork")
    |> assign(:artwork, artwork)
    |> assign(:form, to_form(Content.change_artwork(artwork)))
  end

  @impl true
  def handle_event("validate", %{"artwork" => artwork_params} = params, socket) do
    # Track if user has manually edited the slug field
    slug_manually_edited =
      case params["_target"] do
        ["artwork", "slug"] -> true
        _ -> socket.assigns.slug_manually_edited
      end

    # If slug hasn't been manually edited and title is changing, always clear slug to regenerate
    artwork_params =
      if not slug_manually_edited and params["_target"] == ["artwork", "title"] do
        # Always clear slug when title changes (unless manually edited)
        Map.put(artwork_params, "slug", "")
      else
        artwork_params
      end

    changeset = Content.change_artwork(socket.assigns.artwork, artwork_params)

    # Apply the changeset changes to get updated values for the form
    updated_artwork = Ecto.Changeset.apply_changes(changeset)

    {:noreply,
     socket
     |> assign(:artwork, updated_artwork)
     |> assign(:slug_manually_edited, slug_manually_edited)
     |> assign(:form, to_form(changeset, action: :validate))}
  end

  def handle_event("enable_slug_edit", _params, socket) do
    {:noreply, assign(socket, :slug_manually_edited, true)}
  end

  def handle_event("cancel_upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :image, ref)}
  end

  def handle_event("toggle_media_picker", _params, socket) do
    {:noreply, assign(socket, :show_media_picker, !socket.assigns.show_media_picker)}
  end

  def handle_event("select_media", %{"id" => id}, socket) do
    media = Media.get_media!(id)
    {:noreply, assign(socket, :selected_media, media)}
  end

  def handle_event("remove_image", _params, socket) do
    artwork = socket.assigns.artwork

    if artwork.image_url do
      Uploads.delete_by_url(artwork.image_url)
    end

    case Content.update_artwork(artwork, %{image_url: nil, media_file_id: nil}) do
      {:ok, updated_artwork} ->
        {:noreply,
         socket
         |> assign(:artwork, updated_artwork)
         |> assign(:selected_media, nil)
         |> put_flash(:info, "Image removed successfully")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to remove image")}
    end
  end

  def handle_event("save", %{"artwork" => artwork_params}, socket) do
    save_artwork(socket, socket.assigns.live_action, artwork_params)
  end

  defp save_artwork(socket, :edit, artwork_params) do
    artwork = socket.assigns.artwork

    artwork_params =
      cond do
        socket.assigns.selected_media ->
          artwork_params
          |> Map.put("media_file_id", socket.assigns.selected_media.id)
          |> Map.put("image_url", socket.assigns.selected_media.url)

        not Enum.empty?(socket.assigns.uploads.image.entries) ->
          uploaded_file = List.first(consume_uploaded_entries(socket, :image, fn %{path: path}, entry ->
            filename = Uploads.generate_filename(entry.client_name)
            key = Uploads.artwork_key("general", filename)

            case Uploads.upload_file(path, key, entry.client_type) do
              {:ok, url} -> {:ok, url}
              error -> error
            end
          end))

          case uploaded_file do
            {:ok, url} ->
              artwork_params
              |> Map.put("image_url", url)
              |> Map.delete("media_file_id")
            _ ->
              artwork_params
          end

        true ->
          artwork_params
      end

    if artwork.image_url && artwork_params["image_url"] && artwork.image_url != artwork_params["image_url"] do
      Uploads.delete_by_url(artwork.image_url)
    end

    case Content.update_artwork(artwork, artwork_params) do
      {:ok, artwork} ->
        {:noreply,
         socket
         |> put_flash(:info, "Artwork updated successfully")
         |> push_navigate(to: ~p"/admin/artworks/#{artwork}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_artwork(socket, :new, artwork_params) do
    artwork_params =
      cond do
        socket.assigns.selected_media ->
          artwork_params
          |> Map.put("media_file_id", socket.assigns.selected_media.id)
          |> Map.put("image_url", socket.assigns.selected_media.url)

        not Enum.empty?(socket.assigns.uploads.image.entries) ->
          uploaded_file = List.first(consume_uploaded_entries(socket, :image, fn %{path: path}, entry ->
            filename = Uploads.generate_filename(entry.client_name)
            key = Uploads.artwork_key("general", filename)

            case Uploads.upload_file(path, key, entry.client_type) do
              {:ok, url} -> {:ok, url}
              error -> error
            end
          end))

          case uploaded_file do
            {:ok, url} ->
              artwork_params
              |> Map.put("image_url", url)
              |> Map.delete("media_file_id")
            _ ->
              artwork_params
          end

        true ->
          artwork_params
      end

    case Content.create_artwork(artwork_params) do
      {:ok, artwork} ->
        {:noreply,
         socket
         |> put_flash(:info, "Artwork created successfully")
         |> push_navigate(to: ~p"/admin/artworks/#{artwork}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp series_options(series_list) do
    Enum.map(series_list, fn series -> {series.title, series.id} end)
  end

  defp error_to_string(:too_large), do: "File is too large (max 10MB)"
  defp error_to_string(:not_accepted), do: "File type not accepted (use JPG, PNG, or WEBP)"
  defp error_to_string(:too_many_files), do: "Too many files (max 1)"
  defp error_to_string(_), do: "Unknown error"
end
