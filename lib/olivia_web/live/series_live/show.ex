defmodule OliviaWeb.SeriesLive.Show do
  use OliviaWeb, :live_view

  import OliviaWeb.AssetHelpers, only: [resolve_asset_url: 1]

  alias Olivia.Content
  alias Olivia.Annotations
  alias Olivia.Uploads

  @impl true
  def render(assigns) do
    # When in reviewer mode, determine which visual theme to use
    # For now, default to cottage for database series, default for hardcoded
    visual_theme = cond do
      assigns[:theme] == "reviewer" && is_struct(assigns[:series]) -> "cottage"
      assigns[:theme] == "reviewer" -> "default"
      assigns[:theme] == "cottage" -> "cottage"
      assigns[:theme] == "gallery" -> "gallery"
      true -> "default"
    end

    case visual_theme do
      "cottage" -> render_cottage(assigns)
      "gallery" -> render_gallery(assigns)
      _ -> render_default(assigns)
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

  defp render_cottage(assigns) do
    ~H"""
    <div style="max-width: 1200px; margin: 0 auto; padding: 4rem 1rem;">
      <div style="text-align: center; margin-bottom: 4rem;">
        <h1 class="cottage-heading" style="font-size: 3rem; margin-bottom: 1rem;">
          <%= @series.title %>
        </h1>
        <p class="cottage-body" style="font-size: 1.25rem; color: var(--cottage-text-medium); max-width: 48rem; margin: 0 auto;">
          <%= @series.summary %>
        </p>
      </div>

      <div :if={@series.body_md} style="max-width: 48rem; margin: 0 auto; margin-bottom: 4rem;">
        <div
          id={"series-#{@slug}-description"}
          class="cottage-body"
          style="font-size: 1.125rem; line-height: 1.75;"
          {annotation_attrs(@annotations_enabled, "series:#{@slug}:description", %{
            "anchor_type" => "text",
            "series_slug" => @slug
          })}
        >
          <%= raw(Earmark.as_html!(@series.body_md)) %>
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

      <div style="margin-top: 4rem;">
        <h2 class="cottage-heading" style="font-size: 2rem; text-align: center; margin-bottom: 3rem;">
          Works in this Collection
        </h2>
        <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 2rem;">
          <div
            :for={artwork <- @artworks}
            id={"artwork-#{artwork.slug}"}
            style="border: 1px solid var(--cottage-taupe); border-radius: 8px; overflow: hidden; background: white; box-shadow: 0 2px 8px rgba(200, 167, 216, 0.08);"
            {annotation_attrs(@annotations_enabled, "artwork:#{artwork.slug}", %{
              "anchor_type" => "artwork",
              "artwork_id" => artwork.id,
              "series_slug" => @slug
            })}
          >
            <.link navigate={~p"/artworks/#{artwork.slug}"} style="display: block; text-decoration: none;">
              <div :if={artwork.image_url} style="aspect-ratio: 4/5; overflow: hidden;">
                <img
                  src={Olivia.Content.Artwork.resolved_image_url(artwork)}
                  alt={artwork.title}
                  style="width: 100%; height: 100%; object-fit: cover; display: block; transition: transform 0.3s ease;"
                />
              </div>
              <div
                :if={!artwork.image_url}
                style="aspect-ratio: 4/5; background: var(--cottage-beige); display: flex; align-items: center; justify-content: center;"
              >
                <span class="cottage-body" style="font-size: 0.875rem; color: var(--cottage-text-light);">No image</span>
              </div>
            </.link>
            <div style="padding: 1.5rem; text-align: center;">
              <h3 class="cottage-heading" style="font-size: 1.125rem; margin-bottom: 0.5rem;">
                <.link navigate={~p"/artworks/#{artwork.slug}"} style="text-decoration: none; color: inherit;">
                  <%= artwork.title %>
                </.link>
              </h3>
              <p class="cottage-body" style="font-size: 0.875rem; color: var(--cottage-text-medium); margin: 0;">
                <%= artwork.year %> · <%= artwork.medium %>
              </p>
              <p :if={artwork.dimensions} class="cottage-body" style="font-size: 0.875rem; color: var(--cottage-text-light); margin-top: 0.25rem;">
                <%= artwork.dimensions %>
              </p>
              <div style="margin-top: 0.75rem;">
                <span
                  :if={artwork.status == "available"}
                  class="cottage-body"
                  style="display: inline-block; font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.05em; color: var(--cottage-sage); padding: 0.25rem 0.75rem; border: 1px solid var(--cottage-sage); border-radius: 4px;"
                >
                  Available
                </span>
                <span
                  :if={artwork.status == "sold"}
                  class="cottage-body"
                  style="display: inline-block; font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.05em; color: var(--cottage-text-medium); padding: 0.25rem 0.75rem; border: 1px solid var(--cottage-taupe); border-radius: 4px;"
                >
                  Sold
                </span>
                <span
                  :if={artwork.status == "reserved"}
                  class="cottage-body"
                  style="display: inline-block; font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.05em; color: var(--cottage-wisteria); padding: 0.25rem 0.75rem; border: 1px solid var(--cottage-wisteria); border-radius: 4px;"
                >
                  Reserved
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div style="padding: 2rem 0; text-align: center; margin-top: 4rem; border-top: 1px solid var(--cottage-taupe);">
        <.link
          navigate={~p"/series"}
          class="cottage-body"
          style="font-size: 0.875rem; text-transform: uppercase; letter-spacing: 0.05em; color: var(--cottage-wisteria); text-decoration: none; border-bottom: 1px solid var(--cottage-wisteria); padding-bottom: 0.25rem;"
        >
          ← Back to all collections
        </.link>
      </div>
    </div>
    """
  end

  defp render_gallery(assigns) do
    ~H"""
    <!-- Gallery Hero -->
    <div style="text-align: center; padding: 4rem 1.5rem; border-bottom: 1px solid #e8e6e3;">
      <h1 class="gallery-heading" style="font-size: 3rem; color: #2c2416; margin-bottom: 1rem;">
        <%= @series.title %>
      </h1>
      <p class="gallery-script" style="font-size: 1.25rem; color: #6b5d54; max-width: 48rem; margin: 0 auto;">
        <%= @series.summary %>
      </p>
    </div>

    <!-- Description -->
    <div :if={@series.body_md} style="max-width: 48rem; margin: 0 auto; padding: 3rem 1.5rem;">
      <div
        id={"series-#{@slug}-description"}
        style="color: #4a4034; font-size: 1.125rem; line-height: 1.75;"
        {annotation_attrs(@annotations_enabled, "series:#{@slug}:description", %{
          "anchor_type" => "text",
          "series_slug" => @slug
        })}
      >
        <%= raw(Earmark.as_html!(@series.body_md)) %>
      </div>
    </div>

    <!-- Artworks Grid -->
    <div style="padding: 4rem 1.5rem; border-top: 1px solid #e8e6e3;">
      <h2 class="gallery-heading" style="font-size: 2rem; color: #2c2416; text-align: center; margin-bottom: 3rem;">
        Works in this Collection
      </h2>
      <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 3rem; max-width: 80rem; margin: 0 auto;">
        <div
          :for={artwork <- @artworks}
          id={"artwork-#{artwork.slug}"}
          class="artwork-card"
          {annotation_attrs(@annotations_enabled, "artwork:#{artwork.slug}", %{
            "anchor_type" => "artwork",
            "artwork_id" => artwork.id,
            "series_slug" => @slug
          })}
        >
          <.link navigate={~p"/artworks/#{artwork.slug}"} style="display: block; text-decoration: none;">
            <div :if={artwork.image_url} class="elegant-border" style="overflow: hidden; margin-bottom: 1rem; aspect-ratio: 4/5;">
              <img
                src={Olivia.Content.Artwork.resolved_image_url(artwork)}
                alt={artwork.title}
                style="width: 100%; height: 100%; object-fit: cover; display: block;"
              />
            </div>
            <div
              :if={!artwork.image_url}
              class="elegant-border"
              style="aspect-ratio: 4/5; background: #fafafa; display: flex; align-items: center; justify-content: center; margin-bottom: 1rem;"
            >
              <span style="font-size: 0.875rem; color: #999;">No image</span>
            </div>
          </.link>
          <div style="text-align: center;">
            <h3 class="gallery-heading" style="font-size: 1.125rem; color: #2c2416; margin-bottom: 0.5rem;">
              <.link navigate={~p"/artworks/#{artwork.slug}"} style="text-decoration: none; color: inherit;">
                <%= artwork.title %>
              </.link>
            </h3>
            <p style="font-size: 0.875rem; color: #6b5d54; margin: 0;">
              <%= artwork.year %> · <%= artwork.medium %>
            </p>
            <p :if={artwork.dimensions} style="font-size: 0.875rem; color: #9a8a7a; margin-top: 0.25rem;">
              <%= artwork.dimensions %>
            </p>
            <div style="margin-top: 0.5rem;">
              <span
                :if={artwork.status == "available"}
                style="display: inline-block; font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.05em; color: #6b8e23; padding: 0.25rem 0.5rem; border: 1px solid #9acd32; border-radius: 4px;"
              >
                Available
              </span>
              <span
                :if={artwork.status == "sold"}
                style="display: inline-block; font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.05em; color: #8b4513; padding: 0.25rem 0.5rem; border: 1px solid #d2691e; border-radius: 4px;"
              >
                Sold
              </span>
              <span
                :if={artwork.status == "reserved"}
                style="display: inline-block; font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.05em; color: #b8860b; padding: 0.25rem 0.5rem; border: 1px solid #daa520; border-radius: 4px;"
              >
                Reserved
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Back link -->
    <div style="padding: 2rem 1.5rem; text-align: center;">
      <.link navigate={~p"/series"} style="font-size: 0.875rem; text-transform: uppercase; letter-spacing: 0.05em; color: #8b7355; text-decoration: none; border-bottom: 1px solid #c4b5a0; padding-bottom: 0.25rem;">
        ← Back to all collections
      </.link>
    </div>

    <!-- Annotation recorder hook -->
    <%= if @annotations_enabled do %>
      <div id="annotation-recorder-container">
        <form id="annotation-upload-form" phx-change="noop" phx-submit="noop" phx-hook="AudioAnnotation" style="display: none;">
          <.live_file_input upload={@uploads.audio} id="annotation-audio-input" class="hidden" />
        </form>
      </div>
    <% end %>
    """
  end

  defp render_default(assigns) do
    ~H"""
    <%= if @slug == "becoming" do %>
      <!-- Becoming Series -->
      <div class="min-h-screen bg-white">
        <!-- Header -->
        <div class="bg-gray-50 py-16 sm:py-24">
          <div class="mx-auto max-w-7xl px-6 lg:px-8">
            <div class="mx-auto max-w-2xl text-center">
              <h1 class="text-4xl font-bold tracking-tight text-gray-900 sm:text-5xl">
                Becoming
              </h1>
              <p class="mt-2 text-lg text-gray-500 italic">Figure Works</p>
              <p class="mt-6 text-lg leading-8 text-gray-600">
                Expressionistic figure studies that capture the human form in moments of profound introspection.
              </p>
            </div>
          </div>
        </div>

        <!-- Description -->
        <div class="mx-auto max-w-3xl px-6 lg:px-8 py-16">
          <div
            id="series-becoming-description"
            class="prose prose-lg prose-gray"
            {annotation_attrs(@annotations_enabled, "series:becoming:description", %{
              "anchor_type" => "text",
              "series_slug" => "becoming"
            })}
          >
            <p>
              These paintings ask us to witness without intruding—the universal experience of sitting with difficulty, of weathering change, of the body as vessel for emotional experience. The gestural brushwork refuses prettiness or idealisation; each stroke is visible, urgent, yet the cumulative effect is deeply tender.
            </p>
            <p>
              The figures emerge from backgrounds of turbulent colour, their forms defined not by contour but by the weight of paint itself. This is portraiture that prioritises psychological truth over likeness—the body as it feels to inhabit, not merely as it appears.
            </p>
          </div>
        </div>

        <!-- Artworks Grid -->
        <div class="mx-auto max-w-7xl px-6 lg:px-8 pb-24">
          <h2 class="text-2xl font-bold tracking-tight text-gray-900 mb-12">
            Works in this Series
          </h2>
          <div class="grid grid-cols-1 gap-8 sm:grid-cols-2 lg:grid-cols-3">
            <!-- A Becoming -->
            <div
              id="artwork-a-becoming"
              class="group"
              {annotation_attrs(@annotations_enabled, "artwork:a-becoming", %{
                "anchor_type" => "artwork",
                "artwork_title" => "A Becoming",
                "series_slug" => "becoming"
              })}
            >
              <div class="aspect-[4/5] overflow-hidden rounded-lg bg-gray-100">
                <img
                  src={resolve_asset_url("/uploads/media/1763542139_3020310155b8abcf.jpg")}
                  alt="A Becoming - Expressionist figure painting"
                  class="w-full h-full object-cover group-hover:opacity-90 transition-opacity"
                />
              </div>
              <div class="mt-4">
                <h3 class="text-lg font-semibold text-gray-900">A Becoming</h3>
                <p class="text-sm text-gray-500">Oil on canvas</p>
              </div>
            </div>

            <!-- Changes -->
            <div
              id="artwork-changes"
              class="group"
              {annotation_attrs(@annotations_enabled, "artwork:changes", %{
                "anchor_type" => "artwork",
                "artwork_title" => "Changes",
                "series_slug" => "becoming"
              })}
            >
              <div class="aspect-[4/5] overflow-hidden rounded-lg bg-gray-100">
                <img
                  src={resolve_asset_url("/uploads/media/1763542139_22309219aa56fb95.jpg")}
                  alt="Changes - expressionistic figure study"
                  class="w-full h-full object-cover group-hover:opacity-90 transition-opacity"
                />
              </div>
              <div class="mt-4">
                <h3 class="text-lg font-semibold text-gray-900">Changes</h3>
                <p class="text-sm text-gray-500">Oil on canvas</p>
              </div>
            </div>

            <!-- She Lays Down -->
            <div
              id="artwork-she-lays-down"
              class="group"
              {annotation_attrs(@annotations_enabled, "artwork:she-lays-down", %{
                "anchor_type" => "artwork",
                "artwork_title" => "She Lays Down",
                "series_slug" => "becoming"
              })}
            >
              <div class="aspect-[4/5] overflow-hidden rounded-lg bg-gray-100">
                <img
                  src={resolve_asset_url("/uploads/media/1763483281_a84d8a1756abb807.JPG")}
                  alt="She Lays Down - reclining figure"
                  class="w-full h-full object-cover group-hover:opacity-90 transition-opacity"
                />
              </div>
              <div class="mt-4">
                <h3 class="text-lg font-semibold text-gray-900">She Lays Down</h3>
                <p class="text-sm text-gray-500">Oil on canvas</p>
              </div>
            </div>
          </div>
        </div>

        <!-- Back link -->
        <div class="border-t border-gray-200">
          <div class="mx-auto max-w-7xl px-6 lg:px-8 py-8">
            <.link navigate={~p"/series"} class="text-sm font-semibold text-gray-900 hover:text-gray-600">
              ← Back to all series
            </.link>
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
    <% end %>

    <%= if @slug == "abundance" do %>
      <!-- Abundance Series -->
      <div class="min-h-screen bg-white">
        <!-- Header -->
        <div class="bg-gray-50 py-16 sm:py-24">
          <div class="mx-auto max-w-7xl px-6 lg:px-8">
            <div class="mx-auto max-w-2xl text-center">
              <h1 class="text-4xl font-bold tracking-tight text-gray-900 sm:text-5xl">
                Abundance
              </h1>
              <p class="mt-2 text-lg text-gray-500 italic">Floral Works</p>
              <p class="mt-6 text-lg leading-8 text-gray-600">
                Exuberant floral still lifes that celebrate colour, pattern, and the tension between order and organic profusion.
              </p>
            </div>
          </div>
        </div>

        <!-- Description -->
        <div class="mx-auto max-w-3xl px-6 lg:px-8 py-16">
          <div class="prose prose-lg prose-gray">
            <p>
              These works demand attention, project outward, and perform their beauty with confidence—both natural and constructed, genuine and glamorous. Working with saturated grounds—coral reds, golden ochres—Olivia creates paintings that function almost as interior design elements while retaining the unpredictable energy of expressionism.
            </p>
            <p>
              The florals explore the relationship between containment and overflow. Vases struggle to hold arrangements that threaten to burst their bounds; petals curl and spill across the canvas edge. This is nature domesticated but not subdued.
            </p>
          </div>
        </div>

        <!-- Artworks Grid -->
        <div class="mx-auto max-w-7xl px-6 lg:px-8 pb-24">
          <h2 class="text-2xl font-bold tracking-tight text-gray-900 mb-12">
            Works in this Series
          </h2>
          <div class="grid grid-cols-1 gap-8 sm:grid-cols-2 lg:grid-cols-3">
            <!-- Ecstatic -->
            <div class="group">
              <div class="aspect-[4/5] overflow-hidden rounded-lg bg-gray-100">
                <img
                  src={resolve_asset_url("/uploads/media/1763542139_f6add8cef5e11b3a.jpg")}
                  alt="Ecstatic - floral still life"
                  class="w-full h-full object-cover group-hover:opacity-90 transition-opacity"
                />
              </div>
              <div class="mt-4">
                <h3 class="text-lg font-semibold text-gray-900">Ecstatic</h3>
                <p class="text-sm text-gray-500">Oil on canvas</p>
              </div>
            </div>

            <!-- Marilyn -->
            <div class="group">
              <div class="aspect-[4/5] overflow-hidden rounded-lg bg-gray-100">
                <img
                  src={resolve_asset_url("/uploads/media/1763542139_1225c3b883e0ce02.jpg")}
                  alt="Marilyn - golden floral"
                  class="w-full h-full object-cover group-hover:opacity-90 transition-opacity"
                />
              </div>
              <div class="mt-4">
                <h3 class="text-lg font-semibold text-gray-900">Marilyn</h3>
                <p class="text-sm text-gray-500">Oil on canvas</p>
              </div>
            </div>

            <!-- I Love Three Times -->
            <div class="group">
              <div class="aspect-[4/5] overflow-hidden rounded-lg bg-gray-100">
                <img
                  src={resolve_asset_url("/uploads/media/1763542139_5a2e8259c48f9c2c.JPG")}
                  alt="I Love Three Times - triptych"
                  class="w-full h-full object-cover group-hover:opacity-90 transition-opacity"
                />
              </div>
              <div class="mt-4">
                <h3 class="text-lg font-semibold text-gray-900">I Love Three Times</h3>
                <p class="text-sm text-gray-500">Oil on canvas, triptych</p>
              </div>
            </div>

            <!-- Red Ground -->
            <div class="group">
              <div class="aspect-[4/5] overflow-hidden rounded-lg bg-gray-100">
                <img
                  src={resolve_asset_url("/uploads/media/1763483281_62762e1c677b1d02.jpg")}
                  alt="Floral with red ground"
                  class="w-full h-full object-cover group-hover:opacity-90 transition-opacity"
                />
              </div>
              <div class="mt-4">
                <h3 class="text-lg font-semibold text-gray-900">Untitled (Red Ground)</h3>
                <p class="text-sm text-gray-500">Oil on canvas</p>
              </div>
            </div>

            <!-- Coral Ground -->
            <div class="group">
              <div class="aspect-[4/5] overflow-hidden rounded-lg bg-gray-100">
                <img
                  src={resolve_asset_url("/uploads/media/1763483281_c9cd48fa716cf037.jpg")}
                  alt="Floral detail with coral ground"
                  class="w-full h-full object-cover group-hover:opacity-90 transition-opacity"
                />
              </div>
              <div class="mt-4">
                <h3 class="text-lg font-semibold text-gray-900">Untitled (Coral Ground)</h3>
                <p class="text-sm text-gray-500">Oil on canvas</p>
              </div>
            </div>

            <!-- I Love Three Times Detail -->
            <div class="group">
              <div class="aspect-[4/5] overflow-hidden rounded-lg bg-gray-100">
                <img
                  src={resolve_asset_url("/uploads/media/1763542139_3fcf4d765e5a5eeb.jpg")}
                  alt="I Love Three Times detail"
                  class="w-full h-full object-cover group-hover:opacity-90 transition-opacity"
                />
              </div>
              <div class="mt-4">
                <h3 class="text-lg font-semibold text-gray-900">I Love Three Times (Detail)</h3>
                <p class="text-sm text-gray-500">Oil on canvas, two panels</p>
              </div>
            </div>
          </div>
        </div>

        <!-- Back link -->
        <div class="border-t border-gray-200">
          <div class="mx-auto max-w-7xl px-6 lg:px-8 py-8">
            <.link navigate={~p"/series"} class="text-sm font-semibold text-gray-900 hover:text-gray-600">
              ← Back to all series
            </.link>
          </div>
        </div>
      </div>
    <% end %>

    <%= if @slug == "shifting" do %>
      <!-- Shifting Series -->
      <div class="min-h-screen bg-white">
        <!-- Header -->
        <div class="bg-gray-50 py-16 sm:py-24">
          <div class="mx-auto max-w-7xl px-6 lg:px-8">
            <div class="mx-auto max-w-2xl text-center">
              <h1 class="text-4xl font-bold tracking-tight text-gray-900 sm:text-5xl">
                Shifting
              </h1>
              <p class="mt-2 text-lg text-gray-500 italic">Landscape Works</p>
              <p class="mt-6 text-lg leading-8 text-gray-600">
                Landscapes in perpetual transformation, where the canvas becomes a physical analogue for the terrain it depicts.
              </p>
            </div>
          </div>
        </div>

        <!-- Description -->
        <div class="mx-auto max-w-3xl px-6 lg:px-8 py-16">
          <div class="prose prose-lg prose-gray">
            <p>
              The impasto application is extraordinary in its physicality—paint applied in thick, directional strokes that mimic geological strata, creating surfaces that function almost as relief sculpture. These aren't landscapes observed; they're landscapes experienced through the body.
            </p>
            <p>
              The diptych format emphasises the continuity of terrain across boundaries. The works present terrain in perpetual transformation—mountains becoming sky, earth becoming water, solid becoming fluid.
            </p>
          </div>
        </div>

        <!-- Artworks Grid -->
        <div class="mx-auto max-w-7xl px-6 lg:px-8 pb-24">
          <h2 class="text-2xl font-bold tracking-tight text-gray-900 mb-12">
            Works in this Series
          </h2>
          <div class="grid grid-cols-1 gap-8">
            <!-- Shifting Diptych - Full Width -->
            <div class="group">
              <div class="aspect-[21/9] overflow-hidden rounded-lg bg-gray-100">
                <img
                  src={resolve_asset_url("/uploads/media/1763483281_14d2d6ab6485926c.jpg")}
                  alt="Shifting - expressionist landscape diptych"
                  class="w-full h-full object-cover group-hover:opacity-90 transition-opacity"
                />
              </div>
              <div class="mt-4">
                <h3 class="text-lg font-semibold text-gray-900">Shifting</h3>
                <p class="text-sm text-gray-500">Oil on canvas, diptych</p>
              </div>
            </div>

            <!-- Individual panels -->
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-8">
              <!-- Shifting Part 1 -->
              <div class="group">
                <div class="aspect-[4/5] overflow-hidden rounded-lg bg-gray-100">
                  <img
                    src={resolve_asset_url("/uploads/media/1763483281_ebd1913da6ebeabd.jpg")}
                    alt="Shifting Part 1"
                    class="w-full h-full object-cover group-hover:opacity-90 transition-opacity"
                  />
                </div>
                <div class="mt-4">
                  <h3 class="text-lg font-semibold text-gray-900">Shifting Part 1</h3>
                  <p class="text-sm text-gray-500">Oil on canvas</p>
                </div>
              </div>

              <!-- Shifting Part 2 -->
              <div class="group">
                <div class="aspect-[4/5] overflow-hidden rounded-lg bg-gray-100">
                  <img
                    src={resolve_asset_url("/uploads/media/1763483281_a7b4acd750ac636c.jpg")}
                    alt="Shifting Part 2"
                    class="w-full h-full object-cover group-hover:opacity-90 transition-opacity"
                  />
                </div>
                <div class="mt-4">
                  <h3 class="text-lg font-semibold text-gray-900">Shifting Part 2</h3>
                  <p class="text-sm text-gray-500">Oil on canvas</p>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Back link -->
        <div class="border-t border-gray-200">
          <div class="mx-auto max-w-7xl px-6 lg:px-8 py-8">
            <.link navigate={~p"/series"} class="text-sm font-semibold text-gray-900 hover:text-gray-600">
              ← Back to all series
            </.link>
          </div>
        </div>
      </div>
    <% end %>

    <%= if @slug not in ["becoming", "abundance", "shifting"] do %>
      <!-- Fallback for database series -->
      <div class="bg-white">
        <!-- Header -->
        <div class="mx-auto max-w-7xl px-6 lg:px-8 py-24 sm:py-32">
          <div class="mx-auto max-w-2xl text-center">
            <h1 class="text-4xl font-bold tracking-tight text-gray-900 sm:text-5xl">
              <%= @series.title %>
            </h1>
            <p class="mt-6 text-lg leading-8 text-gray-600">
              <%= @series.summary %>
            </p>
          </div>
        </div>

        <!-- Description -->
        <div :if={@series.body_md} class="mx-auto max-w-7xl px-6 lg:px-8 pb-16">
          <div class="mx-auto max-w-2xl prose prose-lg prose-gray">
            <%= raw(Earmark.as_html!(@series.body_md)) %>
          </div>
        </div>

        <!-- Artworks Grid -->
        <div class="mx-auto max-w-7xl px-6 lg:px-8 pb-24">
          <h2 class="text-2xl font-bold tracking-tight text-gray-900 mb-12">
            Works in this Series
          </h2>
          <div class="grid grid-cols-1 gap-x-6 gap-y-10 sm:grid-cols-2 lg:grid-cols-3 xl:gap-x-8">
            <div :for={artwork <- @artworks} class="group relative">
              <.link navigate={~p"/artworks/#{artwork.slug}"}>
                <div class="aspect-[4/5] w-full overflow-hidden rounded-lg">
                  <img
                    :if={artwork.image_url}
                    src={Olivia.Content.Artwork.resolved_image_url(artwork)}
                    alt={artwork.title}
                    class="h-full w-full object-cover group-hover:opacity-75 transition-opacity"
                  />
                  <div
                    :if={!artwork.image_url}
                    class="h-full w-full bg-gray-100 flex items-center justify-center"
                  >
                    <span class="text-sm text-gray-400">No image</span>
                  </div>
                </div>
              </.link>
              <div class="mt-4">
                <h3 class="text-sm font-medium text-gray-900">
                  <%= artwork.title %>
                </h3>
                <p class="mt-1 text-sm text-gray-500">
                  <%= artwork.year %> · <%= artwork.medium %>
                </p>
              </div>
            </div>
          </div>
        </div>

        <!-- Back link -->
        <div class="mx-auto max-w-7xl px-6 lg:px-8 pb-24">
          <.link navigate={~p"/series"} class="text-sm font-semibold leading-6 text-gray-900">
            ← Back to all series
          </.link>
        </div>
      </div>
    <% end %>
    """
  end

  @impl true
  def mount(%{"slug" => slug}, _session, socket) do
    theme = socket.assigns[:theme]
    page_path = "/series/#{slug}"

    # Derive annotations_enabled from theme
    annotations_enabled = theme == "reviewer"

    # Handle hardcoded series for Original theme
    socket = if slug in ["becoming", "abundance", "shifting"] do
      title = case slug do
        "becoming" -> "Becoming"
        "abundance" -> "Abundance"
        "shifting" -> "Shifting"
      end

      socket
      |> assign(:page_title, "#{title} - Olivia Tew")
      |> assign(:slug, slug)
      |> assign(:series, %{title: title, summary: "", body_md: nil})
      |> assign(:artworks, [])
    else
      series = Content.get_series_by_slug!(slug, published: true)
      artworks = Content.list_artworks(series_id: series.id, published: true)

      socket
      |> assign(:page_title, "#{series.title} - Olivia Tew")
      |> assign(:slug, slug)
      |> assign(:series, series)
      |> assign(:artworks, artworks)
    end

    # Set annotations_enabled for all themes
    socket = assign(socket, :annotations_enabled, annotations_enabled)

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
    Logger.debug("save_audio_blob event received: #{filename}, #{mime_type}")

    anchor = socket.assigns.current_anchor

    if !anchor do
      Logger.warning("No current_anchor set")
      {:noreply, put_flash(socket, :error, "No annotation target selected")}
    else
      Logger.debug("Processing blob upload for anchor: #{inspect(anchor)}")

      # Decode base64 audio data
      case Base.decode64(blob_data) do
        {:ok, binary} ->
          save_audio_binary(socket, binary, filename, mime_type, anchor.key, anchor.meta)

        :error ->
          Logger.error("Failed to decode base64 audio data")
          {:noreply, put_flash(socket, :error, "Invalid audio data")}
      end
    end
  end

  defp save_audio_binary(socket, binary, filename, mime_type, anchor_key, anchor_meta) do
    require Logger
    theme = socket.assigns.theme
    page_path = socket.assigns.page_path
    user = socket.assigns[:current_scope] && socket.assigns.current_scope.user

    Logger.debug("Saving audio binary: #{byte_size(binary)} bytes")

    # Write binary to a temporary file
    temp_path = Path.join(System.tmp_dir!(), filename)

    case File.write(temp_path, binary) do
      :ok ->
        # Upload to S3
        clean_filename = Uploads.generate_filename(filename)
        key = "voice_notes/#{clean_filename}"

        case Uploads.upload_file(temp_path, key, mime_type) do
          {:ok, audio_url} ->
            # Clean up temp file
            File.rm(temp_path)

            # Save to database
            attrs = %{
              audio_url: audio_url,
              anchor_key: anchor_key,
              anchor_meta: anchor_meta,
              anchor_type: "explicit",
              page_path: page_path,
              theme: theme,
              user_id: user && user.id
            }

            case Annotations.create_voice_note(attrs) do
              {:ok, note} ->
                Logger.info("Voice note created: #{note.id}")

                {:noreply,
                 socket
                 |> assign(:current_anchor, nil)
                 |> update(:existing_notes, &[note | &1])
                 |> push_event("note_created", %{
                   id: note.id,
                   anchor_key: note.anchor_key,
                   audio_url: note.audio_url
                 })}

              {:error, changeset} ->
                Logger.error("Failed to create voice note: #{inspect(changeset)}")
                {:noreply, put_flash(socket, :error, "Failed to save note")}
            end

          {:error, reason} ->
            File.rm(temp_path)
            Logger.error("Failed to upload to S3: #{inspect(reason)}")
            {:noreply, put_flash(socket, :error, "Upload failed")}
        end

      {:error, reason} ->
        Logger.error("Failed to write temp file: #{inspect(reason)}")
        {:noreply, put_flash(socket, :error, "Failed to process audio")}
    end
  end

end
