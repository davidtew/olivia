defmodule OliviaWeb.PageLive do
  use OliviaWeb, :live_view

  alias Olivia.CMS

  @impl true
  def render(assigns) do
    ~H"""
    <div class="bg-white px-6 py-24 sm:py-32 lg:px-8">
      <div class="mx-auto max-w-3xl text-base leading-7 text-gray-700">
        <div :for={section <- @sections} class="mt-10 first:mt-0">
          <div class="prose prose-lg prose-gray max-w-none">
            <%= raw(Earmark.as_html!(section.content_md || "")) %>
          </div>
        </div>

        <!-- Newsletter signup for specific pages -->
        <div
          :if={@page.slug in ["about", "collect"]}
          class="mt-16 border-t border-gray-200 pt-16"
        >
          <div class="mx-auto max-w-2xl text-center">
            <h2 class="text-2xl font-bold tracking-tight text-gray-900">
              Stay in Touch
            </h2>
            <p class="mt-4 text-lg text-gray-600">
              Subscribe to hear about new work and exhibitions.
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
              class="flex-none rounded-md bg-gray-900 px-3.5 py-2.5 text-sm font-semibold text-white shadow-sm hover:bg-gray-800"
            >
              Subscribe
            </button>
          </form>
        </div>

        <!-- Back to home -->
        <div class="mt-16 border-t border-gray-200 pt-8">
          <.link navigate={~p"/"} class="text-sm font-semibold text-gray-900">
            ← Back to home
          </.link>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(_params, uri, socket) do
    slug = slug_from_uri(uri)
    page = CMS.get_page_by_slug!(slug, preload: [:sections])
    sections = Enum.sort_by(page.sections, & &1.position)

    {:noreply,
     socket
     |> assign(:page_title, "#{page.title} - Olivia Tew")
     |> assign(:page, page)
     |> assign(:sections, sections)}
  end

  defp slug_from_uri(uri) do
    path = URI.parse(uri).path

    case path do
      "/about" -> "about"
      "/collect" -> "collect"
      "/hotels-designers" -> "hotels-designers"
      "/press-projects" -> "press-projects"
      _ -> "home"
    end
  end

  @impl true
  def handle_event("subscribe", %{"email" => email}, socket) do
    case Olivia.Communications.create_subscriber(%{email: email, source: "website_form"}) do
      {:ok, _subscriber} ->
        {:noreply,
         socket
         |> put_flash(:info, "Thank you for subscribing!")
         |> push_navigate(to: ~p"/")}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "There was an issue subscribing. Please try again.")}
    end
  end
end
