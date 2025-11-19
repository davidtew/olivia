defmodule OliviaWeb.SeriesLive.Index do
  use OliviaWeb, :live_view

  import OliviaWeb.AssetHelpers, only: [resolve_asset_url: 1]

  alias Olivia.Content

  @impl true
  def render(assigns) do
    cond do
      assigns[:theme] == "cottage" -> render_cottage(assigns)
      assigns[:theme] == "gallery" -> render_gallery(assigns)
      true -> render_default(assigns)
    end
  end

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
              style="aspect-ratio: 16/9; background: var(--cottage-beige); display: flex; align-items: center; justify-content: center;"
            >
              <span class="cottage-body" style="font-size: 0.875rem; color: var(--cottage-text-light);">No image</span>
            </div>
          </.link>
          <div style="padding: 2rem;">
            <div style="margin-bottom: 0.75rem;">
              <span class="cottage-body" style="font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.1em; color: var(--cottage-text-light);">
                <%= length(series.artworks) %> <%= if length(series.artworks) == 1,
                  do: "artwork",
                  else: "artworks" %>
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
    <!-- Gallery Hero -->
    <div style="text-align: center; padding: 4rem 1.5rem; border-bottom: 1px solid #e8e6e3;">
      <h1 class="gallery-heading" style="font-size: 3rem; color: #2c2416; margin-bottom: 1rem;">
        Collections
      </h1>
      <p class="gallery-script" style="font-size: 1.25rem; color: #6b5d54; max-width: 42rem; margin: 0 auto;">
        Explore curated collections organized by theme and subject matter.
      </p>
    </div>

    <!-- Series Grid -->
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
              style="aspect-ratio: 16/9; background: #fafafa; display: flex; align-items: center; justify-content: center; margin-bottom: 1rem;"
            >
              <span style="font-size: 0.875rem; color: #999;">No image</span>
            </div>
          </.link>
          <div>
            <div style="margin-bottom: 0.75rem;">
              <span style="font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.1em; color: #9a8a7a;">
                <%= length(series.artworks) %> <%= if length(series.artworks) == 1,
                  do: "artwork",
                  else: "artworks" %>
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

  defp render_default(assigns) do
    ~H"""
    <div class="min-h-screen bg-white">
      <!-- Page Header -->
      <div class="bg-gray-50 py-16 sm:py-24">
        <div class="mx-auto max-w-7xl px-6 lg:px-8">
          <div class="mx-auto max-w-2xl text-center">
            <h1 class="text-4xl font-bold tracking-tight text-gray-900 sm:text-5xl">
              Collections
            </h1>
            <p class="mt-6 text-lg leading-8 text-gray-600">
              Three distinct bodies of work united by bold colour, gestural mark-making, and an unflinching approach to emotional truth.
            </p>
          </div>
        </div>
      </div>

      <!-- Series Grid -->
      <div class="py-16 sm:py-24">
        <div class="mx-auto max-w-7xl px-6 lg:px-8">
          <div class="grid grid-cols-1 gap-16">
            <!-- Becoming - Figure Works -->
            <article class="grid lg:grid-cols-2 gap-8 items-center">
              <.link navigate={~p"/series/becoming"} class="group block">
                <div class="relative aspect-[4/3] overflow-hidden rounded-lg bg-gray-100">
                  <img
                    src={resolve_asset_url("/uploads/media/1763542139_3020310155b8abcf.jpg")}
                    alt="A Becoming - Expressionist figure painting"
                    class="w-full h-full object-cover group-hover:opacity-90 transition-opacity"
                  />
                </div>
              </.link>
              <div>
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
              </div>
            </article>

            <!-- Abundance - Floral Works -->
            <article class="grid lg:grid-cols-2 gap-8 items-center">
              <div class="order-2 lg:order-1">
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
              </div>
              <.link navigate={~p"/series/abundance"} class="group block order-1 lg:order-2">
                <div class="relative aspect-[4/3] overflow-hidden rounded-lg bg-gray-100">
                  <img
                    src={resolve_asset_url("/uploads/media/1763542139_f6add8cef5e11b3a.jpg")}
                    alt="Ecstatic - floral still life"
                    class="w-full h-full object-cover group-hover:opacity-90 transition-opacity"
                  />
                </div>
              </.link>
            </article>

            <!-- Shifting - Landscape Works -->
            <article class="grid lg:grid-cols-2 gap-8 items-center">
              <.link navigate={~p"/series/shifting"} class="group block">
                <div class="relative aspect-[4/3] overflow-hidden rounded-lg bg-gray-100">
                  <img
                    src={resolve_asset_url("/uploads/media/1763483281_14d2d6ab6485926c.jpg")}
                    alt="Shifting - expressionist landscape diptych"
                    class="w-full h-full object-cover group-hover:opacity-90 transition-opacity"
                  />
                </div>
              </.link>
              <div>
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
              </div>
            </article>
          </div>
        </div>
      </div>

      <!-- Back to home -->
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

    {:ok,
     socket
     |> assign(:page_title, "Series - Olivia Tew")
     |> assign(:series_list, series_list)}
  end
end
