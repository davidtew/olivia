defmodule OliviaWeb.PageLive do
  use OliviaWeb, :live_view

  alias Olivia.CMS

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
    <div :if={Phoenix.Flash.get(@flash, :info) || Phoenix.Flash.get(@flash, :error)} style="max-width: 1200px; margin: 0 auto; padding: 1rem 2rem 0;">
      <p :if={Phoenix.Flash.get(@flash, :info)} class="curator-body" style="background: var(--curator-sage); color: white; padding: 1rem 1.5rem; border-radius: 4px;">
        <%= Phoenix.Flash.get(@flash, :info) %>
      </p>
      <p :if={Phoenix.Flash.get(@flash, :error)} class="curator-body" style="background: var(--curator-coral); color: white; padding: 1rem 1.5rem; border-radius: 4px;">
        <%= Phoenix.Flash.get(@flash, :error) %>
      </p>
    </div>

    <!-- Page Header -->
    <section style="padding: 4rem 2rem 2rem; text-align: center;">
      <h1 class="curator-heading" style="font-size: 2.5rem; margin-bottom: 1rem;">
        <%= @page.title %>
      </h1>
    </section>

    <!-- About Page Special Layout -->
    <%= if @page.slug == "about" do %>
      <section style="padding: 2rem;">
        <div style="max-width: 1000px; margin: 0 auto;">
          <!-- Artist Portrait and Bio -->
          <div class="curator-about-grid" style="display: grid; grid-template-columns: 1fr 1.5fr; gap: 3rem; align-items: start;">
            <div>
              <div class="curator-artwork-card">
                <img
                  src="/uploads/media/1763245447_a9722ba628198afa.png"
                  alt="Portrait of artist Olivia Tew in her studio"
                  style="width: 100%; display: block;"
                />
              </div>
            </div>

            <!-- Bio Content -->
            <div>
              <div class="curator-body" style="font-size: 1rem; line-height: 1.8; color: var(--curator-text-light);">
                <p style="margin-bottom: 1.5rem;">
                  Olivia Tew is a contemporary expressionist painter working primarily in oil. Her practice spans figure studies, floral still lifes, and landscapes—all united by bold colour, gestural mark-making, and heavy impasto surfaces that give form weight and permanence.
                </p>
                <p style="margin-bottom: 1.5rem;">
                  Her figure work captures moments of profound introspection—the universal experience of sitting with difficulty, of weathering change, of the body as vessel for emotional experience. The gestural brushwork refuses prettiness or idealisation; each stroke is visible, urgent, yet the cumulative effect is deeply tender.
                </p>
                <p style="margin-bottom: 1.5rem;">
                  Her floral still lifes are maximalist celebrations of colour and abundance. Working with saturated grounds—coral reds, golden ochres—she creates paintings that demand attention, project outward, and perform their beauty with confidence. Both natural and constructed, genuine and glamorous.
                </p>
                <p>
                  Her landscape works, including the SHIFTING series, present terrain in perpetual transformation. The impasto application is extraordinary in its physicality—paint applied in thick, directional strokes that mimic geological strata, creating surfaces that function almost as relief sculpture.
                </p>
              </div>

              <!-- Artistic Connections -->
              <div style="margin-top: 3rem; padding-top: 2rem; border-top: 1px solid rgba(245, 242, 237, 0.1);">
                <h3 style="font-size: 0.6875rem; text-transform: uppercase; letter-spacing: 0.15em; color: var(--curator-text-muted); margin-bottom: 1rem;">
                  Artistic Connections
                </h3>
                <p class="curator-body" style="font-size: 0.875rem; color: var(--curator-text-muted);">
                  Lucian Freud, Frank Auerbach, Jenny Saville, Leon Kossoff, Emil Nolde, Joan Eardley
                </p>
              </div>
            </div>
          </div>

          <!-- Gallery Shot - Artist with Work -->
          <div style="margin-top: 4rem;">
            <div class="curator-artwork-card" style="max-width: 700px; margin: 0 auto;">
              <img
                src="/uploads/media/1763542139_ff497b70635865b6.jpg"
                alt="Olivia Tew with her expressionistic figure painting in gallery setting"
                style="width: 100%; display: block;"
              />
            </div>
            <p class="curator-body" style="font-size: 0.8125rem; color: var(--curator-text-muted); margin-top: 1rem; text-align: center;">
              The artist with her work in situ
            </p>
          </div>
        </div>
      </section>
    <% else %>
      <!-- Generic page content -->
      <section style="padding: 2rem;">
        <div style="max-width: 700px; margin: 0 auto;">
          <div :for={section <- @sections} style="margin-bottom: 2rem;">
            <div class="curator-body" style="font-size: 1rem; line-height: 1.8; color: var(--curator-text-light);">
              <%= raw(Earmark.as_html!(section.content_md || "")) %>
            </div>
          </div>
        </div>
      </section>
    <% end %>

    <!-- Contact CTA -->
    <section style="padding: 4rem 2rem; background: var(--curator-bg-warm); text-align: center; margin-top: 3rem;">
      <div style="max-width: 500px; margin: 0 auto;">
        <h3 class="curator-heading" style="font-size: 1.5rem; margin-bottom: 1rem;">
          Get in Touch
        </h3>
        <p class="curator-body" style="color: var(--curator-text-muted); margin-bottom: 2rem;">
          For collector enquiries, exhibition proposals, or commissions.
        </p>
        <a href="/contact" class="curator-button curator-button-primary">
          Contact
        </a>
      </div>
    </section>
    """
  end

  defp render_cottage(assigns) do
    ~H"""
    <div style="max-width: 800px; margin: 0 auto; padding: 4rem 1rem;">
      <div style="text-align: center; margin-bottom: 4rem;">
        <h1 class="cottage-heading" style="font-size: 3rem; margin-bottom: 1rem;">
          <%= @page.title %>
        </h1>
      </div>

      <div :for={section <- @sections} style="margin-top: 3rem; first:margin-top: 0;">
        <div class="cottage-body" style="font-size: 1.125rem; line-height: 1.75;">
          <%= raw(Earmark.as_html!(section.content_md || "")) %>
        </div>
      </div>

      <div
        :if={@page.slug in ["about", "collect"]}
        style="margin-top: 4rem; padding: 3rem; background: white; border: 1px solid var(--cottage-taupe); border-radius: 8px;"
      >
        <div style="text-align: center; margin-bottom: 2rem;">
          <h2 class="cottage-heading" style="font-size: 1.5rem; margin-bottom: 1rem;">
            Stay in Touch
          </h2>
          <p class="cottage-body" style="color: var(--cottage-text-medium);">
            Subscribe to hear about new work and exhibitions.
          </p>
        </div>
        <form
          phx-submit="subscribe"
          style="max-width: 28rem; margin: 0 auto; display: flex; flex-direction: column; gap: 0.75rem;"
        >
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

      <div style="margin-top: 4rem; padding-top: 2rem; border-top: 1px solid var(--cottage-taupe); text-align: center;">
        <.link
          navigate={~p"/"}
          class="cottage-body"
          style="font-size: 0.875rem; text-transform: uppercase; letter-spacing: 0.05em; color: var(--cottage-wisteria); text-decoration: none; border-bottom: 1px solid var(--cottage-wisteria); padding-bottom: 0.25rem;"
        >
          ← Back to home
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
        <%= @page.title %>
      </h1>
    </div>

    <!-- Page Content -->
    <div style="max-width: 48rem; margin: 0 auto; padding: 4rem 1.5rem;">
      <div :for={section <- @sections} style="margin-top: 3rem; first:margin-top: 0;">
        <div style="color: #4a4034; font-size: 1.125rem; line-height: 1.75;">
          <%= raw(Earmark.as_html!(section.content_md || "")) %>
        </div>
      </div>

      <!-- Newsletter signup for specific pages -->
      <div
        :if={@page.slug in ["about", "collect"]}
        style="margin-top: 4rem; padding-top: 4rem; border-top: 1px solid #e8e6e3;"
      >
        <div style="text-align: center; margin-bottom: 2rem;">
          <h2 class="gallery-heading" style="font-size: 2rem; color: #2c2416; margin-bottom: 1rem;">
            Stay in Touch
          </h2>
          <p class="gallery-script" style="font-size: 1.125rem; color: #6b5d54;">
            Subscribe to hear about new work and exhibitions.
          </p>
        </div>
        <form
          phx-submit="subscribe"
          style="max-width: 28rem; margin: 0 auto; display: flex; gap: 0.75rem;"
        >
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

      <!-- Back to home -->
      <div style="margin-top: 4rem; padding-top: 2rem; border-top: 1px solid #e8e6e3; text-align: center;">
        <.link navigate={~p"/"} style="font-size: 0.875rem; text-transform: uppercase; letter-spacing: 0.05em; color: #8b7355; text-decoration: none; border-bottom: 1px solid #c4b5a0; padding-bottom: 0.25rem;">
          ← Back to home
        </.link>
      </div>
    </div>
    """
  end

  defp render_default(assigns) do
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
