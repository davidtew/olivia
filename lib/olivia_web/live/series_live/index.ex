defmodule OliviaWeb.SeriesLive.Index do
  use OliviaWeb, :live_view

  import OliviaWeb.AssetHelpers, only: [resolve_asset_url: 1]

  alias Olivia.Content
  alias Olivia.Annotations
  alias Olivia.Uploads

  @impl true
  def render(assigns) do
    cond do
      assigns[:theme] == "cottage" -> render_cottage(assigns)
      assigns[:theme] == "gallery" -> render_gallery(assigns)
      assigns[:theme] == "atelier" -> render_atelier(assigns)
      true -> render_default(assigns)
    end
  end

  # Note: annotation_attrs helper removed as we now use <.annotatable>

  defp render_cottage(assigns) do
    ~H"""
    <div style="max-width: 1200px; margin: 0 auto; padding: 4rem 1rem;">
      <div style="text-align: center; margin-bottom: 4rem;">
        <h1 class="cottage-heading" style="font-size: 3rem; margin-bottom: 1rem;">
          Collections
        </h1>
        <p class="cottage-body" style="font-size: 1.25rem; color: var(--cottage-text-medium); max-width: 42rem; margin: 0 auto;">
          Explore curated collections organized by theme and subject matter.
        </p>
      </div>

      <div style="display: grid; grid-template-columns: 1fr; gap: 3rem;">
        <article :for={series <- @series_list} style="display: grid; grid-template-columns: 1fr 1fr; gap: 2rem; border: 1px solid var(--cottage-taupe); border-radius: 8px; overflow: hidden; background: white;">
          <.link navigate={~p"/series/#{series.slug}"} style="display: block; text-decoration: none;">
            <div :if={Olivia.Content.Series.resolved_cover_image_url(series)} style="height: 100%;">
              <.artwork_image
                src={Olivia.Content.Series.resolved_cover_image_url(series)}
                alt={series.title}
                aspect="aspect-[16/9]"
                style="width: 100%; height: 100%; object-fit: cover; display: block;"
                sizes="(max-width: 768px) 100vw, 50vw"
              />
            </div>
            <div
              :if={!Olivia.Content.Series.resolved_cover_image_url(series)}
              style="aspect-ratio: 16/9; background: var(--cottage-beige); display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 0.5rem;"
            >
              <span class="cottage-heading" style="font-size: 1.125rem; color: var(--cottage-wisteria);">In the Studio</span>
              <span class="cottage-body" style="font-size: 0.75rem; color: var(--cottage-text-light);">Paintings in progress...</span>
            </div>
          </.link>
          <div style="padding: 2rem;">
            <div style="margin-bottom: 0.75rem;">
              <span class="cottage-body" style="font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.1em; color: var(--cottage-text-light);">
                <%= if length(series.artworks) == 0 do %>
                  Coming soon
                <% else %>
                  <%= length(series.artworks) %> <%= if length(series.artworks) == 1, do: "artwork", else: "artworks" %>
                <% end %>
              </span>
            </div>
            <h3 class="cottage-heading" style="font-size: 1.75rem; margin-bottom: 0.75rem;">
              <.link navigate={~p"/series/#{series.slug}"} style="text-decoration: none; color: inherit;">
                <%= series.title %>
              </.link>
            </h3>
            <p class="cottage-body" style="font-size: 1rem; line-height: 1.6; margin-bottom: 1.5rem;">
              <%= series.summary %>
            </p>
            <.link
              navigate={~p"/series/#{series.slug}"}
              class="cottage-button"
              style="display: inline-block; padding: 0.75rem 2rem; text-decoration: none;"
            >
              View Collection →
            </.link>
          </div>
        </article>
      </div>
    </div>
    """
  end

  defp render_gallery(assigns) do
    ~H"""
    <div style="text-align: center; padding: 4rem 1.5rem; border-bottom: 1px solid #e8e6e3;">
      <h1 class="gallery-heading" style="font-size: 3rem; color: #2c2416; margin-bottom: 1rem;">
        Collections
      </h1>
      <p class="gallery-script" style="font-size: 1.25rem; color: #6b5d54; max-width: 42rem; margin: 0 auto;">
        Explore curated collections organized by theme and subject matter.
      </p>
    </div>

    <div style="padding: 4rem 1.5rem;">
      <div style="display: grid; grid-template-columns: 1fr; gap: 4rem; max-width: 80rem; margin: 0 auto;">
        <article :for={series <- @series_list} class="artwork-card" style="display: grid; grid-template-columns: 1fr; gap: 2rem;">
          <.link navigate={~p"/series/#{series.slug}"} style="display: block; text-decoration: none;">
            <div :if={Olivia.Content.Series.resolved_cover_image_url(series)} class="elegant-border" style="overflow: hidden; margin-bottom: 1rem;">
              <.artwork_image
                src={Olivia.Content.Series.resolved_cover_image_url(series)}
                alt={series.title}
                aspect="aspect-[16/9]"
                style="width: 100%; display: block;"
                sizes="(max-width: 768px) 100vw, 80vw"
              />
            </div>
            <div
              :if={!Olivia.Content.Series.resolved_cover_image_url(series)}
              class="elegant-border"
              style="aspect-ratio: 16/9; background: #fafafa; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 0.5rem; margin-bottom: 1rem;"
            >
              <span class="gallery-script" style="font-size: 1.125rem; color: #8b7355;">In the Studio</span>
              <span style="font-size: 0.75rem; color: #999;">Paintings in progress...</span>
            </div>
          </.link>
          <div>
            <div style="margin-bottom: 0.75rem;">
              <span style="font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.1em; color: #9a8a7a;">
                <%= if length(series.artworks) == 0 do %>
                  Coming soon
                <% else %>
                  <%= length(series.artworks) %> <%= if length(series.artworks) == 1, do: "artwork", else: "artworks" %>
                <% end %>
              </span>
            </div>
            <h3 class="gallery-heading" style="font-size: 1.5rem; color: #2c2416; margin-bottom: 0.75rem;">
              <.link navigate={~p"/series/#{series.slug}"} style="text-decoration: none; color: inherit;">
                <%= series.title %>
              </.link>
            </h3>
            <p style="font-size: 1rem; color: #6b5d54; line-height: 1.6; margin-bottom: 1rem;">
              <%= series.summary %>
            </p>
            <.link
              navigate={~p"/series/#{series.slug}"}
              style="display: inline-block; font-size: 0.875rem; text-transform: uppercase; letter-spacing: 0.05em; color: #8b7355; text-decoration: none; border-bottom: 1px solid #c4b5a0; padding-bottom: 0.25rem;"
            >
              View Collection →
            </.link>
          </div>
        </article>
      </div>
    </div>
    """
  end

  defp render_atelier(assigns) do
    ~H"""
    <div class="atelier-section" style="max-width: 1200px; margin: 0 auto; padding: 4rem 2rem;">
      <div style="text-align: center; margin-bottom: 4rem;">
        <p class="atelier-heading-accent" style="font-size: 1rem; margin-bottom: 0.5rem;">Explore</p>
        <h1 class="atelier-heading" style="font-size: 3rem; margin-bottom: 1rem; color: var(--atelier-text-light);">
          Collections
        </h1>
        <p class="atelier-body" style="font-size: 1.125rem; color: var(--atelier-text-muted); max-width: 42rem; margin: 0 auto;">
          Three distinct bodies of work united by bold colour, gestural mark-making, and an unflinching approach to emotional truth.
        </p>
        <div class="atelier-divider"></div>
      </div>

      <div style="display: grid; grid-template-columns: 1fr; gap: 3rem;">
        <article :for={series <- @series_list} class="atelier-card" style="display: grid; grid-template-columns: 1fr 1fr; gap: 0; border-radius: 8px; overflow: hidden;">
          <.link navigate={~p"/series/#{series.slug}"} style="display: block; text-decoration: none;">
            <div :if={Olivia.Content.Series.resolved_cover_image_url(series)} class="atelier-artwork-frame" style="height: 100%;">
              <.artwork_image
                src={Olivia.Content.Series.resolved_cover_image_url(series)}
                alt={series.title}
                aspect="aspect-[16/9]"
                style="width: 100%; height: 100%; object-fit: cover; display: block;"
                sizes="(max-width: 768px) 100vw, 50vw"
              />
            </div>
            <div
              :if={!Olivia.Content.Series.resolved_cover_image_url(series)}
              style="aspect-ratio: 16/9; background: linear-gradient(135deg, var(--atelier-slate) 0%, var(--atelier-deep) 100%); display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 0.5rem;"
            >
              <span class="atelier-heading-accent" style="font-size: 1.25rem;">In the Studio</span>
              <span class="atelier-body" style="font-size: 0.75rem; color: var(--atelier-text-muted);">Paintings in progress...</span>
            </div>
          </.link>
          <div style="padding: 2.5rem; display: flex; flex-direction: column; justify-content: center;">
            <div style="margin-bottom: 0.75rem;">
              <span class="atelier-body" style="font-size: 0.6875rem; text-transform: uppercase; letter-spacing: 0.15em; color: var(--atelier-ochre);">
                <%= if length(series.artworks) == 0 do %>
                  Coming soon
                <% else %>
                  <%= length(series.artworks) %> <%= if length(series.artworks) == 1, do: "artwork", else: "artworks" %>
                <% end %>
              </span>
            </div>
            <h3 class="atelier-heading" style="font-size: 1.75rem; margin-bottom: 0.75rem; color: var(--atelier-text-light);">
              <.link navigate={~p"/series/#{series.slug}"} style="text-decoration: none; color: inherit;">
                <%= series.title %>
              </.link>
            </h3>
            <p class="atelier-body" style="font-size: 1rem; color: var(--atelier-text-muted); line-height: 1.6; margin-bottom: 1.5rem;">
              <%= series.summary %>
            </p>
            <.link
              navigate={~p"/series/#{series.slug}"}
              class="atelier-view-collection-link"
              style="display: inline-flex; align-items: center; gap: 0.5rem; font-size: 0.75rem; font-weight: 500; text-transform: uppercase; letter-spacing: 0.12em; color: var(--atelier-ochre); text-decoration: none; transition: all 0.3s ease; position: relative; z-index: 10;"
            >
              View Collection
              <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M5 12h14M12 5l7 7-7 7"/>
              </svg>
            </.link>
          </div>
        </article>
      </div>
    </div>
    """
  end

  defp render_default(assigns) do
    ~H"""
    <div class="min-h-screen bg-white">
      <div class="bg-gray-50 py-16 sm:py-24">
        <div class="mx-auto max-w-7xl px-6 lg:px-8">
          <.annotatable
            anchor="series-index:header"
            class="mx-auto max-w-2xl text-center"
            data-anchor-meta={Jason.encode!(%{"page" => "series-index"})}
          >
            <h1 class="text-4xl font-bold tracking-tight text-gray-900 sm:text-5xl">
              Collections
            </h1>
            <p class="mt-6 text-lg leading-8 text-gray-600">
              Three distinct bodies of work united by bold colour, gestural mark-making, and an unflinching approach to emotional truth.
            </p>
          </.annotatable>
        </div>
      </div>

      <div class="py-16 sm:py-24">
        <div class="mx-auto max-w-7xl px-6 lg:px-8">
          <div class="grid grid-cols-1 gap-16">
            <article class="grid lg:grid-cols-2 gap-8 items-center">
              <.annotatable
                anchor="series-index:becoming:image"
                data-anchor-meta={Jason.encode!(%{"page" => "series-index", "series" => "becoming"})}
              >
                <.link navigate={~p"/series/becoming"} class="group block">
                  <div class="relative aspect-[4/3] overflow-hidden rounded-lg bg-gray-100">
                    <img
                      src={resolve_asset_url("/uploads/media/1763542139_3020310155b8abcf.jpg")}
                      alt="A Becoming - Expressionist figure painting"
                      class="w-full h-full object-cover group-hover:opacity-90 transition-opacity"
                    />
                  </div>
                </.link>
              </.annotatable>

              <.annotatable
                anchor="series-index:becoming:text"
                data-anchor-meta={Jason.encode!(%{"page" => "series-index", "series" => "becoming"})}
              >
                <div class="mb-2">
                  <span class="text-xs text-gray-500 uppercase tracking-wide">3 artworks</span>
                </div>
                <h2 class="text-2xl font-bold tracking-tight text-gray-900 mb-4">
                  <.link navigate={~p"/series/becoming"} class="hover:text-gray-600">
                    Becoming
                  </.link>
                </h2>
                <p class="text-sm text-gray-500 italic mb-4">Figure Works</p>
                <p class="text-gray-600 leading-7 mb-6">
                  Expressionistic figure studies that capture the human form in moments of profound introspection. The paintings ask us to witness without intruding—the universal experience of sitting with difficulty, of weathering change, of the body as vessel for emotional experience.
                </p>
                <.link
                  navigate={~p"/series/becoming"}
                  class="text-sm font-semibold text-gray-900 hover:text-gray-600"
                >
                  View series <span aria-hidden="true">→</span>
                </.link>
              </.annotatable>
            </article>

            <article class="grid lg:grid-cols-2 gap-8 items-center">
              <.annotatable
                anchor="series-index:abundance:text"
                class="order-2 lg:order-1"
                data-anchor-meta={Jason.encode!(%{"page" => "series-index", "series" => "abundance"})}
              >
                <div class="mb-2">
                  <span class="text-xs text-gray-500 uppercase tracking-wide">6 artworks</span>
                </div>
                <h2 class="text-2xl font-bold tracking-tight text-gray-900 mb-4">
                  <.link navigate={~p"/series/abundance"} class="hover:text-gray-600">
                    Abundance
                  </.link>
                </h2>
                <p class="text-sm text-gray-500 italic mb-4">Floral Works</p>
                <p class="text-gray-600 leading-7 mb-6">
                  Exuberant floral still lifes that celebrate colour, pattern, and the tension between order and organic profusion. These works demand attention, project outward, and perform their beauty with confidence—both natural and constructed, genuine and glamorous.
                </p>
                <.link
                  navigate={~p"/series/abundance"}
                  class="text-sm font-semibold text-gray-900 hover:text-gray-600"
                >
                  View series <span aria-hidden="true">→</span>
                </.link>
              </.annotatable>

              <.annotatable
                anchor="series-index:abundance:image"
                class="order-1 lg:order-2"
                data-anchor-meta={Jason.encode!(%{"page" => "series-index", "series" => "abundance"})}
              >
                <.link navigate={~p"/series/abundance"} class="group block">
                  <div class="relative aspect-[4/3] overflow-hidden rounded-lg bg-gray-100">
                    <img
                      src={resolve_asset_url("/uploads/media/1763542139_f6add8cef5e11b3a.jpg")}
                      alt="Ecstatic - floral still life"
                      class="w-full h-full object-cover group-hover:opacity-90 transition-opacity"
                    />
                  </div>
                </.link>
              </.annotatable>
            </article>

            <article class="grid lg:grid-cols-2 gap-8 items-center">
              <.annotatable
                anchor="series-index:shifting:image"
                data-anchor-meta={Jason.encode!(%{"page" => "series-index", "series" => "shifting"})}
              >
                <.link navigate={~p"/series/shifting"} class="group block">
                  <div class="relative aspect-[4/3] overflow-hidden rounded-lg bg-gray-100">
                    <img
                      src={resolve_asset_url("/uploads/media/1763483281_14d2d6ab6485926c.jpg")}
                      alt="Shifting - expressionist landscape diptych"
                      class="w-full h-full object-cover group-hover:opacity-90 transition-opacity"
                    />
                  </div>
                </.link>
              </.annotatable>

              <.annotatable
                anchor="series-index:shifting:text"
                data-anchor-meta={Jason.encode!(%{"page" => "series-index", "series" => "shifting"})}
              >
                <div class="mb-2">
                  <span class="text-xs text-gray-500 uppercase tracking-wide">3 artworks</span>
                </div>
                <h2 class="text-2xl font-bold tracking-tight text-gray-900 mb-4">
                  <.link navigate={~p"/series/shifting"} class="hover:text-gray-600">
                    Shifting
                  </.link>
                </h2>
                <p class="text-sm text-gray-500 italic mb-4">Landscape Works</p>
                <p class="text-gray-600 leading-7 mb-6">
                  Landscapes in perpetual transformation. The impasto application is extraordinary in its physicality—paint applied in thick, directional strokes that mimic geological strata. The canvas becomes a physical analogue for the terrain it depicts.
                </p>
                <.link
                  navigate={~p"/series/shifting"}
                  class="text-sm font-semibold text-gray-900 hover:text-gray-600"
                >
                  View series <span aria-hidden="true">→</span>
                </.link>
              </.annotatable>
            </article>

            <article class="grid lg:grid-cols-2 gap-8 items-center">
              <.annotatable
                anchor="series-index:embodiment:text"
                class="order-2 lg:order-1"
                data-anchor-meta={Jason.encode!(%{"page" => "series-index", "series" => "embodiment"})}
              >
                <div class="mb-2">
                  <span class="text-xs text-gray-500 uppercase tracking-wide">4 artworks</span>
                </div>
                <h2 class="text-2xl font-bold tracking-tight text-gray-900 mb-4">
                  <.link navigate={~p"/series/embodiment"} class="hover:text-gray-600">
                    Embodiment
                  </.link>
                </h2>
                <p class="text-sm text-gray-500 italic mb-4">Studies in Gesture and Form</p>
                <p class="text-gray-600 leading-7 mb-6">
                  An investigation of the human figure through gesture, colour, and mark-making—capturing how bodies inhabit space, move through daily life, and reveal form through paint.
                </p>
                <.link
                  navigate={~p"/series/embodiment"}
                  class="text-sm font-semibold text-gray-900 hover:text-gray-600"
                >
                  View series <span aria-hidden="true">→</span>
                </.link>
              </.annotatable>

              <.annotatable
                anchor="series-index:embodiment:image"
                class="order-1 lg:order-2"
                data-anchor-meta={Jason.encode!(%{"page" => "series-index", "series" => "embodiment"})}
              >
                <.link navigate={~p"/series/embodiment"} class="group block">
                  <div class="relative aspect-[4/3] overflow-hidden rounded-lg bg-gray-100">
                    <img
                      src={resolve_asset_url("/uploads/media/1763722108_d70e2e2341d3cccd.jpg")}
                      alt="IN MOTION IV - Figure study"
                      class="w-full h-full object-cover group-hover:opacity-90 transition-opacity"
                    />
                  </div>
                </.link>
              </.annotatable>
            </article>
          </div>
        </div>
      </div>

      <%= if @annotations_enabled do %>
        <div id="annotation-recorder-container">
          <form id="annotation-upload-form" phx-change="noop" phx-submit="noop" phx-hook="AudioAnnotation">
            <.live_file_input upload={@uploads.audio} id="annotation-audio-input" class="hidden" />
          </form>

          <form id="annotation-text-form" class="annotation-text-input hidden" phx-submit="save_text_annotation" style="position: fixed; bottom: 20px; right: 20px; background: white; padding: 16px; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.15); z-index: 10000; max-width: 400px; min-width: 300px;">
            <input type="hidden" name="anchor_key" class="annotation-anchor-key" value="" />
            <input type="hidden" name="anchor_meta" class="annotation-anchor-meta" value="{}" />
            <input type="hidden" name="text_content" class="annotation-html-content" value="" />
            <div contenteditable="true" class="annotation-textarea" data-placeholder="Type or paste your note here..." style="min-height: 4em; padding: 0.5em; border: 1px solid #ccc; border-radius: 4px; background: white; margin-bottom: 8px;"></div>
            <button type="submit" style="width: 100%; padding: 8px; background: #4F46E5; color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 14px;">💬 Save Note</button>
          </form>
        </div>
      <% end %>

      <div class="border-t border-gray-200 bg-white">
        <div class="mx-auto max-w-7xl px-6 lg:px-8 py-8">
          <.link navigate={~p"/"} class="text-sm font-semibold text-gray-900 hover:text-gray-600">
            ← Back to home
          </.link>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    series_list = Content.list_series(published: true, preload: [:artworks])
    # Sort so collections without cover images appear at the bottom
    series_list = Enum.sort_by(series_list, fn series ->
      if Olivia.Content.Series.resolved_cover_image_url(series), do: 0, else: 1
    end)

    theme = socket.assigns[:theme]
    page_path = "/series"
    annotations_enabled = theme == "reviewer"

    socket =
      socket
      |> assign(:page_title, "Series - Olivia Tew")
      |> assign(:series_list, series_list)
      |> assign(:annotations_enabled, annotations_enabled)

    # Add annotation support when enabled
    socket = if annotations_enabled do
      existing_notes = Annotations.list_voice_notes(page_path, "reviewer")

      socket
      |> assign(:annotation_mode, false)
      |> assign(:current_anchor, nil)
      |> assign(:page_path, page_path)
      |> assign(:existing_notes, existing_notes)
      |> allow_upload(:audio,
        accept: ~w(audio/*),
        max_entries: 1,
        max_file_size: 50_000_000
      )
      |> push_event("load_existing_notes", %{
        notes: Enum.map(existing_notes, &%{
          id: &1.id,
          anchor_key: &1.anchor_key,
          audio_url: &1.audio_url,
          type: &1.type,
          content: &1.content
        })
      })
    else
      socket
    end

    {:ok, socket}
  end

  # Annotation event handlers (only used in reviewer theme)

  @impl true
  def handle_event("noop", _, socket), do: {:noreply, socket}

  @impl true
  def handle_event("toggle_mode", _, socket) do
    enabled = !socket.assigns.annotation_mode

    {:noreply,
     socket
     |> assign(:annotation_mode, enabled)
     |> push_event("annotation_mode_changed", %{enabled: enabled})}
  end

  @impl true
  def handle_event("start_annotation", params, socket) do
    anchor = %{
      key: params["anchor_key"],
      meta: params["anchor_meta"] || %{}
    }

    {:noreply, assign(socket, :current_anchor, anchor)}
  end

  @impl true
  def handle_event("save_audio_blob", %{"blob" => blob_data, "mime_type" => mime_type, "filename" => filename}, socket) do
    require Logger
    anchor = socket.assigns.current_anchor

    if !anchor do
      {:noreply, put_flash(socket, :error, "No annotation target selected")}
    else
      case Base.decode64(blob_data) do
        {:ok, binary_data} ->
          # Write to temp file first (same as SeriesLive.Show)
          temp_path = Path.join(System.tmp_dir!(), filename)

          case File.write(temp_path, binary_data) do
            :ok ->
              # Generate proper S3 key with path prefix
              clean_filename = Uploads.generate_filename(filename)
              key = "voice_notes/#{clean_filename}"

              case Uploads.upload_file(temp_path, key, mime_type) do
                {:ok, url} ->
                  # Clean up temp file
                  File.rm(temp_path)

                  case Annotations.create_voice_note(%{
                    type: "voice",
                    audio_url: url,
                    anchor_key: anchor.key,
                    anchor_meta: anchor.meta,
                    page_path: socket.assigns.page_path,
                    theme: "reviewer"
                  }) do
                    {:ok, voice_note} ->
                      {:noreply,
                       socket
                       |> put_flash(:info, "Annotation saved successfully")
                       |> assign(:current_anchor, nil)
                       |> push_event("note_created", %{
                         id: voice_note.id,
                         anchor_key: voice_note.anchor_key,
                         audio_url: voice_note.audio_url,
                         type: voice_note.type,
                         content: voice_note.content
                       })}

                    {:error, _changeset} ->
                      {:noreply, put_flash(socket, :error, "Failed to save annotation")}
                  end

                {:error, _reason} ->
                  File.rm(temp_path)
                  {:noreply, put_flash(socket, :error, "Failed to upload audio")}
              end

            {:error, _reason} ->
              {:noreply, put_flash(socket, :error, "Failed to process audio")}
          end

        :error ->
          {:noreply, put_flash(socket, :error, "Invalid audio data")}
      end
    end
  end

  @impl true
  def handle_event("save_text_annotation", params, socket) do
    %{"anchor_key" => anchor_key, "anchor_meta" => anchor_meta_str, "text_content" => text_content} = params
    require Logger

    user = socket.assigns[:current_user]

    # Parse anchor_meta from JSON string to map
    anchor_meta = case Jason.decode(anchor_meta_str) do
      {:ok, meta} -> meta
      {:error, _} -> %{}
    end

    # Sanitize HTML content for security
    sanitized_html = HtmlSanitizeEx.basic_html(text_content)

    # Also store plain text version
    plain_text = text_content
    |> HtmlSanitizeEx.strip_tags()
    |> String.trim()

    attrs = %{
      type: "text",
      content: %{"html" => sanitized_html, "text" => plain_text},
      anchor_key: anchor_key,
      anchor_meta: anchor_meta,
      page_path: socket.assigns.page_path,
      theme: socket.assigns.theme,
      user_id: user && user.id
    }

    case Annotations.create_voice_note(attrs) do
      {:ok, note} ->
        Logger.info("Text note created: #{note.id}")

        {:noreply,
         socket
         |> assign(:current_anchor, nil)
         |> update(:existing_notes, &[note | &1])
         |> push_event("note_created", %{
           id: note.id,
           anchor_key: note.anchor_key,
           audio_url: nil,
           type: note.type,
           content: note.content
         })}

      {:error, changeset} ->
        Logger.error("Failed to create text note: #{inspect(changeset)}")
        {:noreply, put_flash(socket, :error, "Failed to save note")}
    end
  end

  @impl true
  def handle_event("delete_annotation", %{"id" => id}, socket) do
    voice_note = Annotations.get_voice_note!(id)

    case Annotations.delete_voice_note(voice_note) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Annotation deleted")
         |> push_event("annotation_deleted", %{id: id})}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to delete annotation")}
    end
  end
end
