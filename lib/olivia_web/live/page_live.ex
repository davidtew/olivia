defmodule OliviaWeb.PageLive do
  use OliviaWeb, :live_view

  import OliviaWeb.AssetHelpers, only: [resolve_asset_url: 1]

  alias Olivia.Annotations
  alias Olivia.CMS
  alias Olivia.Uploads

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
    <div :if={Phoenix.Flash.get(@flash, :info) || Phoenix.Flash.get(@flash, :error)} style="max-width: 1200px; margin: 0 auto; padding: 1rem 2rem 0;">
      <p :if={Phoenix.Flash.get(@flash, :info)} class="curator-body" style="background: var(--curator-sage); color: white; padding: 1rem 1.5rem; border-radius: 4px;">
        <%= Phoenix.Flash.get(@flash, :info) %>
      </p>
      <p :if={Phoenix.Flash.get(@flash, :error)} class="curator-body" style="background: var(--curator-coral); color: white; padding: 1rem 1.5rem; border-radius: 4px;">
        <%= Phoenix.Flash.get(@flash, :error) %>
      </p>
    </div>

    <section style="padding: 4rem 2rem 2rem; text-align: center;">
      <h1 class="curator-heading" style="font-size: 2.5rem; margin-bottom: 1rem;">
        <%= @page.title %>
      </h1>
    </section>

    <%= if @page.slug == "about" do %>
      <section style="padding: 2rem;">
        <div style="max-width: 1000px; margin: 0 auto;">
          <div class="curator-about-grid" style="display: grid; grid-template-columns: 1fr 1.5fr; gap: 3rem; align-items: start;">
            <div>
              <div class="curator-artwork-card">
                <img
                  src={resolve_asset_url("/uploads/media/1763245447_a9722ba628198afa.png")}
                  alt="Portrait of artist Olivia Tew in her studio"
                  style="width: 100%; display: block;"
                />
              </div>
            </div>

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

          <div style="margin-top: 4rem;">
            <div class="curator-artwork-card" style="max-width: 700px; margin: 0 auto;">
              <img
                src={resolve_asset_url("/uploads/media/1763542139_ff497b70635865b6.jpg")}
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
    <%= if @page.slug == "about" do %>
      <section style="background: var(--cottage-cream);">
        <div class="cottage-about-hero" style="max-width: 1200px; margin: 0 auto; display: grid; grid-template-columns: 1fr; gap: 2rem; padding: 3rem 1rem; align-items: center;">
          <style>
            @media (min-width: 768px) {
              .cottage-about-hero { grid-template-columns: 1fr 1.2fr !important; gap: 4rem !important; padding: 5rem 1rem !important; }
              .cottage-about-practice { grid-template-columns: 1.2fr 1fr !important; gap: 4rem !important; }
              .cottage-about-studio { grid-template-columns: repeat(2, 1fr) !important; }
            }
          </style>
          <div style="border: 1px solid var(--cottage-taupe); border-radius: 8px; overflow: hidden; box-shadow: 0 4px 20px rgba(200, 167, 216, 0.1);">
            <img
              src={resolve_asset_url("/uploads/media/1763542139_ff497b70635865b6.jpg")}
              alt="Olivia Tew standing beside her expressionistic figure painting in gallery setting"
              style="width: 100%; display: block;"
            />
          </div>

          <div>
            <h1 class="cottage-heading" style="font-size: 2.5rem; color: var(--cottage-text-dark); margin-bottom: 1rem;">
              About the Artist
            </h1>
            <div class="cottage-divider" style="margin: 0 0 2rem;"></div>
            <div class="cottage-body" style="color: var(--cottage-text-medium); line-height: 1.9; font-size: 1rem;">
              <p style="margin-bottom: 1.5rem;">
                Olivia Tew is a contemporary expressionist painter working primarily in oil from her cottage garden studio in Devon. Her practice spans figure studies, floral still lifes, and landscapes—all united by bold colour, gestural mark-making, and heavy impasto surfaces that give form weight and permanence.
              </p>
              <p style="margin-bottom: 1.5rem;">
                Her figure work captures moments of profound introspection—the universal experience of sitting with difficulty, of weathering change, of the body as vessel for emotional experience. The gestural brushwork refuses prettiness or idealisation; each stroke is visible, urgent, yet the cumulative effect is deeply tender.
              </p>
              <p>
                Her floral still lifes are maximalist celebrations of colour and abundance. Working with saturated grounds—coral reds, golden ochres—she creates paintings that demand attention, project outward, and perform their beauty with confidence.
              </p>
            </div>
          </div>
        </div>
      </section>

      <section style="padding: 3rem 1rem; background: white;">
        <div class="cottage-about-practice" style="max-width: 1000px; margin: 0 auto; display: grid; grid-template-columns: 1fr; gap: 2rem; align-items: center;">
          <div>
            <h2 class="cottage-heading" style="font-size: 1.75rem; color: var(--cottage-text-dark); margin-bottom: 1.5rem;">
              The Practice
            </h2>
            <div class="cottage-body" style="color: var(--cottage-text-medium); line-height: 1.9; font-size: 1rem;">
              <p style="margin-bottom: 1.5rem;">
                Her landscape works, including the SHIFTING series, present terrain in perpetual transformation. The impasto application is extraordinary in its physicality—paint applied in thick, directional strokes that mimic geological strata, creating surfaces that function almost as relief sculpture.
              </p>
              <p>
                Each painting asks us to witness without intruding. The work explores emergence and transformation—the universal experience of becoming.
              </p>
            </div>
            <div style="margin-top: 2rem; padding-top: 2rem; border-top: 1px solid var(--cottage-taupe);">
              <h3 style="font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.15em; color: var(--cottage-wisteria); margin-bottom: 0.75rem;">
                Artistic Connections
              </h3>
              <p class="cottage-body" style="font-size: 0.875rem; color: var(--cottage-text-medium);">
                Lucian Freud, Frank Auerbach, Jenny Saville, Leon Kossoff, Emil Nolde, Joan Eardley
              </p>
            </div>
          </div>
          <div style="border: 1px solid var(--cottage-taupe); border-radius: 8px; overflow: hidden; box-shadow: 0 2px 12px rgba(200, 167, 216, 0.08);">
            <img
              src={resolve_asset_url("/uploads/media/1763542139_3020310155b8abcf.jpg")}
              alt="A Becoming - Expressionist figure painting of nude torso emerging from gestural brushwork"
              style="width: 100%; display: block;"
            />
          </div>
        </div>
      </section>

      <section style="padding: 5rem 1rem; background: var(--cottage-beige);">
        <div style="max-width: 1000px; margin: 0 auto;">
          <h2 class="cottage-heading" style="font-size: 1.5rem; color: var(--cottage-text-dark); margin-bottom: 2rem;">
            Studio & Process
          </h2>
          <div class="cottage-about-studio" style="display: grid; grid-template-columns: 1fr; gap: 1.5rem;">
            <div style="border: 1px solid var(--cottage-taupe); border-radius: 8px; overflow: hidden; box-shadow: 0 2px 8px rgba(200, 167, 216, 0.08);">
              <img
                src={resolve_asset_url("/uploads/media/1763542139_ba6e66be3929fdcd.jpg")}
                alt="Works in progress on outdoor deck - nascent stage of A Becoming"
                style="width: 100%; display: block;"
              />
            </div>
            <div style="border: 1px solid var(--cottage-taupe); border-radius: 8px; overflow: hidden; box-shadow: 0 2px 8px rgba(200, 167, 216, 0.08);">
              <img
                src={resolve_asset_url("/uploads/media/1763542139_e7e47b872f6b7223.JPG")}
                alt="Marilyn in studio light showing golden warmth"
                style="width: 100%; display: block;"
              />
            </div>
          </div>
        </div>
      </section>

      <section style="padding: 5rem 1rem; background: white;">
        <div style="max-width: 500px; margin: 0 auto; text-align: center;">
          <h2 class="cottage-heading" style="font-size: 1.5rem; color: var(--cottage-text-dark); margin-bottom: 1rem;">
            Stay in Touch
          </h2>
          <p class="cottage-body" style="color: var(--cottage-text-medium); margin-bottom: 2rem;">
            Subscribe to hear about new work and exhibitions.
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
      </section>

      <div style="border-top: 1px solid var(--cottage-taupe); padding: 2rem 1rem; background: white;">
        <div style="max-width: 1200px; margin: 0 auto;">
          <a href="/" style="font-size: 0.875rem; text-transform: uppercase; letter-spacing: 0.1em; color: var(--cottage-wisteria); text-decoration: none;">
            ← Back to home
          </a>
        </div>
      </div>

    <% else %>
      <div style="max-width: 800px; margin: 0 auto; padding: 4rem 1rem;">
        <div style="text-align: center; margin-bottom: 4rem;">
          <h1 class="cottage-heading" style="font-size: 3rem; margin-bottom: 1rem; color: var(--cottage-text-dark);">
            <%= @page.title %>
          </h1>
          <div class="cottage-divider"></div>
        </div>

        <div :for={section <- @sections} style="margin-top: 3rem; first:margin-top: 0;">
          <div class="cottage-body" style="font-size: 1.125rem; line-height: 1.75; color: var(--cottage-text-medium);">
            <%= raw(Earmark.as_html!(section.content_md || "")) %>
          </div>
        </div>

        <div
          :if={@page.slug in ["collect"]}
          style="margin-top: 4rem; padding: 3rem; background: white; border: 1px solid var(--cottage-taupe); border-radius: 8px;"
        >
          <div style="text-align: center; margin-bottom: 2rem;">
            <h2 class="cottage-heading" style="font-size: 1.5rem; margin-bottom: 1rem; color: var(--cottage-text-dark);">
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
    <% end %>
    """
  end

  defp render_gallery(assigns) do
    ~H"""
    <%= if @page.slug == "about" do %>
      <section style="background: linear-gradient(to bottom, #faf8f5, #fff);">
        <div class="gallery-about-hero" style="max-width: 1200px; margin: 0 auto; display: grid; grid-template-columns: 1fr; gap: 2rem; padding: 4rem 1.5rem; align-items: center;">
          <style>
            @media (min-width: 768px) {
              .gallery-about-hero { grid-template-columns: 1fr 1.2fr !important; gap: 4rem !important; }
              .gallery-about-practice { grid-template-columns: 1.2fr 1fr !important; gap: 4rem !important; }
              .gallery-about-studio { grid-template-columns: repeat(2, 1fr) !important; }
            }
          </style>
          <div style="border: 6px solid #fff; box-shadow: 0 2px 12px rgba(44, 36, 22, 0.08);">
            <img
              src={resolve_asset_url("/uploads/media/1763245447_a9722ba628198afa.png")}
              alt="Portrait of artist Olivia Tew in her studio"
              style="width: 100%; display: block;"
            />
          </div>

          <div>
            <h1 class="gallery-heading" style="font-size: 2.5rem; color: #2c2416; margin-bottom: 1rem;">
              About the Artist
            </h1>
            <div style="width: 60px; height: 1px; background: #c4b5a0; margin-bottom: 2rem;"></div>
            <div style="color: #6b5d54; line-height: 1.9; font-size: 1rem;">
              <p style="margin-bottom: 1.5rem;">
                Olivia Tew is a contemporary expressionist painter working primarily in oil. Her practice spans figure studies, floral still lifes, and landscapes—all united by bold colour, gestural mark-making, and heavy impasto surfaces that give form weight and permanence.
              </p>
              <p style="margin-bottom: 1.5rem;">
                Her figure work captures moments of profound introspection—the universal experience of sitting with difficulty, of weathering change, of the body as vessel for emotional experience. The gestural brushwork refuses prettiness or idealisation; each stroke is visible, urgent, yet the cumulative effect is deeply tender.
              </p>
              <p>
                Her floral still lifes are maximalist celebrations of colour and abundance. Working with saturated grounds—coral reds, golden ochres—she creates paintings that demand attention, project outward, and perform their beauty with confidence.
              </p>
            </div>
          </div>
        </div>
      </section>

      <section style="padding: 5rem 1.5rem; background: #fff;">
        <div class="gallery-about-practice" style="max-width: 1000px; margin: 0 auto; display: grid; grid-template-columns: 1fr; gap: 2rem; align-items: center;">
          <div>
            <h2 class="gallery-heading" style="font-size: 1.75rem; color: #2c2416; margin-bottom: 1.5rem;">
              The Practice
            </h2>
            <div style="color: #6b5d54; line-height: 1.9; font-size: 1rem;">
              <p style="margin-bottom: 1.5rem;">
                Her landscape works, including the SHIFTING series, present terrain in perpetual transformation. The impasto application is extraordinary in its physicality—paint applied in thick, directional strokes that mimic geological strata, creating surfaces that function almost as relief sculpture.
              </p>
              <p>
                Each painting asks us to witness without intruding. The work explores emergence and transformation—the universal experience of becoming.
              </p>
            </div>
            <div style="margin-top: 2rem; padding-top: 2rem; border-top: 1px solid #e8e6e3;">
              <h3 style="font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.15em; color: #8b7355; margin-bottom: 0.75rem;">
                Artistic Connections
              </h3>
              <p style="font-size: 0.875rem; color: #6b5d54;">
                Lucian Freud, Frank Auerbach, Jenny Saville, Leon Kossoff, Emil Nolde, Joan Eardley
              </p>
            </div>
          </div>
          <div style="border: 6px solid #fff; box-shadow: 0 2px 12px rgba(44, 36, 22, 0.08);">
            <img
              src={resolve_asset_url("/uploads/media/1763542139_ff497b70635865b6.jpg")}
              alt="Olivia Tew with her expressionistic figure painting"
              style="width: 100%; display: block;"
            />
          </div>
        </div>
      </section>

      <section style="padding: 5rem 1.5rem; background: #f5f3f0;">
        <div style="max-width: 1000px; margin: 0 auto;">
          <h2 class="gallery-heading" style="font-size: 1.5rem; color: #2c2416; margin-bottom: 2rem;">
            Studio & Process
          </h2>
          <div class="gallery-about-studio" style="display: grid; grid-template-columns: 1fr; gap: 1.5rem;">
            <div style="border: 6px solid #fff; box-shadow: 0 2px 12px rgba(44, 36, 22, 0.08);">
              <img
                src={resolve_asset_url("/uploads/media/1763542139_ba6e66be3929fdcd.jpg")}
                alt="Works in progress on outdoor deck"
                style="width: 100%; display: block;"
              />
            </div>
            <div style="border: 6px solid #fff; box-shadow: 0 2px 12px rgba(44, 36, 22, 0.08);">
              <img
                src={resolve_asset_url("/uploads/media/1763542139_e7e47b872f6b7223.JPG")}
                alt="Marilyn in studio"
                style="width: 100%; display: block;"
              />
            </div>
          </div>
        </div>
      </section>

      <section style="padding: 5rem 1.5rem; background: #fff;">
        <div style="max-width: 500px; margin: 0 auto; text-align: center;">
          <h2 class="gallery-heading" style="font-size: 1.5rem; color: #2c2416; margin-bottom: 1rem;">
            Stay in Touch
          </h2>
          <p style="color: #6b5d54; margin-bottom: 2rem;">
            Subscribe to hear about new work and exhibitions.
          </p>
          <form phx-submit="subscribe" style="display: flex; gap: 0.75rem;">
            <input
              id="email-address"
              name="email"
              type="email"
              autocomplete="email"
              required
              style="flex: 1; padding: 0.75rem 1rem; border: 1px solid #c4b5a0; outline: none; font-size: 1rem; background: #faf8f5;"
              placeholder="Your email"
            />
            <button
              type="submit"
              style="padding: 0.75rem 1.5rem; background: #6b5d54; color: #faf8f5; font-size: 0.8125rem; text-transform: uppercase; letter-spacing: 0.1em; border: none; cursor: pointer; transition: background-color 0.2s;"
            >
              Subscribe
            </button>
          </form>
        </div>
      </section>

      <div style="border-top: 1px solid #e8e6e3; padding: 2rem 1.5rem;">
        <div style="max-width: 1200px; margin: 0 auto;">
          <a href="/" style="font-size: 0.8125rem; text-transform: uppercase; letter-spacing: 0.1em; color: #8b7355; text-decoration: none;">
            ← Back to home
          </a>
        </div>
      </div>

    <% else %>
      <div style="text-align: center; padding: 4rem 1.5rem; border-bottom: 1px solid #e8e6e3; background: linear-gradient(to bottom, #faf8f5, #fff);">
        <h1 class="gallery-heading" style="font-size: 2.5rem; color: #2c2416; margin-bottom: 1rem;">
          <%= @page.title %>
        </h1>
        <div style="width: 60px; height: 1px; background: #c4b5a0; margin: 0 auto;"></div>
      </div>

      <div style="max-width: 48rem; margin: 0 auto; padding: 4rem 1.5rem;">
        <div :for={section <- @sections} style="margin-top: 3rem; first:margin-top: 0;">
          <div style="color: #6b5d54; font-size: 1.125rem; line-height: 1.8;">
            <%= raw(Earmark.as_html!(section.content_md || "")) %>
          </div>
        </div>

        <div
          :if={@page.slug in ["collect"]}
          style="margin-top: 4rem; padding-top: 4rem; border-top: 1px solid #e8e6e3;"
        >
          <div style="text-align: center; margin-bottom: 2rem;">
            <h2 class="gallery-heading" style="font-size: 1.5rem; color: #2c2416; margin-bottom: 1rem;">
              Stay in Touch
            </h2>
            <p style="font-size: 1rem; color: #6b5d54;">
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
              style="flex: 1; padding: 0.75rem 1rem; border: 1px solid #c4b5a0; outline: none; font-size: 1rem; background: #faf8f5;"
              placeholder="Your email"
            />
            <button
              type="submit"
              style="padding: 0.75rem 1.5rem; background: #6b5d54; color: #faf8f5; font-size: 0.8125rem; text-transform: uppercase; letter-spacing: 0.1em; border: none; cursor: pointer; transition: background-color 0.2s;"
            >
              Subscribe
            </button>
          </form>
        </div>

        <div style="margin-top: 4rem; padding-top: 2rem; border-top: 1px solid #e8e6e3; text-align: center;">
          <a href="/" style="font-size: 0.8125rem; text-transform: uppercase; letter-spacing: 0.1em; color: #8b7355; text-decoration: none;">
            ← Back to home
          </a>
        </div>
      </div>
    <% end %>
    """
  end

  defp render_default(assigns) do
    ~H"""
    <%= if @page.slug == "hotels-designers" do %>
      <div class="bg-white">
        <div class="relative bg-gray-50">
          <div class="mx-auto max-w-7xl">
            <div class="grid lg:grid-cols-2 gap-0">
              <.annotatable
                anchor="hotels:hero:image"
                class="relative aspect-[3/4] lg:aspect-auto"
                data-anchor-meta={Jason.encode!(%{"page" => "hotels-designers", "section" => "hero"})}
              >
                <img
                  src={resolve_asset_url("/uploads/media/1763555487_35a594e71b1cb673.png")}
                  alt="Artwork visualisation in luxury Swiss hotel lounge with alpine views"
                  class="w-full h-full object-cover"
                />
              </.annotatable>
              <.annotatable
                anchor="hotels:hero:text"
                class="flex flex-col justify-center px-6 py-16 lg:px-12 lg:py-24"
                data-anchor-meta={Jason.encode!(%{"page" => "hotels-designers", "section" => "hero"})}
              >
                <h1 class="text-4xl font-bold tracking-tight text-gray-900 sm:text-5xl">
                  Hotels & Designers
                </h1>
                <div class="mt-8 space-y-6 text-gray-600 leading-7">
                  <p>
                    Olivia works with interior designers, hotels, and private collectors on commissions and art consultancy. Her paintings bring warmth, energy, and emotional depth to residential and hospitality spaces.
                  </p>
                  <p>
                    Whether you need original pieces, commissioned work, or high-quality reproductions, she can help you find the right solution for your project.
                  </p>
                </div>
              </.annotatable>
            </div>
          </div>
        </div>

        <div class="py-16 sm:py-24">
          <div class="mx-auto max-w-7xl px-6 lg:px-8">
            <div class="mx-auto max-w-3xl">
              <h2 class="text-2xl font-bold tracking-tight text-gray-900">
                What I Offer
              </h2>
              <ul class="mt-8 space-y-4 text-gray-600 leading-7">
                <li class="flex gap-x-3">
                  <span class="font-semibold text-gray-900">Original artwork</span>
                  for statement spaces and private areas
                </li>
                <li class="flex gap-x-3">
                  <span class="font-semibold text-gray-900">Commissioned pieces</span>
                  tailored to your brand and aesthetic
                </li>
                <li class="flex gap-x-3">
                  <span class="font-semibold text-gray-900">Print editions</span>
                  for multiple rooms or spaces
                </li>
                <li class="flex gap-x-3">
                  <span class="font-semibold text-gray-900">Curation support</span>
                  to ensure cohesive visual storytelling
                </li>
              </ul>
              <p class="mt-8 text-gray-600 leading-7">
                Recent projects include a 1,000-print run for a Swiss luxury hotel group and bespoke originals for London spa treatment rooms.
              </p>
            </div>
          </div>
        </div>

        <div class="bg-gray-50 py-16 sm:py-24">
          <div class="mx-auto max-w-7xl px-6 lg:px-8">
            <div class="mx-auto max-w-3xl">
              <h2 class="text-2xl font-bold tracking-tight text-gray-900">
                Visualise Before You Commit
              </h2>
              <div class="mt-6 space-y-4 text-gray-600 leading-7">
                <p>
                  To help you visualise how a piece might work in your space, we can supply a full-size poster print of any artwork for assessment purposes, provided at cost.
                </p>
                <p>
                  This allows you to experience the scale, colour relationships, and impact before committing to an original. It's particularly useful for hospitality projects where multiple stakeholders need to approve artwork selections.
                </p>
              </div>
            </div>
          </div>
        </div>

        <div class="bg-gray-900 py-16">
          <div class="mx-auto max-w-7xl px-6 lg:px-8 text-center">
            <h2 class="text-2xl font-bold text-white">
              Let's Discuss Your Project
            </h2>
            <p class="mt-4 text-gray-300 max-w-xl mx-auto">
              Get in touch to discuss your space, timeline, and vision.
            </p>
            <div class="mt-8">
              <.link
                navigate={~p"/contact"}
                class="rounded-md bg-white px-4 py-2.5 text-sm font-semibold text-gray-900 shadow-sm hover:bg-gray-100"
              >
                Start a Conversation
              </.link>
            </div>
          </div>
        </div>

        <div class="border-t border-gray-200 bg-white">
          <div class="mx-auto max-w-7xl px-6 lg:px-8 py-8">
            <.link navigate={~p"/"} class="text-sm font-semibold text-gray-900 hover:text-gray-600">
              ← Back to home
            </.link>
          </div>
        </div>
      </div>
    <% end %>
    <%= if @page.slug == "about" do %>
      <div class="bg-white">
        <div class="relative bg-gray-50">
          <div class="mx-auto max-w-7xl">
            <div class="grid lg:grid-cols-2 gap-0">
              <.annotatable
                anchor="about:hero:portrait"
                class="relative aspect-[3/4] lg:aspect-auto"
                data-anchor-meta={Jason.encode!(%{"page" => "about", "section" => "hero"})}
              >
                <img
                  src={resolve_asset_url("/uploads/media/1763245447_a9722ba628198afa.png")}
                  alt="Portrait of artist Olivia Tew in her studio"
                  class="w-full h-full object-cover object-top"
                />
              </.annotatable>
              <.annotatable
                anchor="about:hero:bio"
                class="flex flex-col justify-center px-6 py-16 lg:px-12 lg:py-24"
                data-anchor-meta={Jason.encode!(%{"page" => "about", "section" => "hero"})}
              >
                <h1 class="text-4xl font-bold tracking-tight text-gray-900 sm:text-5xl">
                  About the Artist
                </h1>
                <div class="mt-8 space-y-6 text-gray-600 leading-7">
                  <p>
                    Olivia Tew is a contemporary expressionist painter working primarily in oil. Her practice spans figure studies, floral still lifes, and landscapes—all united by bold colour, gestural mark-making, and heavy impasto surfaces that give form weight and permanence.
                  </p>
                  <p>
                    Her figure work captures moments of profound introspection—the universal experience of sitting with difficulty, of weathering change, of the body as vessel for emotional experience. The gestural brushwork refuses prettiness or idealisation; each stroke is visible, urgent, yet the cumulative effect is deeply tender.
                  </p>
                  <p>
                    Her floral still lifes are maximalist celebrations of colour and abundance. Working with saturated grounds—coral reds, golden ochres—she creates paintings that demand attention, project outward, and perform their beauty with confidence.
                  </p>
                </div>
              </.annotatable>
            </div>
          </div>
        </div>

        <div class="py-16 sm:py-24">
          <div class="mx-auto max-w-7xl px-6 lg:px-8">
            <div class="grid lg:grid-cols-2 gap-12 items-center">
              <.annotatable
                anchor="about:practice:text"
                class="order-2 lg:order-1"
                data-anchor-meta={Jason.encode!(%{"page" => "about", "section" => "practice"})}
              >
                <h2 class="text-2xl font-bold tracking-tight text-gray-900">
                  The Practice
                </h2>
                <div class="mt-6 space-y-4 text-gray-600 leading-7">
                  <p>
                    Her landscape works, including the SHIFTING series, present terrain in perpetual transformation. The impasto application is extraordinary in its physicality—paint applied in thick, directional strokes that mimic geological strata, creating surfaces that function almost as relief sculpture.
                  </p>
                  <p>
                    Each painting asks us to witness without intruding. The work explores emergence and transformation—the universal experience of becoming.
                  </p>
                </div>
                <div class="mt-8">
                  <h3 class="text-sm font-semibold text-gray-900 uppercase tracking-wide">
                    Artistic Connections
                  </h3>
                  <p class="mt-2 text-sm text-gray-500">
                    Lucian Freud, Frank Auerbach, Jenny Saville, Leon Kossoff, Emil Nolde, Joan Eardley
                  </p>
                </div>
              </.annotatable>
              <.annotatable
                anchor="about:practice:image"
                class="order-1 lg:order-2"
                data-anchor-meta={Jason.encode!(%{"page" => "about", "section" => "practice"})}
              >
                <div class="aspect-[4/3] overflow-hidden rounded-lg">
                  <img
                    src={resolve_asset_url("/uploads/media/1763542139_ff497b70635865b6.jpg")}
                    alt="Olivia Tew with her expressionistic figure painting"
                    class="w-full h-full object-cover"
                  />
                </div>
              </.annotatable>
            </div>
          </div>
        </div>

        <div class="bg-gray-50 py-16 sm:py-24">
          <div class="mx-auto max-w-7xl px-6 lg:px-8">
            <h2 class="text-2xl font-bold tracking-tight text-gray-900 mb-8">
              Studio & Process
            </h2>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
              <.annotatable
                anchor="about:studio:image-1"
                class="aspect-[4/3] overflow-hidden rounded-lg"
                data-anchor-meta={Jason.encode!(%{"page" => "about", "section" => "studio"})}
              >
                <img
                  src={resolve_asset_url("/uploads/media/1763542139_ba6e66be3929fdcd.jpg")}
                  alt="Works in progress on outdoor deck"
                  class="w-full h-full object-cover"
                />
              </.annotatable>
              <.annotatable
                anchor="about:studio:image-2"
                class="aspect-[4/3] overflow-hidden rounded-lg"
                data-anchor-meta={Jason.encode!(%{"page" => "about", "section" => "studio"})}
              >
                <img
                  src={resolve_asset_url("/uploads/media/1763542139_e7e47b872f6b7223.JPG")}
                  alt="Marilyn in studio"
                  class="w-full h-full object-cover"
                />
              </.annotatable>
            </div>
          </div>
        </div>

        <div class="py-16 sm:py-24">
          <div class="mx-auto max-w-2xl px-6 lg:px-8 text-center">
            <h2 class="text-2xl font-bold tracking-tight text-gray-900">
              Stay in Touch
            </h2>
            <p class="mt-4 text-gray-600">
              Subscribe to hear about new work and exhibitions.
            </p>
            <form
              phx-submit="subscribe"
              class="mt-8 flex max-w-md mx-auto gap-x-4"
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
        </div>

        <div class="border-t border-gray-200">
          <div class="mx-auto max-w-7xl px-6 lg:px-8 py-8">
            <.link navigate={~p"/"} class="text-sm font-semibold text-gray-900 hover:text-gray-600">
              ← Back to home
            </.link>
          </div>
        </div>
      </div>
    <% end %>
    <%= if @page.slug not in ["hotels-designers", "about"] do %>
      <div class="bg-white px-6 py-24 sm:py-32 lg:px-8">
        <div class="mx-auto max-w-3xl text-base leading-7 text-gray-700">
          <.annotatable
            anchor={"#{@page.slug}:header"}
            data-anchor-meta={Jason.encode!(%{"page" => @page.slug, "section" => "header"})}
          >
            <h1 class="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl mb-8">
              <%= @page.title %>
            </h1>
          </.annotatable>
          <div :for={{section, index} <- Enum.with_index(@sections)} class="mt-10 first:mt-0">
            <.annotatable
              anchor={"#{@page.slug}:section:#{index}"}
              class="prose prose-lg prose-gray max-w-none"
              data-anchor-meta={Jason.encode!(%{"page" => @page.slug, "section" => "content", "index" => index})}
            >
              <%= raw(Earmark.as_html!(section.content_md || "")) %>
            </.annotatable>
          </div>

          <div
            :if={@page.slug in ["collect"]}
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

          <div class="mt-16 border-t border-gray-200 pt-8">
            <.link navigate={~p"/"} class="text-sm font-semibold text-gray-900">
              ← Back to home
            </.link>
          </div>
        </div>
      </div>
    <% end %>

    <%= if @annotations_enabled do %>
      <div id="annotation-recorder-container">
        <form id="annotation-upload-form" phx-change="noop" phx-submit="noop" phx-hook="AudioAnnotation">
          <.live_file_input upload={@uploads.audio} id="annotation-audio-input" class="hidden" />
        </form>
      </div>
    <% end %>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    theme = socket.assigns[:theme]
    annotations_enabled = theme == "reviewer"

    socket =
      socket
      |> assign(:annotations_enabled, annotations_enabled)

    # Add annotation support when enabled
    socket = if annotations_enabled do
      socket
      |> assign(:annotation_mode, false)
      |> assign(:current_anchor, nil)
      |> assign(:page_path, "/about")  # Will be updated in handle_params
      |> assign(:existing_notes, [])
      |> allow_upload(:audio,
        accept: ~w(audio/*),
        max_entries: 1,
        max_file_size: 50_000_000
      )
    else
      socket
    end

    {:ok, socket}
  end

  @impl true
  def handle_params(_params, uri, socket) do
    slug = slug_from_uri(uri)
    page = CMS.get_page_by_slug!(slug, preload: [:sections])
    sections = Enum.sort_by(page.sections, & &1.position)

    path = URI.parse(uri).path

    socket =
      socket
      |> assign(:page_title, "#{page.title} - Olivia Tew")
      |> assign(:page, page)
      |> assign(:sections, sections)

    # Update page_path and load notes for reviewer theme
    socket = if socket.assigns[:annotations_enabled] do
      existing_notes = Annotations.list_voice_notes(path, "reviewer")

      socket
      |> assign(:page_path, path)
      |> assign(:existing_notes, existing_notes)
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

    {:noreply, socket}
  end

  defp slug_from_uri(uri) do
    path = URI.parse(uri).path

    case path do
      "/about" -> "about"
      "/collect" -> "collect"
      "/hotels-designers" -> "hotels-designers"
      "/press-projects" -> "press-projects"
      # Archived pages
      "/archive/collect" -> "collect"
      "/archive/hotels-designers" -> "hotels-designers"
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

  # Annotation event handlers

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
    anchor = socket.assigns.current_anchor

    if !anchor do
      {:noreply, put_flash(socket, :error, "No annotation target selected")}
    else
      case Base.decode64(blob_data) do
        {:ok, binary_data} ->
          # Write to temp file first (same as SeriesLive.Show)
          temp_path = Path.join(System.tmp_dir!(), filename)

          case File.write(temp_path, binary_data) do
            :ok ->
              # Generate proper S3 key with path prefix
              clean_filename = Uploads.generate_filename(filename)
              key = "voice_notes/#{clean_filename}"

              case Uploads.upload_file(temp_path, key, mime_type) do
                {:ok, url} ->
                  # Clean up temp file
                  File.rm(temp_path)

                  case Annotations.create_voice_note(%{
                    audio_url: url,
                    anchor_key: anchor.key,
                    anchor_meta: anchor.meta,
                    page_path: socket.assigns.page_path,
                    theme: "reviewer"
                  }) do
                    {:ok, voice_note} ->
                      {:noreply,
                       socket
                       |> put_flash(:info, "Annotation saved successfully")
                       |> assign(:current_anchor, nil)
                       |> push_event("note_created", %{
                         id: voice_note.id,
                         anchor_key: voice_note.anchor_key,
                         audio_url: voice_note.audio_url
                       })}

                    {:error, _changeset} ->
                      {:noreply, put_flash(socket, :error, "Failed to save annotation")}
                  end

                {:error, _reason} ->
                  File.rm(temp_path)
                  {:noreply, put_flash(socket, :error, "Failed to upload audio")}
              end

            {:error, _reason} ->
              {:noreply, put_flash(socket, :error, "Failed to write temp file")}
          end

        :error ->
          {:noreply, put_flash(socket, :error, "Invalid audio data")}
      end
    end
  end

  @impl true
  def handle_event("delete_annotation", %{"id" => id}, socket) do
    voice_note = Annotations.get_voice_note!(id)

    case Annotations.delete_voice_note(voice_note) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Annotation deleted")
         |> push_event("annotation_deleted", %{id: id})}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to delete annotation")}
    end
  end
end
