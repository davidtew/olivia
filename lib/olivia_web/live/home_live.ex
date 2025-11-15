defmodule OliviaWeb.HomeLive do
  use OliviaWeb, :live_view

  alias Olivia.CMS
  alias Olivia.Content

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen">
      <!-- Hero Section -->
      <div class="relative bg-gray-50 py-24 sm:py-32">
        <div class="mx-auto max-w-7xl px-6 lg:px-8">
          <div class="mx-auto max-w-2xl text-center">
            <h1 class="text-4xl font-bold tracking-tight text-gray-900 sm:text-6xl">
              <%= @sections["hero_title"] %>
            </h1>
            <p class="mt-6 text-lg leading-8 text-gray-600">
              <%= @sections["hero_subtitle"] %>
            </p>
          </div>
        </div>
      </div>

      <!-- Intro Section -->
      <div class="mx-auto max-w-7xl px-6 lg:px-8 py-16">
        <div class="mx-auto max-w-2xl">
          <div class="prose prose-lg prose-gray mx-auto">
            <%= raw(Earmark.as_html!(@sections["intro"] || "")) %>
          </div>
        </div>
      </div>

      <!-- Featured Artworks -->
      <div :if={length(@featured_artworks) > 0} class="bg-white py-16">
        <div class="mx-auto max-w-7xl px-6 lg:px-8">
          <div class="mx-auto max-w-2xl text-center">
            <h2 class="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
              Featured Works
            </h2>
          </div>
          <div class="mx-auto mt-16 grid max-w-2xl grid-cols-1 gap-x-8 gap-y-12 sm:mt-20 lg:mx-0 lg:max-w-none lg:grid-cols-3">
            <article
              :for={artwork <- @featured_artworks}
              class="flex flex-col items-start justify-between"
            >
              <div class="relative w-full">
                <.link navigate={~p"/artworks/#{artwork.slug}"}>
                  <div :if={artwork.image_url}>
                    <.artwork_image
                      src={artwork.image_url}
                      alt={artwork.title}
                      aspect="aspect-[4/5]"
                      class="rounded-2xl hover:opacity-90 transition-opacity"
                      sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 33vw"
                    />
                  </div>
                  <div
                    :if={!artwork.image_url}
                    class="aspect-[4/5] w-full rounded-2xl bg-gray-100 flex items-center justify-center"
                  >
                    <span class="text-sm text-gray-400">No image</span>
                  </div>
                  <div class="absolute inset-0 rounded-2xl ring-1 ring-inset ring-gray-900/10"></div>
                </.link>
              </div>
              <div class="max-w-xl mt-4">
                <div class="group relative">
                  <h3 class="mt-3 text-lg font-semibold leading-6 text-gray-900 group-hover:text-gray-600">
                    <.link navigate={~p"/artworks/#{artwork.slug}"}>
                      <%= artwork.title %>
                    </.link>
                  </h3>
                  <p class="mt-2 text-sm leading-6 text-gray-600">
                    <%= artwork.year %> · <%= artwork.medium %>
                  </p>
                  <p :if={artwork.series} class="mt-1 text-sm text-gray-500">
                    <%= artwork.series.title %>
                  </p>
                </div>
              </div>
            </article>
          </div>
          <div class="mt-10 text-center">
            <.link
              navigate={~p"/series"}
              class="text-sm font-semibold leading-6 text-gray-900 hover:text-gray-600"
            >
              View all series <span aria-hidden="true">→</span>
            </.link>
          </div>
        </div>
      </div>

      <!-- Hotels Teaser -->
      <div class="bg-gray-50 py-16">
        <div class="mx-auto max-w-7xl px-6 lg:px-8">
          <div class="mx-auto max-w-2xl">
            <div class="prose prose-lg prose-gray mx-auto">
              <%= raw(Earmark.as_html!(@sections["hotels_teaser"] || "")) %>
            </div>
            <div class="mt-8 text-center">
              <.link
                navigate={~p"/hotels-designers"}
                class="rounded-md bg-gray-900 px-3.5 py-2.5 text-sm font-semibold text-white shadow-sm hover:bg-gray-800"
              >
                Learn more
              </.link>
            </div>
          </div>
        </div>
      </div>

      <!-- Newsletter Section -->
      <div class="bg-white py-16 sm:py-24">
        <div class="mx-auto max-w-7xl px-6 lg:px-8">
          <div class="mx-auto max-w-2xl text-center">
            <h2 class="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
              Stay Updated
            </h2>
            <p class="mt-4 text-lg leading-8 text-gray-600">
              <%= @sections["newsletter_blurb"] %>
            </p>
          </div>
          <form
            phx-submit="subscribe"
            class="mx-auto mt-10 flex max-w-md gap-x-4"
          >
            <label for="email-address" class="sr-only">Email address</label>
            <input
              id="email-address"
              name="email"
              type="email"
              autocomplete="email"
              required
              class="min-w-0 flex-auto rounded-md border-0 px-3.5 py-2 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-gray-600 sm:text-sm sm:leading-6"
              placeholder="Enter your email"
            />
            <button
              type="submit"
              class="flex-none rounded-md bg-gray-900 px-3.5 py-2.5 text-sm font-semibold text-white shadow-sm hover:bg-gray-800 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-gray-600"
            >
              Subscribe
            </button>
          </form>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    page = CMS.get_page_by_slug!("home", preload: [:sections])
    sections = sections_to_map(page.sections)
    featured_artworks = Content.list_featured_artworks(preload: [:series], limit: 3)

    {:ok,
     socket
     |> assign(:page_title, "Olivia Tew - Contemporary Painter")
     |> assign(:sections, sections)
     |> assign(:featured_artworks, featured_artworks)}
  end

  @impl true
  def handle_event("subscribe", %{"email" => email}, socket) do
    case Olivia.Communications.create_subscriber(%{email: email, source: "website_form"}) do
      {:ok, _subscriber} ->
        {:noreply,
         socket
         |> put_flash(:info, "Thank you for subscribing! You'll hear from us soon.")
         |> push_navigate(to: ~p"/")}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "There was an issue subscribing. Please try again.")}
    end
  end

  defp sections_to_map(sections) do
    Enum.reduce(sections, %{}, fn section, acc ->
      Map.put(acc, section.key, section.content_md)
    end)
  end
end
