defmodule OliviaWeb.HomeLive do
  use OliviaWeb, :live_view

  alias Olivia.CMS
  alias Olivia.Content

  @impl true
  def render(assigns) do
    cond do
      assigns[:theme] == "curator" -> render_curator(assigns)
      assigns[:theme] == "cottage" -> render_cottage(assigns)
      assigns[:theme] == "gallery" -> render_gallery(assigns)
      true -> render_default(assigns)
    end
  end

  defp render_curator(assigns) do
    ~H"""
    <!-- Flash Messages -->
    <div :if={Phoenix.Flash.get(@flash, :info) || Phoenix.Flash.get(@flash, :error)} style="max-width: 1200px; margin: 0 auto; padding: 1rem 2rem;">
      <p :if={Phoenix.Flash.get(@flash, :info)} class="curator-body" style="background: var(--curator-sage); color: white; padding: 1rem 1.5rem; border-radius: 4px;">
        <%= Phoenix.Flash.get(@flash, :info) %>
      </p>
      <p :if={Phoenix.Flash.get(@flash, :error)} class="curator-body" style="background: var(--curator-coral); color: white; padding: 1rem 1.5rem; border-radius: 4px;">
        <%= Phoenix.Flash.get(@flash, :error) %>
      </p>
    </div>

    <!-- Hero Section - A BECOMING -->
    <section style="min-height: 100vh; display: flex; flex-direction: column; justify-content: center; align-items: center; position: relative; padding: 2rem;">
      <!-- Hero Image -->
      <div style="max-width: 600px; width: 100%; margin-bottom: 3rem;">
        <img
          src="/uploads/media/1763542139_3020310155b8abcf.jpg"
          alt="A BECOMING - Expressionist figure painting of nude torso emerging from gestural brushwork"
          style="width: 100%; height: auto; display: block;"
        />
      </div>

      <!-- Hero Text -->
      <div style="text-align: center; max-width: 600px;">
        <h1 class="curator-heading-italic" style="font-size: 3rem; margin-bottom: 1rem; color: var(--curator-text-light);">
          A Becoming
        </h1>
        <p class="curator-body" style="font-size: 1.125rem; color: var(--curator-text-muted); line-height: 1.8; margin-bottom: 2rem;">
          Contemporary expressionist work exploring transformation, vulnerability, and the emergence of form from paint itself.
        </p>
        <a href="/work" class="curator-button">
          Enter Gallery
        </a>
      </div>

      <!-- Scroll Indicator -->
      <div style="position: absolute; bottom: 2rem; left: 50%; transform: translateX(-50%); opacity: 0.5;">
        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1">
          <path d="M12 5v14M19 12l-7 7-7-7"/>
        </svg>
      </div>
    </section>

    <!-- Preview Triptych -->
    <section style="padding: 6rem 2rem; background: var(--curator-bg-warm);">
      <div style="max-width: 1200px; margin: 0 auto;">
        <div style="text-align: center; margin-bottom: 4rem;">
          <h2 class="curator-heading" style="font-size: 2rem; margin-bottom: 1rem;">
            The Collection
          </h2>
          <div class="curator-divider"></div>
        </div>

        <!-- Three Collection Previews -->
        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 2rem;">
          <!-- Becoming (Figures) -->
          <a href="/work#becoming" style="text-decoration: none; display: block;">
            <div class="curator-artwork-card" style="margin-bottom: 1.5rem;">
              <img
                src="/uploads/media/1763542139_22309219aa56fb95.jpg"
                alt="Changes - expressionistic figure study"
                style="width: 100%; aspect-ratio: 4/5; object-fit: cover; display: block;"
              />
            </div>
            <h3 class="curator-heading" style="font-size: 1.25rem; color: var(--curator-text-light); margin-bottom: 0.5rem;">
              Becoming
            </h3>
            <p class="curator-body" style="font-size: 0.875rem; color: var(--curator-text-muted);">
              Figure works exploring emergence and transformation
            </p>
          </a>

          <!-- Abundance (Florals) -->
          <a href="/work#abundance" style="text-decoration: none; display: block;">
            <div class="curator-artwork-card" style="margin-bottom: 1.5rem;">
              <img
                src="/uploads/media/1763542139_f6add8cef5e11b3a.jpg"
                alt="Ecstatic - floral still life in Georgian setting"
                style="width: 100%; aspect-ratio: 4/5; object-fit: cover; display: block;"
              />
            </div>
            <h3 class="curator-heading" style="font-size: 1.25rem; color: var(--curator-text-light); margin-bottom: 0.5rem;">
              Abundance
            </h3>
            <p class="curator-body" style="font-size: 0.875rem; color: var(--curator-text-muted);">
              Floral celebrations of colour and joy
            </p>
          </a>

          <!-- Shifting (Landscapes) -->
          <a href="/work#shifting" style="text-decoration: none; display: block;">
            <div class="curator-artwork-card" style="margin-bottom: 1.5rem;">
              <img
                src="/uploads/media/1763483281_14d2d6ab6485926c.jpg"
                alt="SHIFTING - expressionist landscape diptych"
                style="width: 100%; aspect-ratio: 4/5; object-fit: cover; display: block;"
              />
            </div>
            <h3 class="curator-heading" style="font-size: 1.25rem; color: var(--curator-text-light); margin-bottom: 0.5rem;">
              Shifting
            </h3>
            <p class="curator-body" style="font-size: 0.875rem; color: var(--curator-text-muted);">
              Landscapes in perpetual transformation
            </p>
          </a>
        </div>
      </div>
    </section>

    <!-- Artist Statement -->
    <section style="padding: 6rem 2rem;">
      <div style="max-width: 700px; margin: 0 auto; text-align: center;">
        <blockquote class="curator-heading-italic" style="font-size: 1.5rem; line-height: 1.6; color: var(--curator-text-light); margin-bottom: 2rem;">
          "Each painting asks us to witness without intruding—the universal experience of weathering change, of the body as vessel for emotional experience."
        </blockquote>
        <div class="curator-divider"></div>
        <p class="curator-body" style="margin-top: 2rem; color: var(--curator-text-muted);">
          Olivia Tew works in oil, building surfaces through heavy impasto that gives form weight and permanence. Her practice spans figure studies, floral still lifes, and expressionistic landscapes—all united by bold colour, gestural mark-making, and an unflinching approach to emotional truth.
        </p>
        <div style="margin-top: 2rem;">
          <a href="/about" class="curator-button">
            About the Artist
          </a>
        </div>
      </div>
    </section>

    <!-- Contact CTA -->
    <section style="padding: 4rem 2rem; background: var(--curator-bg-warm); text-align: center;">
      <div style="max-width: 500px; margin: 0 auto;">
        <h3 class="curator-heading" style="font-size: 1.5rem; margin-bottom: 1rem;">
          Enquire About Work
        </h3>
        <p class="curator-body" style="color: var(--curator-text-muted); margin-bottom: 2rem;">
          For collector enquiries, exhibition proposals, or commission discussions.
        </p>
        <a href="/contact" class="curator-button curator-button-primary">
          Get in Touch
        </a>
      </div>
    </section>
    """
  end

  defp render_cottage(assigns) do
    ~H"""
    <div style="max-width: 1200px; margin: 0 auto; padding: 4rem 1rem;">
      <div style="text-align: center; margin-bottom: 4rem;">
        <h1 class="cottage-heading" style="font-size: 3rem; margin-bottom: 1rem;">
          <%= @sections["hero_title"] %>
        </h1>
        <p class="cottage-body" style="font-size: 1.25rem; color: var(--cottage-text-medium); max-width: 42rem; margin: 0 auto;">
          <%= @sections["hero_subtitle"] %>
        </p>
      </div>

      <div style="max-width: 48rem; margin: 0 auto 4rem;">
        <div class="cottage-body" style="text-align: center; font-size: 1.125rem; line-height: 1.75;">
          <%= raw(Earmark.as_html!(@sections["intro"] || "")) %>
        </div>
      </div>

      <div :if={length(@featured_artworks) > 0} style="margin-top: 4rem;">
        <h2 class="cottage-heading" style="font-size: 2rem; text-align: center; margin-bottom: 3rem;">
          Featured Works
        </h2>
        <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 2rem;">
          <article :for={artwork <- @featured_artworks} style="border: 1px solid var(--cottage-taupe); border-radius: 8px; overflow: hidden; box-shadow: 0 2px 8px rgba(200, 167, 216, 0.08); transition: box-shadow 0.3s ease;">
            <.link navigate={~p"/artworks/#{artwork.slug}"} style="display: block; text-decoration: none;">
              <div :if={artwork.image_url} style="overflow: hidden;">
                <.artwork_image
                  src={artwork.image_url}
                  alt={artwork.title}
                  aspect="aspect-[4/5]"
                  style="width: 100%; display: block; transition: transform 0.3s ease;"
                  sizes="(max-width: 768px) 100vw, 33vw"
                />
              </div>
              <div
                :if={!artwork.image_url}
                style="aspect-ratio: 4/5; background: var(--cottage-beige); display: flex; align-items: center; justify-content: center;"
              >
                <span class="cottage-body" style="font-size: 0.875rem; color: var(--cottage-text-light);">No image</span>
              </div>
            </.link>
            <div style="padding: 1.5rem; background: white;">
              <h3 class="cottage-heading" style="font-size: 1.25rem; margin-bottom: 0.5rem;">
                <.link navigate={~p"/artworks/#{artwork.slug}"} style="text-decoration: none; color: inherit;">
                  <%= artwork.title %>
                </.link>
              </h3>
              <p class="cottage-body" style="font-size: 0.875rem; color: var(--cottage-text-medium); margin: 0;">
                <%= artwork.year %> · <%= artwork.medium %>
              </p>
              <p :if={artwork.series} class="cottage-body" style="font-size: 0.875rem; color: var(--cottage-text-light); margin-top: 0.25rem;">
                <%= artwork.series.title %>
              </p>
            </div>
          </article>
        </div>
        <div style="text-align: center; margin-top: 3rem;">
          <.link
            navigate={~p"/series"}
            class="cottage-button"
            style="display: inline-block; padding: 0.75rem 2rem; text-decoration: none;"
          >
            View All Collections
          </.link>
        </div>
      </div>

      <div style="margin-top: 6rem; padding: 3rem; background: white; border: 1px solid var(--cottage-taupe); border-radius: 8px;">
        <div style="max-width: 36rem; margin: 0 auto; text-align: center;">
          <h2 class="cottage-heading" style="font-size: 1.5rem; margin-bottom: 1rem;">
            Stay Updated
          </h2>
          <p class="cottage-body" style="color: var(--cottage-text-medium); margin-bottom: 1.5rem;">
            <%= @sections["newsletter_blurb"] %>
          </p>
          <form phx-submit="subscribe" style="display: flex; gap: 0.75rem; flex-direction: column;">
            <input
              id="email-address"
              name="email"
              type="email"
              autocomplete="email"
              required
              style="padding: 0.75rem 1rem; border: 1px solid var(--cottage-taupe); border-radius: 6px; outline: none; font-family: 'Montserrat', sans-serif; font-size: 1rem; background: var(--cottage-cream);"
              placeholder="Your email"
            />
            <button
              type="submit"
              class="cottage-button"
              style="padding: 0.75rem 1.5rem; width: 100%;"
            >
              Subscribe
            </button>
          </form>
        </div>
      </div>
    </div>
    """
  end

  defp render_gallery(assigns) do
    ~H"""
    <!-- Gallery-styled Hero -->
    <div style="text-align: center; padding: 4rem 1.5rem; border-bottom: 1px solid #e8e6e3;">
      <h1 class="gallery-heading" style="font-size: 3rem; color: #2c2416; margin-bottom: 1rem;">
        <%= @sections["hero_title"] %>
      </h1>
      <p class="gallery-script" style="font-size: 1.25rem; color: #6b5d54; max-width: 42rem; margin: 0 auto;">
        <%= @sections["hero_subtitle"] %>
      </p>
    </div>

    <!-- Intro Section -->
    <div style="max-width: 48rem; margin: 0 auto; padding: 3rem 1.5rem;">
      <div style="color: #4a4034; text-align: center; font-size: 1.125rem; line-height: 1.75;">
        <%= raw(Earmark.as_html!(@sections["intro"] || "")) %>
      </div>
    </div>

    <!-- Featured Artworks -->
    <div :if={length(@featured_artworks) > 0} style="padding: 4rem 1.5rem; border-top: 1px solid #e8e6e3;">
      <h2 class="gallery-heading" style="font-size: 2rem; color: #2c2416; text-align: center; margin-bottom: 3rem;">
        Featured Works
      </h2>
      <div style="display: grid; grid-template-columns: 1fr; gap: 3rem; max-width: 80rem; margin: 0 auto;">
        <article :for={artwork <- @featured_artworks} class="artwork-card" style="display: block;">
          <.link navigate={~p"/artworks/#{artwork.slug}"} style="display: block; text-decoration: none;">
            <div :if={artwork.image_url} class="elegant-border" style="overflow: hidden; margin-bottom: 1rem;">
              <.artwork_image
                src={artwork.image_url}
                alt={artwork.title}
                aspect="aspect-[4/5]"
                style="width: 100%; display: block;"
                sizes="(max-width: 768px) 100vw, 50vw"
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
            <h3 class="gallery-heading" style="font-size: 1.25rem; color: #2c2416; margin-bottom: 0.5rem;">
              <.link navigate={~p"/artworks/#{artwork.slug}"} style="text-decoration: none; color: inherit;">
                <%= artwork.title %>
              </.link>
            </h3>
            <p style="font-size: 0.875rem; color: #6b5d54; margin: 0;">
              <%= artwork.year %> · <%= artwork.medium %>
            </p>
            <p :if={artwork.series} style="font-size: 0.875rem; color: #9a8a7a; margin-top: 0.25rem;">
              <%= artwork.series.title %>
            </p>
          </div>
        </article>
      </div>
      <div style="text-align: center; margin-top: 3rem;">
        <.link
          navigate={~p"/series"}
          style="display: inline-block; padding: 0.5rem 1.5rem; border: 1px solid #c4b5a0; font-size: 0.875rem; text-transform: uppercase; letter-spacing: 0.05em; text-decoration: none; color: #6b5d54; transition: all 0.2s; background: transparent;"
        >
          View All Collections
        </.link>
      </div>
    </div>

    <!-- Newsletter -->
    <div style="padding: 4rem 1.5rem; margin-top: 4rem; background: #ffffff; border-top: 1px solid #e8e6e3;">
      <div style="max-width: 36rem; margin: 0 auto; text-align: center;">
        <h2 class="gallery-heading" style="font-size: 1.5rem; color: #2c2416; margin-bottom: 1rem;">Stay Updated</h2>
        <p style="color: #6b5d54; margin-bottom: 1.5rem;">
          <%= @sections["newsletter_blurb"] %>
        </p>
        <form phx-submit="subscribe" style="display: flex; gap: 0.75rem;">
          <input
            id="email-address"
            name="email"
            type="email"
            autocomplete="email"
            required
            style="flex: 1; padding: 0.5rem 1rem; border: 1px solid #c4b5a0; outline: none; font-size: 1rem; background: #faf8f5;"
            placeholder="Your email"
          />
          <button
            type="submit"
            style="padding: 0.5rem 1.5rem; background: #6b5d54; color: #faf8f5; font-size: 0.875rem; text-transform: uppercase; letter-spacing: 0.05em; border: none; cursor: pointer; transition: background-color 0.2s;"
          >
            Subscribe
          </button>
        </form>
      </div>
    </div>
    """
  end

  defp render_default(assigns) do
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
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
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
