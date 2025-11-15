defmodule OliviaWeb.SeriesLive.Index do
  use OliviaWeb, :live_view

  alias Olivia.Content

  @impl true
  def render(assigns) do
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
