defmodule OliviaWeb.SeriesLive.Show do
  use OliviaWeb, :live_view

  alias Olivia.Content

  @impl true
  def render(assigns) do
    ~H"""
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
                  src={artwork.image_url}
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
            <div class="mt-4 flex justify-between">
              <div>
                <h3 class="text-sm font-medium text-gray-900">
                  <.link navigate={~p"/artworks/#{artwork.slug}"}>
                    <span aria-hidden="true" class="absolute inset-0"></span>
                    <%= artwork.title %>
                  </.link>
                </h3>
                <p class="mt-1 text-sm text-gray-500">
                  <%= artwork.year %> · <%= artwork.medium %>
                </p>
                <p :if={artwork.dimensions} class="mt-1 text-sm text-gray-500">
                  <%= artwork.dimensions %>
                </p>
              </div>
              <div>
                <span
                  :if={artwork.status == "available"}
                  class="inline-flex items-center rounded-md bg-green-50 px-2 py-1 text-xs font-medium text-green-700 ring-1 ring-inset ring-green-600/20"
                >
                  Available
                </span>
                <span
                  :if={artwork.status == "sold"}
                  class="inline-flex items-center rounded-md bg-red-50 px-2 py-1 text-xs font-medium text-red-700 ring-1 ring-inset ring-red-600/10"
                >
                  Sold
                </span>
                <span
                  :if={artwork.status == "reserved"}
                  class="inline-flex items-center rounded-md bg-yellow-50 px-2 py-1 text-xs font-medium text-yellow-800 ring-1 ring-inset ring-yellow-600/20"
                >
                  Reserved
                </span>
              </div>
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
    """
  end

  @impl true
  def mount(%{"slug" => slug}, _session, socket) do
    series = Content.get_series_by_slug!(slug, published: true)
    artworks = Content.list_artworks(series_id: series.id, published: true)

    {:ok,
     socket
     |> assign(:page_title, "#{series.title} - Olivia Tew")
     |> assign(:series, series)
     |> assign(:artworks, artworks)}
  end
end
