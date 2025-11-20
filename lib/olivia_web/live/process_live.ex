defmodule OliviaWeb.ProcessLive do
  use OliviaWeb, :live_view

  import OliviaWeb.AssetHelpers, only: [resolve_asset_url: 1]

  alias Olivia.Annotations
  alias Olivia.Uploads

  @impl true
  def render(assigns) do
    cond do
      assigns[:theme] == "curator" -> render_curator(assigns)
      assigns[:theme] == "cottage" -> render_default(assigns)
      assigns[:theme] == "gallery" -> render_default(assigns)
      true -> render_default(assigns)
    end
  end

  # Helper to conditionally add annotation attributes
  defp annotation_attrs(enabled, anchor_key, anchor_meta) do
    if enabled do
      %{
        "data-note-anchor" => anchor_key,
        "data-anchor-meta" => Jason.encode!(anchor_meta),
        "phx-hook" => "AnnotatableElement"
      }
    else
      %{}
    end
  end

  defp render_curator(assigns) do
    ~H"""
    <!-- Page Header -->
    <section style="padding: 4rem 2rem 2rem; text-align: center;">
      <h1 class="curator-heading" style="font-size: 2.5rem; margin-bottom: 1rem;">
        Process
      </h1>
      <p class="curator-body" style="color: var(--curator-text-muted); max-width: 600px; margin: 0 auto;">
        Behind the finished work—the testing, the iterations, the domestic rituals of making.
      </p>
    </section>

    <!-- Process Introduction -->
    <section style="padding: 3rem 2rem;">
      <div style="max-width: 700px; margin: 0 auto;">
        <blockquote class="curator-heading-italic" style="font-size: 1.25rem; line-height: 1.6; color: var(--curator-text-light); margin-bottom: 2rem; text-align: center;">
          "There's something testing and ceremonial about viewing paintings outside in natural light—it's where the artist sees colour relationships without artificial interference, where decisions get made about what works and what doesn't."
        </blockquote>
        <div class="curator-divider"></div>
      </div>
    </section>

    <!-- From Nascent to Becoming -->
    <section style="padding: 4rem 2rem; background: var(--curator-bg-warm);">
      <div style="max-width: 1200px; margin: 0 auto;">
        <div style="margin-bottom: 3rem;">
          <h2 class="curator-heading" style="font-size: 1.75rem; margin-bottom: 1rem;">
            From Nascent to Becoming
          </h2>
          <p class="curator-body" style="color: var(--curator-text-muted); max-width: 600px;">
            This process documentation captures 'A BECOMING' in its nascent state—before the figure fully resolved from the gestural ground. The photograph documents the moment of potential, before decisions about where the figure resolves and where it remains in flux.
          </p>
        </div>

        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(400px, 1fr)); gap: 3rem; align-items: start;">
          <!-- Process Shot -->
          <div>
            <div class="curator-artwork-card" style="margin-bottom: 1rem;">
              <img
                src={resolve_asset_url("/uploads/media/1763542139_ba6e66be3929fdcd.jpg")}
                alt="A Becoming in progress on outdoor easel"
                style="width: 100%; display: block;"
              />
            </div>
            <p class="curator-body" style="font-size: 0.875rem; color: var(--curator-text-muted);">
              <strong>Nascent stage</strong> — The figure has not yet fully resolved from the gestural ground of flesh pinks, ochres, and siennas.
            </p>
          </div>

          <!-- Final Work -->
          <div>
            <div class="curator-artwork-card" style="margin-bottom: 1rem;">
              <img
                src={resolve_asset_url("/uploads/media/1763542139_3020310155b8abcf.jpg")}
                alt="A BECOMING - finished work"
                style="width: 100%; display: block;"
              />
            </div>
            <p class="curator-body" style="font-size: 0.875rem; color: var(--curator-text-muted);">
              <strong>Resolved</strong> — The figure emerges from and dissolves into the painterly ground, the tension between construction and dissolution productive.
            </p>
          </div>
        </div>
      </div>
    </section>

    <!-- Light Studies -->
    <section style="padding: 4rem 2rem;">
      <div style="max-width: 1200px; margin: 0 auto;">
        <div style="margin-bottom: 3rem;">
          <h2 class="curator-heading" style="font-size: 1.75rem; margin-bottom: 1rem;">
            Natural Light Testing
          </h2>
          <p class="curator-body" style="color: var(--curator-text-muted); max-width: 600px;">
            Viewing work in different lighting conditions reveals different truths. The golden ground that glows outdoors in sunlight takes on a different character under studio lighting—both valid, both revealing different aspects of the painting's nature.
          </p>
        </div>

        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(350px, 1fr)); gap: 3rem; align-items: start;">
          <!-- Marilyn Outdoor -->
          <div>
            <div class="curator-artwork-card" style="margin-bottom: 1rem;">
              <img
                src={resolve_asset_url("/uploads/media/1763542139_1225c3b883e0ce02.jpg")}
                alt="Marilyn in natural garden light"
                style="width: 100%; display: block;"
              />
            </div>
            <p class="curator-body" style="font-size: 0.875rem; color: var(--curator-text-muted);">
              <strong>Natural light</strong> — The golden ground positively glows with warmth that studio lighting couldn't capture.
            </p>
          </div>

          <!-- Marilyn Indoor -->
          <div>
            <div class="curator-artwork-card" style="margin-bottom: 1rem;">
              <img
                src={resolve_asset_url("/uploads/media/1763542139_e7e47b872f6b7223.JPG")}
                alt="Marilyn in studio lighting"
                style="width: 100%; display: block;"
              />
            </div>
            <p class="curator-body" style="font-size: 0.875rem; color: var(--curator-text-muted);">
              <strong>Studio light</strong> — More controlled, revealing the structural relationships between forms and the precision of mark-making.
            </p>
          </div>
        </div>
      </div>
    </section>

    <!-- Context Studies -->
    <section style="padding: 4rem 2rem; background: var(--curator-bg-warm);">
      <div style="max-width: 1200px; margin: 0 auto;">
        <div style="margin-bottom: 3rem;">
          <h2 class="curator-heading" style="font-size: 1.75rem; margin-bottom: 1rem;">
            Living With Work
          </h2>
          <p class="curator-body" style="color: var(--curator-text-muted); max-width: 600px;">
            Work that lives with the maker, tested in the crucible of daily viewing. Different contexts unlock different colour readings—the same triptych reveals cool tones against a grey wall that were less visible against pink.
          </p>
        </div>

        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(350px, 1fr)); gap: 3rem; align-items: start;">
          <!-- I Love Three Times - Pink Wall -->
          <div>
            <div class="curator-artwork-card" style="margin-bottom: 1rem;">
              <img
                src={resolve_asset_url("/uploads/media/1763542139_5a2e8259c48f9c2c.JPG")}
                alt="I Love Three Times on pink wall"
                style="width: 100%; display: block;"
              />
            </div>
            <p class="curator-body" style="font-size: 0.875rem; color: var(--curator-text-muted);">
              <strong>Pink wall</strong> — The warm context emphasizes the jewel tones and warmth of the flowers.
            </p>
          </div>

          <!-- I Love Three Times - Grey Wall -->
          <div>
            <div class="curator-artwork-card" style="margin-bottom: 1rem;">
              <img
                src={resolve_asset_url("/uploads/media/1763542139_3fcf4d765e5a5eeb.jpg")}
                alt="I Love Three Times on grey-blue wall"
                style="width: 100%; display: block;"
              />
            </div>
            <p class="curator-body" style="font-size: 0.875rem; color: var(--curator-text-muted);">
              <strong>Grey-blue wall</strong> — The cooler setting reveals tones that were hidden, and the vessel's patterns become more prominent.
            </p>
          </div>
        </div>
      </div>
    </section>

    <!-- The Outdoor Studio -->
    <section style="padding: 4rem 2rem;">
      <div style="max-width: 900px; margin: 0 auto; text-align: center;">
        <h2 class="curator-heading" style="font-size: 1.75rem; margin-bottom: 1.5rem;">
          The Outdoor Studio
        </h2>
        <p class="curator-body" style="color: var(--curator-text-muted); margin-bottom: 2rem;">
          The domestic garden studio—potted plants, turquoise fence, brick houses in the background. Paint palettes with mixed flesh tones, brushes, mixing surfaces arranged on a wooden deck. There's something testing and ceremonial about viewing paintings outside in natural light.
        </p>
        <div class="curator-artwork-card" style="max-width: 700px; margin: 0 auto;">
          <img
            src={resolve_asset_url("/uploads/media/1763542139_ba6e66be3929fdcd.jpg")}
            alt="Artist's outdoor workspace with paintings in progress"
            style="width: 100%; display: block;"
          />
        </div>
      </div>
    </section>

    <!-- Back to Work CTA -->
    <section style="padding: 4rem 2rem; background: var(--curator-bg-warm); text-align: center;">
      <div style="max-width: 500px; margin: 0 auto;">
        <h3 class="curator-heading" style="font-size: 1.5rem; margin-bottom: 1rem;">
          View the Collection
        </h3>
        <p class="curator-body" style="color: var(--curator-text-muted); margin-bottom: 2rem;">
          Explore the finished works across all three bodies of work.
        </p>
        <a href="/work" class="curator-button">
          View Work
        </a>
      </div>
    </section>
    """
  end

  defp render_default(assigns) do
    ~H"""
    <div class="bg-white min-h-screen">
      <div class="mx-auto max-w-7xl px-6 py-16 sm:py-24">
        <div
          class="text-center mb-16"
          {annotation_attrs(@annotations_enabled, "about:header", %{"page" => "about"})}
        >
          <h1 class="text-4xl font-bold tracking-tight text-gray-900 sm:text-5xl">About</h1>
          <p class="mt-6 text-lg leading-8 text-gray-600 max-w-2xl mx-auto">
            Behind the finished work—the testing, the iterations, the domestic rituals of making.
          </p>
        </div>

        <div
          class="prose prose-lg prose-gray mx-auto"
          {annotation_attrs(@annotations_enabled, "about:content", %{"page" => "about"})}
        >
          <p>
            Working primarily in oil, Olivia builds surfaces through heavy impasto that gives form weight and permanence.
            Her gestural brushwork refuses prettiness or idealisation—each stroke visible, urgent, yet deeply tender in cumulative effect.
          </p>
          <p>
            There's something testing and ceremonial about viewing paintings outside in natural light—it's where the artist
            sees colour relationships without artificial interference, where decisions get made about what works and what doesn't.
          </p>
        </div>
      </div>

      <!-- Annotation recorder hook -->
      <%= if @annotations_enabled do %>
        <div id="annotation-recorder-container">
          <form id="annotation-upload-form" phx-change="noop" phx-submit="noop" phx-hook="AudioAnnotation">
            <.live_file_input upload={@uploads.audio} id="annotation-audio-input" class="hidden" />
          </form>
        </div>
      <% end %>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    theme = socket.assigns[:theme]
    page_path = "/about"
    annotations_enabled = theme == "reviewer"

    socket =
      socket
      |> assign(:page_title, "About - Olivia Tew")
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
        max_file_size: 10_000_000
      )
      |> push_event("load_existing_notes", %{
        notes: Enum.map(existing_notes, &%{
          id: &1.id,
          anchor_key: &1.anchor_key,
          audio_url: &1.audio_url
        })
      })
    else
      socket
    end

    {:ok, socket}
  end

  # Annotation event handlers

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
          case Uploads.upload_binary(binary_data, filename, mime_type) do
            {:ok, url} ->
              case Annotations.create_voice_note(%{
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
                     audio_url: voice_note.audio_url
                   })}

                {:error, _changeset} ->
                  {:noreply, put_flash(socket, :error, "Failed to save annotation")}
              end

            {:error, _reason} ->
              {:noreply, put_flash(socket, :error, "Failed to upload audio")}
          end

        :error ->
          {:noreply, put_flash(socket, :error, "Invalid audio data")}
      end
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
