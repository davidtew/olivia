defmodule OliviaWeb.SeriesLive.Index do
  use OliviaWeb, :live_view

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
            <div :if={series.cover_image_url} style="height: 100%;">
              <.artwork_image
                src={series.cover_image_url}
                alt={series.title}
                aspect="aspect-[16/9]"
                style="width: 100%; height: 100%; object-fit: cover; display: block;"
                sizes="(max-width: 768px) 100vw, 50vw"
              />
            </div>
            <div
              :if={!series.cover_image_url}
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
            <div :if={series.cover_image_url} class="elegant-border" style="overflow: hidden; margin-bottom: 1rem;">
              <.artwork_image
                src={series.cover_image_url}
                alt={series.title}
                aspect="aspect-[16/9]"
                style="width: 100%; display: block;"
                sizes="(max-width: 768px) 100vw, 80vw"
              />
            </div>
            <div
              :if={!series.cover_image_url}
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
    <div class="bg-white py-24 sm:py-32">
      <div class="mx-auto max-w-7xl px-6 lg:px-8">
        <div class="mx-auto max-w-2xl text-center">
          <h1 class="text-4xl font-bold tracking-tight text-gray-900 sm:text-5xl">
            Series
          </h1>
          <p class="mt-6 text-lg leading-8 text-gray-600">
            Explore collections of work organized by theme and subject matter.
          </p>
        </div>

        <div class="mx-auto mt-16 grid max-w-2xl grid-cols-1 gap-x-8 gap-y-20 lg:mx-0 lg:max-w-none lg:grid-cols-2">
          <article :for={series <- @series_list} class="flex flex-col items-start">
            <div class="relative w-full">
              <.link navigate={~p"/series/#{series.slug}"}>
                <div :if={series.cover_image_url}>
                  <.artwork_image
                    src={series.cover_image_url}
                    alt={series.title}
                    aspect="aspect-[16/9]"
                    class="rounded-2xl hover:opacity-90 transition-opacity"
                    sizes="(max-width: 1024px) 100vw, 50vw"
                  />
                </div>
                <div
                  :if={!series.cover_image_url}
                  class="aspect-[16/9] w-full rounded-2xl bg-gray-100 flex items-center justify-center"
                >
                  <span class="text-sm text-gray-400">No image</span>
                </div>
                <div class="absolute inset-0 rounded-2xl ring-1 ring-inset ring-gray-900/10"></div>
              </.link>
            </div>
            <div class="max-w-xl">
              <div class="mt-8 flex items-center gap-x-4 text-xs">
                <span class="text-gray-500">
                  <%= length(series.artworks) %> <%= if length(series.artworks) == 1,
                    do: "artwork",
                    else: "artworks" %>
                </span>
              </div>
              <div class="group relative">
                <h3 class="mt-3 text-lg font-semibold leading-6 text-gray-900 group-hover:text-gray-600">
                  <.link navigate={~p"/series/#{series.slug}"}>
                    <span class="absolute inset-0"></span>
                    <%= series.title %>
                  </.link>
                </h3>
                <p class="mt-5 line-clamp-3 text-sm leading-6 text-gray-600">
                  <%= series.summary %>
                </p>
              </div>
              <div class="mt-4">
                <.link
                  navigate={~p"/series/#{series.slug}"}
                  class="text-sm font-semibold leading-6 text-gray-900 hover:text-gray-600"
                >
                  View series <span aria-hidden="true">→</span>
                </.link>
              </div>
            </div>
          </article>
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
