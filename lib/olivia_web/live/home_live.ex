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
    <!-- Hero Section -->
    <section style="min-height: 90vh; display: flex; flex-direction: column; justify-content: center; align-items: center; padding: 4rem 1rem; background: var(--cottage-cream);">
      <!-- Hero Artwork - Marilyn in garden light -->
      <div style="max-width: 500px; width: 100%; margin-bottom: 3rem;">
        <div style="border: 1px solid var(--cottage-taupe); border-radius: 8px; overflow: hidden; box-shadow: 0 4px 20px rgba(200, 167, 216, 0.12);">
          <img
            src="/uploads/media/1763542139_1225c3b883e0ce02.jpg"
            alt="Marilyn - Vibrant floral painting with white daffodils and blue hydrangea against golden ochre ground"
            style="width: 100%; height: auto; display: block;"
          />
        </div>
      </div>

      <!-- Hero Text -->
      <div style="text-align: center; max-width: 600px;">
        <h1 class="cottage-heading" style="font-size: 3rem; margin-bottom: 0.5rem; color: var(--cottage-text-dark);">
          Olivia Tew
        </h1>
        <p class="cottage-accent" style="font-size: 1.125rem; color: var(--cottage-wisteria); margin-bottom: 2rem;">
          Romantic. Expressive. Uplifting.
        </p>
        <p class="cottage-body" style="font-size: 1.125rem; color: var(--cottage-text-medium); line-height: 1.8; margin-bottom: 2rem;">
          Oil paintings from a cottage garden studio in Devon. Bold colour, gestural mark-making, and heavy impasto surfaces that celebrate the beauty found in transformation.
        </p>
        <a href="/work" class="cottage-button" style="display: inline-block; padding: 0.875rem 2.5rem;">
          View the Collection
        </a>
      </div>
    </section>

    <!-- Three Bodies of Work -->
    <section style="padding: 6rem 1rem; background: white;">
      <div style="max-width: 1200px; margin: 0 auto;">
        <div style="text-align: center; margin-bottom: 4rem;">
          <h2 class="cottage-heading" style="font-size: 2rem; margin-bottom: 1rem; color: var(--cottage-text-dark);">
            The Collection
          </h2>
          <div class="cottage-divider"></div>
        </div>

        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 2rem;">
          <!-- Becoming - Figures -->
          <a href="/work#becoming" style="text-decoration: none; display: block;">
            <div style="border: 1px solid var(--cottage-taupe); border-radius: 8px; overflow: hidden; margin-bottom: 1.5rem; box-shadow: 0 2px 8px rgba(200, 167, 216, 0.08); transition: box-shadow 0.3s ease;">
              <img
                src="/uploads/media/1763542139_22309219aa56fb95.jpg"
                alt="Changes - expressionistic figure study of seated nude in blue"
                style="width: 100%; aspect-ratio: 4/5; object-fit: cover; display: block;"
              />
            </div>
            <h3 class="cottage-heading" style="font-size: 1.25rem; color: var(--cottage-text-dark); margin-bottom: 0.5rem;">
              Becoming
            </h3>
            <p class="cottage-accent" style="font-size: 0.875rem; color: var(--cottage-text-medium);">
              Figure works exploring emergence and transformation
            </p>
          </a>

          <!-- Abundance - Florals -->
          <a href="/work#abundance" style="text-decoration: none; display: block;">
            <div style="border: 1px solid var(--cottage-taupe); border-radius: 8px; overflow: hidden; margin-bottom: 1.5rem; box-shadow: 0 2px 8px rgba(200, 167, 216, 0.08); transition: box-shadow 0.3s ease;">
              <img
                src="/uploads/media/1763483281_62762e1c677b1d02.jpg"
                alt="Floral still life with abundant mixed flowers in patterned vase against coral-red ground"
                style="width: 100%; aspect-ratio: 4/5; object-fit: cover; display: block;"
              />
            </div>
            <h3 class="cottage-heading" style="font-size: 1.25rem; color: var(--cottage-text-dark); margin-bottom: 0.5rem;">
              Abundance
            </h3>
            <p class="cottage-accent" style="font-size: 0.875rem; color: var(--cottage-text-medium);">
              Floral celebrations of colour and joy
            </p>
          </a>

          <!-- Shifting - Landscapes -->
          <a href="/work#shifting" style="text-decoration: none; display: block;">
            <div style="border: 1px solid var(--cottage-taupe); border-radius: 8px; overflow: hidden; margin-bottom: 1.5rem; box-shadow: 0 2px 8px rgba(200, 167, 216, 0.08); transition: box-shadow 0.3s ease;">
              <img
                src="/uploads/media/1763483281_ebd1913da6ebeabd.jpg"
                alt="Shifting Part 1 - expressionist landscape with pink wall and dense garden vegetation"
                style="width: 100%; aspect-ratio: 4/5; object-fit: cover; display: block;"
              />
            </div>
            <h3 class="cottage-heading" style="font-size: 1.25rem; color: var(--cottage-text-dark); margin-bottom: 0.5rem;">
              Shifting
            </h3>
            <p class="cottage-accent" style="font-size: 0.875rem; color: var(--cottage-text-medium);">
              Landscapes in perpetual transformation
            </p>
          </a>
        </div>
      </div>
    </section>

    <!-- Artist Statement Quote -->
    <section style="padding: 5rem 1rem; background: var(--cottage-beige);">
      <div style="max-width: 700px; margin: 0 auto; text-align: center;">
        <blockquote class="cottage-accent" style="font-size: 1.5rem; line-height: 1.6; color: var(--cottage-text-dark); margin-bottom: 2rem;">
          "Each painting asks us to witness without intruding—the universal experience of weathering change, of the body as vessel for emotional experience."
        </blockquote>
        <div class="cottage-divider"></div>
        <p class="cottage-body" style="margin-top: 2rem; color: var(--cottage-text-medium); line-height: 1.8;">
          Working in oil, Olivia builds surfaces through heavy impasto that gives form weight and permanence. Her gestural brushwork refuses prettiness—each stroke visible, urgent, yet the cumulative effect is deeply tender.
        </p>
        <div style="margin-top: 2rem;">
          <a href="/about" style="font-size: 0.875rem; text-transform: uppercase; letter-spacing: 0.1em; color: var(--cottage-wisteria); text-decoration: none; border-bottom: 1px solid var(--cottage-wisteria); padding-bottom: 0.25rem;">
            About the Artist
          </a>
        </div>
      </div>
    </section>

    <!-- Selected Works Grid -->
    <section style="padding: 6rem 1rem; background: white;">
      <div style="max-width: 1200px; margin: 0 auto;">
        <h2 class="cottage-heading" style="font-size: 1.5rem; color: var(--cottage-text-dark); margin-bottom: 3rem; text-align: center;">
          Selected Works
        </h2>
        <div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 1rem;">
          <div style="aspect-ratio: 1; overflow: hidden; border-radius: 8px;">
            <img
              src="/uploads/media/1763483281_a84d8a1756abb807.JPG"
              alt="She Lays Down - reclining figure in warm flesh tones"
              style="width: 100%; height: 100%; object-fit: cover; transition: opacity 0.3s;"
            />
          </div>
          <div style="aspect-ratio: 1; overflow: hidden; border-radius: 8px;">
            <img
              src="/uploads/media/1763542139_f6add8cef5e11b3a.jpg"
              alt="Ecstatic - floral still life above Georgian fireplace"
              style="width: 100%; height: 100%; object-fit: cover; transition: opacity 0.3s;"
            />
          </div>
          <div style="aspect-ratio: 1; overflow: hidden; border-radius: 8px;">
            <img
              src="/uploads/media/1763483281_14d2d6ab6485926c.jpg"
              alt="Shifting - expressionist landscape diptych"
              style="width: 100%; height: 100%; object-fit: cover; transition: opacity 0.3s;"
            />
          </div>
          <div style="aspect-ratio: 1; overflow: hidden; border-radius: 8px;">
            <img
              src="/uploads/media/1763542139_3020310155b8abcf.jpg"
              alt="A Becoming - figure emerging from gestural brushwork"
              style="width: 100%; height: 100%; object-fit: cover; transition: opacity 0.3s;"
            />
          </div>
        </div>
        <div style="text-align: center; margin-top: 3rem;">
          <a href="/work" class="cottage-button" style="display: inline-block; padding: 0.875rem 2.5rem;">
            View Full Collection
          </a>
        </div>
      </div>
    </section>

    <!-- For Collectors & Designers -->
    <section style="padding: 5rem 1rem; background: var(--cottage-beige);">
      <div style="max-width: 1000px; margin: 0 auto; display: grid; grid-template-columns: 1fr 1fr; gap: 4rem; align-items: center;">
        <div>
          <h2 class="cottage-heading" style="font-size: 1.5rem; color: var(--cottage-text-dark); margin-bottom: 1.5rem;">
            For Collectors & Designers
          </h2>
          <p class="cottage-body" style="font-size: 1rem; color: var(--cottage-text-medium); line-height: 1.8; margin-bottom: 1.5rem;">
            Olivia works with interior designers, hotels, and private collectors on commissions and art consultancy. Her paintings bring warmth, energy, and emotional depth to residential and hospitality spaces.
          </p>
          <a href="/hotels-designers" style="font-size: 0.875rem; text-transform: uppercase; letter-spacing: 0.1em; color: var(--cottage-wisteria); text-decoration: none; border-bottom: 1px solid var(--cottage-wisteria); padding-bottom: 0.25rem;">
            Learn More
          </a>
        </div>
        <div style="border: 1px solid var(--cottage-taupe); border-radius: 8px; overflow: hidden; box-shadow: 0 2px 12px rgba(200, 167, 216, 0.1);">
          <img
            src="/uploads/media/1763542139_5a2e8259c48f9c2c.JPG"
            alt="I Love Three Times triptych installed in domestic interior"
            style="width: 100%; display: block;"
          />
        </div>
      </div>
    </section>

    <!-- Newsletter -->
    <section style="padding: 5rem 1rem; background: white;">
      <div style="max-width: 500px; margin: 0 auto; text-align: center;">
        <h2 class="cottage-heading" style="font-size: 1.5rem; color: var(--cottage-text-dark); margin-bottom: 1rem;">
          Stay Updated
        </h2>
        <p class="cottage-body" style="color: var(--cottage-text-medium); margin-bottom: 2rem;">
          Subscribe for news about new work, exhibitions, and studio updates.
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

    <!-- Contact CTA -->
    <section style="padding: 4rem 1rem; background: var(--cottage-wisteria-deep); text-align: center;">
      <div style="max-width: 500px; margin: 0 auto;">
        <h3 class="cottage-heading" style="font-size: 1.5rem; color: white; margin-bottom: 1rem;">
          Interested in a piece?
        </h3>
        <p style="color: rgba(255, 255, 255, 0.85); margin-bottom: 2rem;">
          Get in touch for availability, pricing, and commissions.
        </p>
        <a href="/contact" style="display: inline-block; padding: 0.875rem 2.5rem; border: 1px solid white; border-radius: 6px; font-size: 0.875rem; text-transform: uppercase; letter-spacing: 0.1em; text-decoration: none; color: white; transition: all 0.3s;">
          Contact
        </a>
      </div>
    </section>
    """
  end

  defp render_gallery(assigns) do
    ~H"""
    <!-- Hero Section with Featured Artwork -->
    <section style="min-height: 90vh; display: flex; flex-direction: column; justify-content: center; align-items: center; padding: 4rem 1.5rem; background: linear-gradient(to bottom, #faf8f5, #f5f3f0);">
      <!-- Hero Artwork - A Becoming -->
      <div style="max-width: 500px; width: 100%; margin-bottom: 3rem;">
        <div style="border: 8px solid #fff; box-shadow: 0 4px 20px rgba(44, 36, 22, 0.1);">
          <img
            src="/uploads/media/1763542139_3020310155b8abcf.jpg"
            alt="A Becoming - Expressionist figure painting of nude torso emerging from gestural brushwork"
            style="width: 100%; height: auto; display: block;"
          />
        </div>
      </div>

      <!-- Hero Text -->
      <div style="text-align: center; max-width: 600px;">
        <h1 class="gallery-script" style="font-size: 3.5rem; color: #2c2416; margin-bottom: 0.5rem; font-weight: 400;">
          Olivia Tew
        </h1>
        <p style="font-size: 0.875rem; text-transform: uppercase; letter-spacing: 0.2em; color: #8b7355; margin-bottom: 2rem;">
          Contemporary Expressionist Painter
        </p>
        <p style="font-size: 1.125rem; color: #6b5d54; line-height: 1.8; margin-bottom: 2rem;">
          Bold colour, gestural mark-making, and heavy impasto surfaces that give form weight and permanence.
        </p>
        <a
          href="/work"
          style="display: inline-block; padding: 0.75rem 2rem; border: 1px solid #2c2416; font-size: 0.8125rem; text-transform: uppercase; letter-spacing: 0.15em; text-decoration: none; color: #2c2416; transition: all 0.3s;"
        >
          View the Collection
        </a>
      </div>
    </section>

    <!-- Three Bodies of Work -->
    <section style="padding: 6rem 1.5rem; background: #fff;">
      <div style="max-width: 1200px; margin: 0 auto;">
        <div style="text-align: center; margin-bottom: 4rem;">
          <h2 class="gallery-heading" style="font-size: 2rem; color: #2c2416; margin-bottom: 1rem;">
            The Collection
          </h2>
          <div style="width: 60px; height: 1px; background: #c4b5a0; margin: 0 auto;"></div>
        </div>

        <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 2rem;">
          <!-- Becoming - Figures -->
          <a href="/work#becoming" style="text-decoration: none; display: block;">
            <div style="border: 6px solid #fff; box-shadow: 0 2px 12px rgba(44, 36, 22, 0.08); margin-bottom: 1.5rem; overflow: hidden;">
              <img
                src="/uploads/media/1763542139_22309219aa56fb95.jpg"
                alt="Changes - expressionistic figure study in contemplative pose"
                style="width: 100%; aspect-ratio: 4/5; object-fit: cover; display: block; transition: transform 0.4s;"
              />
            </div>
            <h3 class="gallery-heading" style="font-size: 1.25rem; color: #2c2416; margin-bottom: 0.5rem;">
              Becoming
            </h3>
            <p style="font-size: 0.8125rem; color: #8b7355; text-transform: uppercase; letter-spacing: 0.1em;">
              Figure Works
            </p>
          </a>

          <!-- Abundance - Florals -->
          <a href="/work#abundance" style="text-decoration: none; display: block;">
            <div style="border: 6px solid #fff; box-shadow: 0 2px 12px rgba(44, 36, 22, 0.08); margin-bottom: 1.5rem; overflow: hidden;">
              <img
                src="/uploads/media/1763542139_1225c3b883e0ce02.jpg"
                alt="Marilyn - golden floral with white daffodils"
                style="width: 100%; aspect-ratio: 4/5; object-fit: cover; display: block; transition: transform 0.4s;"
              />
            </div>
            <h3 class="gallery-heading" style="font-size: 1.25rem; color: #2c2416; margin-bottom: 0.5rem;">
              Abundance
            </h3>
            <p style="font-size: 0.8125rem; color: #8b7355; text-transform: uppercase; letter-spacing: 0.1em;">
              Floral Works
            </p>
          </a>

          <!-- Shifting - Landscapes -->
          <a href="/work#shifting" style="text-decoration: none; display: block;">
            <div style="border: 6px solid #fff; box-shadow: 0 2px 12px rgba(44, 36, 22, 0.08); margin-bottom: 1.5rem; overflow: hidden;">
              <img
                src="/uploads/media/1763483281_ebd1913da6ebeabd.jpg"
                alt="Shifting Part 1 - expressionist landscape with pink wall and garden"
                style="width: 100%; aspect-ratio: 4/5; object-fit: cover; display: block; transition: transform 0.4s;"
              />
            </div>
            <h3 class="gallery-heading" style="font-size: 1.25rem; color: #2c2416; margin-bottom: 0.5rem;">
              Shifting
            </h3>
            <p style="font-size: 0.8125rem; color: #8b7355; text-transform: uppercase; letter-spacing: 0.1em;">
              Landscape Works
            </p>
          </a>
        </div>
      </div>
    </section>

    <!-- Statement Quote -->
    <section style="padding: 5rem 1.5rem; background: #f5f3f0;">
      <div style="max-width: 700px; margin: 0 auto; text-align: center;">
        <blockquote class="gallery-script" style="font-size: 1.75rem; line-height: 1.6; color: #2c2416; margin-bottom: 2rem; font-style: italic;">
          "Each painting asks us to witness without intruding—the universal experience of weathering change, of the body as vessel for emotional experience."
        </blockquote>
        <div style="width: 60px; height: 1px; background: #c4b5a0; margin: 0 auto 2rem;"></div>
        <p style="font-size: 1rem; color: #6b5d54; line-height: 1.8;">
          Working in oil, Olivia builds surfaces through heavy impasto that gives form weight and permanence. Her gestural brushwork refuses prettiness—each stroke visible, urgent, yet the cumulative effect is deeply tender.
        </p>
        <div style="margin-top: 2rem;">
          <a
            href="/about"
            style="font-size: 0.8125rem; text-transform: uppercase; letter-spacing: 0.15em; color: #8b7355; text-decoration: none; border-bottom: 1px solid #c4b5a0; padding-bottom: 0.25rem;"
          >
            About the Artist
          </a>
        </div>
      </div>
    </section>

    <!-- Selected Works Grid -->
    <section style="padding: 6rem 1.5rem; background: #fff;">
      <div style="max-width: 1200px; margin: 0 auto;">
        <h2 class="gallery-heading" style="font-size: 1.5rem; color: #2c2416; margin-bottom: 3rem;">
          Selected Works
        </h2>
        <div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 1rem;">
          <div style="aspect-ratio: 1; overflow: hidden;">
            <img
              src="/uploads/media/1763483281_a84d8a1756abb807.JPG"
              alt="She Lays Down - reclining figure"
              style="width: 100%; height: 100%; object-fit: cover; transition: opacity 0.3s;"
            />
          </div>
          <div style="aspect-ratio: 1; overflow: hidden;">
            <img
              src="/uploads/media/1763542139_f6add8cef5e11b3a.jpg"
              alt="Ecstatic - floral still life above Georgian fireplace"
              style="width: 100%; height: 100%; object-fit: cover; transition: opacity 0.3s;"
            />
          </div>
          <div style="aspect-ratio: 1; overflow: hidden;">
            <img
              src="/uploads/media/1763483281_62762e1c677b1d02.jpg"
              alt="Floral with red ground and patterned vase"
              style="width: 100%; height: 100%; object-fit: cover; transition: opacity 0.3s;"
            />
          </div>
          <div style="aspect-ratio: 1; overflow: hidden;">
            <img
              src="/uploads/media/1763483281_a7b4acd750ac636c.jpg"
              alt="Shifting Part 2 - coastal landscape"
              style="width: 100%; height: 100%; object-fit: cover; transition: opacity 0.3s;"
            />
          </div>
        </div>
        <div style="text-align: center; margin-top: 3rem;">
          <a
            href="/work"
            style="display: inline-block; padding: 0.75rem 2rem; background: #6b5d54; color: #faf8f5; font-size: 0.8125rem; text-transform: uppercase; letter-spacing: 0.15em; text-decoration: none; transition: background 0.3s;"
          >
            View Full Collection
          </a>
        </div>
      </div>
    </section>

    <!-- For Collectors & Designers -->
    <section style="padding: 5rem 1.5rem; background: #f5f3f0;">
      <div style="max-width: 1000px; margin: 0 auto; display: grid; grid-template-columns: 1fr 1fr; gap: 4rem; align-items: center;">
        <div>
          <h2 class="gallery-heading" style="font-size: 1.5rem; color: #2c2416; margin-bottom: 1.5rem;">
            For Collectors & Designers
          </h2>
          <p style="font-size: 1rem; color: #6b5d54; line-height: 1.8; margin-bottom: 1.5rem;">
            Olivia works with interior designers, hotels, and private collectors on commissions and art consultancy. Her paintings bring warmth, energy, and emotional depth to residential and hospitality spaces.
          </p>
          <a
            href="/hotels-designers"
            style="font-size: 0.8125rem; text-transform: uppercase; letter-spacing: 0.15em; color: #8b7355; text-decoration: none; border-bottom: 1px solid #c4b5a0; padding-bottom: 0.25rem;"
          >
            Learn More
          </a>
        </div>
        <div style="border: 6px solid #fff; box-shadow: 0 2px 12px rgba(44, 36, 22, 0.08);">
          <img
            src="/uploads/media/1763542139_5a2e8259c48f9c2c.JPG"
            alt="I Love Three Times triptych installed in interior"
            style="width: 100%; display: block;"
          />
        </div>
      </div>
    </section>

    <!-- Newsletter -->
    <section style="padding: 5rem 1.5rem; background: #fff; border-top: 1px solid #e8e6e3;">
      <div style="max-width: 500px; margin: 0 auto; text-align: center;">
        <h2 class="gallery-heading" style="font-size: 1.5rem; color: #2c2416; margin-bottom: 1rem;">
          Stay Updated
        </h2>
        <p style="color: #6b5d54; margin-bottom: 2rem;">
          Subscribe for news about new work, exhibitions, and studio updates.
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

    <!-- Contact CTA -->
    <section style="padding: 4rem 1.5rem; background: #2c2416; text-align: center;">
      <div style="max-width: 500px; margin: 0 auto;">
        <h3 class="gallery-heading" style="font-size: 1.25rem; color: #faf8f5; margin-bottom: 1rem;">
          Interested in a piece?
        </h3>
        <p style="color: #c4b5a0; margin-bottom: 2rem; font-size: 0.9375rem;">
          Get in touch for availability, pricing, and commissions.
        </p>
        <a
          href="/contact"
          style="display: inline-block; padding: 0.75rem 2rem; border: 1px solid #faf8f5; font-size: 0.8125rem; text-transform: uppercase; letter-spacing: 0.15em; text-decoration: none; color: #faf8f5; transition: all 0.3s;"
        >
          Contact
        </a>
      </div>
    </section>
    """
  end

  defp render_default(assigns) do
    ~H"""
    <div class="min-h-screen">
      <!-- Hero Section with Featured Artwork -->
      <div class="relative bg-gray-50">
        <div class="mx-auto max-w-7xl">
          <div class="grid lg:grid-cols-2 gap-0">
            <!-- Hero Image -->
            <div class="relative aspect-[4/5] lg:aspect-auto">
              <img
                src="/uploads/media/1763542139_3020310155b8abcf.jpg"
                alt="A Becoming - Expressionist figure painting of nude torso emerging from gestural brushwork"
                class="w-full h-full object-cover"
              />
            </div>
            <!-- Hero Text -->
            <div class="flex flex-col justify-center px-6 py-16 lg:px-12 lg:py-24">
              <h1 class="text-4xl font-bold tracking-tight text-gray-900 sm:text-5xl lg:text-6xl">
                Olivia Tew
              </h1>
              <p class="mt-2 text-xl text-gray-500 italic">
                Contemporary Painter
              </p>
              <p class="mt-6 text-lg leading-8 text-gray-600 max-w-lg">
                Bold colour, gestural mark-making, and heavy impasto surfaces that give form weight and permanence. Figure studies, floral still lifes, and expressionistic landscapes united by an unflinching approach to emotional truth.
              </p>
              <div class="mt-8 flex gap-4">
                <.link
                  navigate={~p"/work"}
                  class="rounded-md bg-gray-900 px-4 py-2.5 text-sm font-semibold text-white shadow-sm hover:bg-gray-800"
                >
                  View the Work
                </.link>
                <.link
                  navigate={~p"/about"}
                  class="rounded-md bg-white px-4 py-2.5 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
                >
                  About the Artist
                </.link>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Three Bodies of Work -->
      <div class="bg-white py-16 sm:py-24">
        <div class="mx-auto max-w-7xl px-6 lg:px-8">
          <div class="mx-auto max-w-2xl text-center mb-16">
            <h2 class="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
              The Collection
            </h2>
            <p class="mt-4 text-lg text-gray-600">
              Three distinct bodies of work exploring transformation, abundance, and the shifting landscape
            </p>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
            <!-- Figure Works -->
            <.link navigate={~p"/work"} class="group block">
              <div class="relative aspect-[4/5] overflow-hidden rounded-lg bg-gray-100">
                <img
                  src="/uploads/media/1763542139_22309219aa56fb95.jpg"
                  alt="Changes - expressionistic figure study"
                  class="w-full h-full object-cover group-hover:opacity-90 transition-opacity"
                />
              </div>
              <h3 class="mt-4 text-lg font-semibold text-gray-900 group-hover:text-gray-600">
                Becoming
              </h3>
              <p class="mt-1 text-sm text-gray-500">
                Figure works exploring emergence and transformation
              </p>
            </.link>

            <!-- Floral Works -->
            <.link navigate={~p"/work"} class="group block">
              <div class="relative aspect-[4/5] overflow-hidden rounded-lg bg-gray-100">
                <img
                  src="/uploads/media/1763542139_f6add8cef5e11b3a.jpg"
                  alt="Ecstatic - floral still life"
                  class="w-full h-full object-cover group-hover:opacity-90 transition-opacity"
                />
              </div>
              <h3 class="mt-4 text-lg font-semibold text-gray-900 group-hover:text-gray-600">
                Abundance
              </h3>
              <p class="mt-1 text-sm text-gray-500">
                Floral celebrations of colour and joy
              </p>
            </.link>

            <!-- Landscape Works -->
            <.link navigate={~p"/work"} class="group block">
              <div class="relative aspect-[4/5] overflow-hidden rounded-lg bg-gray-100">
                <img
                  src="/uploads/media/1763483281_14d2d6ab6485926c.jpg"
                  alt="Shifting - expressionist landscape diptych"
                  class="w-full h-full object-cover object-center group-hover:opacity-90 transition-opacity"
                />
              </div>
              <h3 class="mt-4 text-lg font-semibold text-gray-900 group-hover:text-gray-600">
                Shifting
              </h3>
              <p class="mt-1 text-sm text-gray-500">
                Landscapes in perpetual transformation
              </p>
            </.link>
          </div>
        </div>
      </div>

      <!-- Artist Statement -->
      <div class="bg-gray-50 py-16 sm:py-24">
        <div class="mx-auto max-w-3xl px-6 lg:px-8">
          <blockquote class="text-center">
            <p class="text-2xl font-medium leading-9 text-gray-900 italic">
              "Each painting asks us to witness without intruding—the universal experience of weathering change, of the body as vessel for emotional experience."
            </p>
          </blockquote>
          <div class="mt-8 flex justify-center">
            <div class="w-16 h-px bg-gray-300"></div>
          </div>
          <p class="mt-8 text-center text-gray-600 leading-7">
            Working primarily in oil, Olivia builds surfaces through heavy impasto that gives form weight and permanence. Her gestural brushwork refuses prettiness or idealisation—each stroke visible, urgent, yet deeply tender in cumulative effect.
          </p>
          <div class="mt-8 text-center">
            <.link
              navigate={~p"/about"}
              class="text-sm font-semibold text-gray-900 hover:text-gray-600"
            >
              Read more about the artist <span aria-hidden="true">→</span>
            </.link>
          </div>
        </div>
      </div>

      <!-- Selected Works Gallery -->
      <div class="bg-white py-16 sm:py-24">
        <div class="mx-auto max-w-7xl px-6 lg:px-8">
          <h2 class="text-2xl font-bold tracking-tight text-gray-900 mb-8">
            Selected Works
          </h2>
          <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
            <div class="aspect-square overflow-hidden rounded-lg">
              <img
                src="/uploads/media/1763483281_a84d8a1756abb807.JPG"
                alt="She Lays Down - reclining figure"
                class="w-full h-full object-cover hover:opacity-90 transition-opacity"
              />
            </div>
            <div class="aspect-square overflow-hidden rounded-lg">
              <img
                src="/uploads/media/1763542139_1225c3b883e0ce02.jpg"
                alt="Marilyn - golden floral"
                class="w-full h-full object-cover hover:opacity-90 transition-opacity"
              />
            </div>
            <div class="aspect-square overflow-hidden rounded-lg">
              <img
                src="/uploads/media/1763483281_62762e1c677b1d02.jpg"
                alt="Floral with red ground"
                class="w-full h-full object-cover hover:opacity-90 transition-opacity"
              />
            </div>
            <div class="aspect-square overflow-hidden rounded-lg">
              <img
                src="/uploads/media/1763483281_ebd1913da6ebeabd.jpg"
                alt="Shifting Part 1"
                class="w-full h-full object-cover hover:opacity-90 transition-opacity"
              />
            </div>
          </div>
          <div class="mt-8 text-center">
            <.link
              navigate={~p"/work"}
              class="rounded-md bg-gray-900 px-4 py-2.5 text-sm font-semibold text-white shadow-sm hover:bg-gray-800"
            >
              View Full Collection
            </.link>
          </div>
        </div>
      </div>

      <!-- For Hotels & Designers -->
      <div class="bg-gray-50 py-16">
        <div class="mx-auto max-w-7xl px-6 lg:px-8">
          <div class="grid lg:grid-cols-2 gap-12 items-center">
            <div>
              <h2 class="text-2xl font-bold tracking-tight text-gray-900">
                For Hotels & Designers
              </h2>
              <p class="mt-4 text-gray-600 leading-7">
                Olivia works with interior designers, hotels, and private collectors on commissions and art consultancy. Her paintings bring warmth, energy, and emotional depth to residential and hospitality spaces.
              </p>
              <p class="mt-4 text-gray-600 leading-7">
                To help you visualise how a piece might work in your space, we can supply a full-size poster print of any artwork for assessment purposes, provided at cost. This allows you to experience the scale, colour relationships, and impact before committing to an original.
              </p>
              <div class="mt-6">
                <.link
                  navigate={~p"/hotels-designers"}
                  class="text-sm font-semibold text-gray-900 hover:text-gray-600"
                >
                  Learn about working together <span aria-hidden="true">→</span>
                </.link>
              </div>
            </div>
            <div class="aspect-[3/4] overflow-hidden rounded-lg">
              <img
                src="/uploads/media/1763555487_35a594e71b1cb673.png"
                alt="Artwork visualisation in luxury Swiss hotel lounge with alpine views"
                class="w-full h-full object-cover"
              />
            </div>
          </div>
        </div>
      </div>

      <!-- Newsletter Section -->
      <div class="bg-white py-16 sm:py-24">
        <div class="mx-auto max-w-7xl px-6 lg:px-8">
          <div class="mx-auto max-w-2xl text-center">
            <h2 class="text-2xl font-bold tracking-tight text-gray-900">
              Stay Updated
            </h2>
            <p class="mt-4 text-gray-600">
              Subscribe for news about new work, exhibitions, and studio updates.
            </p>
          </div>
          <form
            phx-submit="subscribe"
            class="mx-auto mt-8 flex max-w-md gap-x-4"
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

      <!-- Contact CTA -->
      <div class="bg-gray-900 py-12">
        <div class="mx-auto max-w-7xl px-6 lg:px-8 text-center">
          <h2 class="text-xl font-semibold text-white">
            Interested in a piece?
          </h2>
          <p class="mt-2 text-gray-300">
            Get in touch for availability, pricing, and commissions.
          </p>
          <div class="mt-6">
            <.link
              navigate={~p"/contact"}
              class="rounded-md bg-white px-4 py-2.5 text-sm font-semibold text-gray-900 shadow-sm hover:bg-gray-100"
            >
              Contact
            </.link>
          </div>
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
