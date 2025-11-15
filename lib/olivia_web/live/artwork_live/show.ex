defmodule OliviaWeb.ArtworkLive.Show do
  use OliviaWeb, :live_view

  alias Olivia.Content

  @impl true
  def render(assigns) do
    ~H"""
    <div class="bg-white">
      <div class="mx-auto max-w-2xl px-4 py-16 sm:px-6 sm:py-24 lg:max-w-7xl lg:px-8">
        <div class="lg:grid lg:grid-cols-2 lg:items-start lg:gap-x-8">
          <!-- Image gallery -->
          <div class="flex flex-col-reverse">
            <div :if={@artwork.image_url}>
              <.artwork_image
                src={@artwork.image_url}
                alt={@artwork.title}
                aspect="aspect-[4/5]"
                class="rounded-lg shadow-lg"
                sizes="(max-width: 1024px) 100vw, 50vw"
                loading="eager"
              />
            </div>
            <div
              :if={!@artwork.image_url}
              class="aspect-[4/5] w-full overflow-hidden rounded-lg bg-gray-100 flex items-center justify-center"
            >
              <span class="text-lg text-gray-400">No image available</span>
            </div>
          </div>

          <!-- Artwork info -->
          <div class="mt-10 px-4 sm:mt-16 sm:px-0 lg:mt-0">
            <h1 class="text-3xl font-bold tracking-tight text-gray-900">
              <%= @artwork.title %>
            </h1>

            <div class="mt-3">
              <h2 class="sr-only">Artwork information</h2>
              <p :if={@artwork.price_cents && @artwork.status == "available"} class="text-3xl tracking-tight text-gray-900">
                <%= format_price(@artwork.price_cents, @artwork.currency) %>
              </p>
              <p :if={@artwork.status == "sold"} class="text-xl tracking-tight text-red-700">
                Sold
              </p>
              <p :if={@artwork.status == "reserved"} class="text-xl tracking-tight text-yellow-700">
                Reserved
              </p>
            </div>

            <div class="mt-6">
              <h3 class="sr-only">Description</h3>
              <div class="prose prose-gray">
                <%= raw(Earmark.as_html!(@artwork.description_md || "")) %>
              </div>
            </div>

            <div class="mt-6 space-y-2">
              <div class="flex justify-between text-sm">
                <dt class="text-gray-500">Year</dt>
                <dd class="font-medium text-gray-900"><%= @artwork.year %></dd>
              </div>
              <div class="flex justify-between text-sm">
                <dt class="text-gray-500">Medium</dt>
                <dd class="font-medium text-gray-900"><%= @artwork.medium %></dd>
              </div>
              <div :if={@artwork.dimensions} class="flex justify-between text-sm">
                <dt class="text-gray-500">Dimensions</dt>
                <dd class="font-medium text-gray-900"><%= @artwork.dimensions %></dd>
              </div>
              <div :if={@artwork.location} class="flex justify-between text-sm">
                <dt class="text-gray-500">Location</dt>
                <dd class="font-medium text-gray-900"><%= @artwork.location %></dd>
              </div>
              <div :if={@artwork.series} class="flex justify-between text-sm border-t pt-2 mt-4">
                <dt class="text-gray-500">Series</dt>
                <dd class="font-medium text-gray-900">
                  <.link navigate={~p"/series/#{@artwork.series.slug}"} class="hover:text-gray-600">
                    <%= @artwork.series.title %>
                  </.link>
                </dd>
              </div>
            </div>

            <div :if={@artwork.status == "available"} class="mt-10">
              <.link
                navigate={~p"/collect"}
                class="flex w-full items-center justify-center rounded-md border border-transparent bg-gray-900 px-8 py-3 text-base font-medium text-white hover:bg-gray-800 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2"
              >
                Enquire about this work
              </.link>
            </div>

            <div class="mt-6">
              <.link
                navigate={
                  if @artwork.series,
                    do: ~p"/series/#{@artwork.series.slug}",
                    else: ~p"/series"
                }
                class="text-sm font-semibold text-gray-900"
              >
                ← Back to <%= if @artwork.series, do: @artwork.series.title, else: "series" %>
              </.link>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(%{"slug" => slug}, _session, socket) do
    artwork = Content.get_artwork_by_slug!(slug, published: true, preload: [:series])

    {:ok,
     socket
     |> assign(:page_title, "#{artwork.title} - Olivia Tew")
     |> assign(:artwork, artwork)}
  end

  defp format_price(cents, currency) do
    amount = cents / 100
    symbol =
      case currency do
        "GBP" -> "£"
        "USD" -> "$"
        "EUR" -> "€"
        _ -> currency
      end

    formatted = :erlang.float_to_binary(amount, decimals: 0)
    "#{symbol}#{formatted}"
  end
end
