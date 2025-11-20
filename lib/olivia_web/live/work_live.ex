defmodule OliviaWeb.WorkLive do
  use OliviaWeb, :live_view

  import OliviaWeb.AssetHelpers, only: [resolve_asset_url: 1]

  @impl true
  def render(assigns) do
    cond do
      assigns[:theme] == "curator" -> render_curator(assigns)
      assigns[:theme] == "cottage" -> render_cottage(assigns)
      assigns[:theme] == "gallery" -> render_gallery(assigns)
      true -> render_default(assigns)
    end
  end

  defp render_gallery(assigns) do
    ~H"""
    <!-- Page Header -->
    <section style="padding: 5rem 1.5rem 3rem; text-align: center; background: linear-gradient(to bottom, #faf8f5, #fff);">
      <h1 class="gallery-heading" style="font-size: 2.5rem; color: #2c2416; margin-bottom: 1rem;">
        The Work
      </h1>
      <div style="width: 60px; height: 1px; background: #c4b5a0; margin: 0 auto 2rem;"></div>
      <p style="color: #6b5d54; max-width: 600px; margin: 0 auto; line-height: 1.8;">
        Three distinct bodies of work united by bold colour, gestural mark-making, and an unflinching approach to emotional truth.
      </p>
    </section>

    <!-- Becoming - Figure Works -->
    <section id="becoming" style="padding: 5rem 1.5rem; background: #fff;">
      <div style="max-width: 1200px; margin: 0 auto;">
        <div style="margin-bottom: 3rem;">
          <h2 class="gallery-heading" style="font-size: 2rem; color: #2c2416; margin-bottom: 0.5rem;">
            Becoming
          </h2>
          <p class="gallery-script" style="font-size: 1rem; color: #8b7355; margin-bottom: 1.5rem; font-style: italic;">
            Figure Works
          </p>
          <p style="color: #6b5d54; max-width: 600px; line-height: 1.8;">
            Expressionistic figure studies that capture the human form in moments of profound introspection. The paintings ask us to witness without intruding—the universal experience of sitting with difficulty, of weathering change, of the body as vessel for emotional experience.
          </p>
        </div>

        <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 2rem;">
          <!-- A Becoming -->
          <div>
            <div style="border: 6px solid #fff; box-shadow: 0 2px 12px rgba(44, 36, 22, 0.08); margin-bottom: 1rem;">
              <img
                src={resolve_asset_url("/uploads/media/1763542139_3020310155b8abcf.jpg")}
                alt="A Becoming - Expressionist figure painting of nude torso emerging from gestural brushwork"
                style="width: 100%; display: block;"
              />
            </div>
            <h3 class="gallery-heading" style="font-size: 1.125rem; color: #2c2416; margin-bottom: 0.25rem;">A Becoming</h3>
            <p style="font-size: 0.8125rem; color: #8b7355;">Oil on canvas</p>
          </div>

          <!-- Changes -->
          <div>
            <div style="border: 6px solid #fff; box-shadow: 0 2px 12px rgba(44, 36, 22, 0.08); margin-bottom: 1rem;">
              <img
                src={resolve_asset_url("/uploads/media/1763542139_22309219aa56fb95.jpg")}
                alt="Changes - expressionistic figure study in blue"
                style="width: 100%; display: block;"
              />
            </div>
            <h3 class="gallery-heading" style="font-size: 1.125rem; color: #2c2416; margin-bottom: 0.25rem;">Changes</h3>
            <p style="font-size: 0.8125rem; color: #8b7355;">Oil on canvas</p>
          </div>

          <!-- She Lays Down -->
          <div>
            <div style="border: 6px solid #fff; box-shadow: 0 2px 12px rgba(44, 36, 22, 0.08); margin-bottom: 1rem;">
              <img
                src={resolve_asset_url("/uploads/media/1763483281_a84d8a1756abb807.JPG")}
                alt="She Lays Down - reclining figure in warm flesh tones"
                style="width: 100%; display: block;"
              />
            </div>
            <h3 class="gallery-heading" style="font-size: 1.125rem; color: #2c2416; margin-bottom: 0.25rem;">She Lays Down</h3>
            <p style="font-size: 0.8125rem; color: #8b7355;">Oil on canvas</p>
          </div>
        </div>
      </div>
    </section>

    <!-- Abundance - Floral Works -->
    <section id="abundance" style="padding: 5rem 1.5rem; background: #f5f3f0;">
      <div style="max-width: 1200px; margin: 0 auto;">
        <div style="margin-bottom: 3rem;">
          <h2 class="gallery-heading" style="font-size: 2rem; color: #2c2416; margin-bottom: 0.5rem;">
            Abundance
          </h2>
          <p class="gallery-script" style="font-size: 1rem; color: #8b7355; margin-bottom: 1.5rem; font-style: italic;">
            Floral Works
          </p>
          <p style="color: #6b5d54; max-width: 600px; line-height: 1.8;">
            Exuberant floral still lifes that celebrate colour, pattern, and the tension between order and organic profusion. These works demand attention, project outward, and perform their beauty with confidence—both natural and constructed, genuine and glamorous.
          </p>
        </div>

        <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 2rem;">
          <!-- Marilyn -->
          <div>
            <div style="border: 6px solid #fff; box-shadow: 0 2px 12px rgba(44, 36, 22, 0.08); margin-bottom: 1rem;">
              <img
                src={resolve_asset_url("/uploads/media/1763542139_1225c3b883e0ce02.jpg")}
                alt="Marilyn - golden floral with white daffodils in garden light"
                style="width: 100%; display: block;"
              />
            </div>
            <h3 class="gallery-heading" style="font-size: 1.125rem; color: #2c2416; margin-bottom: 0.25rem;">Marilyn</h3>
            <p style="font-size: 0.8125rem; color: #8b7355;">Oil on canvas</p>
          </div>

          <!-- Ecstatic -->
          <div>
            <div style="border: 6px solid #fff; box-shadow: 0 2px 12px rgba(44, 36, 22, 0.08); margin-bottom: 1rem;">
              <img
                src={resolve_asset_url("/uploads/media/1763542139_f6add8cef5e11b3a.jpg")}
                alt="Ecstatic - floral still life above Georgian fireplace"
                style="width: 100%; display: block;"
              />
            </div>
            <h3 class="gallery-heading" style="font-size: 1.125rem; color: #2c2416; margin-bottom: 0.25rem;">Ecstatic</h3>
            <p style="font-size: 0.8125rem; color: #8b7355;">Oil on canvas</p>
          </div>

          <!-- Red Ground Floral -->
          <div>
            <div style="border: 6px solid #fff; box-shadow: 0 2px 12px rgba(44, 36, 22, 0.08); margin-bottom: 1rem;">
              <img
                src={resolve_asset_url("/uploads/media/1763483281_62762e1c677b1d02.jpg")}
                alt="Floral with red ground and patterned vase"
                style="width: 100%; display: block;"
              />
            </div>
            <h3 class="gallery-heading" style="font-size: 1.125rem; color: #2c2416; margin-bottom: 0.25rem;">Untitled (Red Ground)</h3>
            <p style="font-size: 0.8125rem; color: #8b7355;">Oil on canvas</p>
          </div>

          <!-- Red Ground Detail -->
          <div>
            <div style="border: 6px solid #fff; box-shadow: 0 2px 12px rgba(44, 36, 22, 0.08); margin-bottom: 1rem;">
              <img
                src={resolve_asset_url("/uploads/media/1763483281_c9cd48fa716cf037.jpg")}
                alt="Floral detail with coral ground"
                style="width: 100%; display: block;"
              />
            </div>
            <h3 class="gallery-heading" style="font-size: 1.125rem; color: #2c2416; margin-bottom: 0.25rem;">Coral Ground (Detail)</h3>
            <p style="font-size: 0.8125rem; color: #8b7355;">Oil on canvas</p>
          </div>

          <!-- Marilyn Indoor -->
          <div>
            <div style="border: 6px solid #fff; box-shadow: 0 2px 12px rgba(44, 36, 22, 0.08); margin-bottom: 1rem;">
              <img
                src={resolve_asset_url("/uploads/media/1763542139_e7e47b872f6b7223.JPG")}
                alt="Marilyn - studio view with warm golden tones"
                style="width: 100%; display: block;"
              />
            </div>
            <h3 class="gallery-heading" style="font-size: 1.125rem; color: #2c2416; margin-bottom: 0.25rem;">Marilyn (Studio)</h3>
            <p style="font-size: 0.8125rem; color: #8b7355;">Oil on canvas</p>
          </div>

          <!-- I Love Three Times -->
          <div>
            <div style="border: 6px solid #fff; box-shadow: 0 2px 12px rgba(44, 36, 22, 0.08); margin-bottom: 1rem;">
              <img
                src={resolve_asset_url("/uploads/media/1763542139_5a2e8259c48f9c2c.JPG")}
                alt="I Love Three Times - floral triptych installation"
                style="width: 100%; display: block;"
              />
            </div>
            <h3 class="gallery-heading" style="font-size: 1.125rem; color: #2c2416; margin-bottom: 0.25rem;">I Love Three Times</h3>
            <p style="font-size: 0.8125rem; color: #8b7355;">Oil on canvas, triptych</p>
          </div>
        </div>
      </div>
    </section>

    <!-- Shifting - Landscape Works -->
    <section id="shifting" style="padding: 5rem 1.5rem; background: #fff;">
      <div style="max-width: 1200px; margin: 0 auto;">
        <div style="margin-bottom: 3rem;">
          <h2 class="gallery-heading" style="font-size: 2rem; color: #2c2416; margin-bottom: 0.5rem;">
            Shifting
          </h2>
          <p class="gallery-script" style="font-size: 1rem; color: #8b7355; margin-bottom: 1.5rem; font-style: italic;">
            Landscape Works
          </p>
          <p style="color: #6b5d54; max-width: 600px; line-height: 1.8;">
            Landscapes in perpetual transformation. The impasto application is extraordinary in its physicality—paint applied in thick, directional strokes that mimic geological strata. The canvas becomes a physical analogue for the terrain it depicts.
          </p>
        </div>

        <!-- Diptych - Full Width -->
        <div style="margin-bottom: 3rem;">
          <div style="border: 6px solid #fff; box-shadow: 0 2px 12px rgba(44, 36, 22, 0.08); margin-bottom: 1rem;">
            <img
              src={resolve_asset_url("/uploads/media/1763483281_14d2d6ab6485926c.jpg")}
              alt="Shifting - expressionist landscape diptych"
              style="width: 100%; display: block;"
            />
          </div>
          <h3 class="gallery-heading" style="font-size: 1.125rem; color: #2c2416; margin-bottom: 0.25rem;">Shifting</h3>
          <p style="font-size: 0.8125rem; color: #8b7355;">Oil on canvas, diptych</p>
        </div>

        <!-- Individual Panels -->
        <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 2rem;">
          <!-- Part 1 -->
          <div>
            <div style="border: 6px solid #fff; box-shadow: 0 2px 12px rgba(44, 36, 22, 0.08); margin-bottom: 1rem;">
              <img
                src={resolve_asset_url("/uploads/media/1763483281_ebd1913da6ebeabd.jpg")}
                alt="Shifting Part 1 - garden threshold with pink wall"
                style="width: 100%; display: block;"
              />
            </div>
            <h3 class="gallery-heading" style="font-size: 1.125rem; color: #2c2416; margin-bottom: 0.25rem;">Shifting Part 1</h3>
            <p style="font-size: 0.8125rem; color: #8b7355;">Oil on canvas</p>
          </div>

          <!-- Part 2 -->
          <div>
            <div style="border: 6px solid #fff; box-shadow: 0 2px 12px rgba(44, 36, 22, 0.08); margin-bottom: 1rem;">
              <img
                src={resolve_asset_url("/uploads/media/1763483281_a7b4acd750ac636c.jpg")}
                alt="Shifting Part 2 - coastal path through textured terrain"
                style="width: 100%; display: block;"
              />
            </div>
            <h3 class="gallery-heading" style="font-size: 1.125rem; color: #2c2416; margin-bottom: 0.25rem;">Shifting Part 2</h3>
            <p style="font-size: 0.8125rem; color: #8b7355;">Oil on canvas</p>
          </div>
        </div>
      </div>
    </section>

    <!-- Contact CTA -->
    <section style="padding: 5rem 1.5rem; background: #2c2416; text-align: center;">
      <div style="max-width: 500px; margin: 0 auto;">
        <h3 class="gallery-heading" style="font-size: 1.5rem; color: #faf8f5; margin-bottom: 1rem;">
          Interested in a piece?
        </h3>
        <p style="color: #c4b5a0; margin-bottom: 2rem;">
          Contact for availability, pricing, and commission enquiries.
        </p>
        <a
          href="/contact"
          style="display: inline-block; padding: 0.75rem 2rem; border: 1px solid #faf8f5; font-size: 0.8125rem; text-transform: uppercase; letter-spacing: 0.15em; text-decoration: none; color: #faf8f5; transition: all 0.3s;"
        >
          Enquire
        </a>
      </div>
    </section>

    <!-- Back to home -->
    <div style="border-top: 1px solid #e8e6e3; padding: 2rem 1.5rem;">
      <div style="max-width: 1200px; margin: 0 auto;">
        <a href="/" style="font-size: 0.8125rem; text-transform: uppercase; letter-spacing: 0.1em; color: #8b7355; text-decoration: none;">
          ← Back to home
        </a>
      </div>
    </div>
    """
  end

  defp render_cottage(assigns) do
    ~H"""
    <!-- Page Header -->
    <section style="padding: 5rem 1rem 3rem; text-align: center; background: var(--cottage-cream);">
      <h1 class="cottage-heading" style="font-size: 2.5rem; color: var(--cottage-text-dark); margin-bottom: 1rem;">
        The Work
      </h1>
      <div class="cottage-divider"></div>
      <p class="cottage-body" style="color: var(--cottage-text-medium); max-width: 600px; margin: 2rem auto 0; line-height: 1.8;">
        Three distinct bodies of work united by bold colour, gestural mark-making, and an unflinching approach to emotional truth.
      </p>
    </section>

    <!-- Becoming - Figure Works -->
    <section id="becoming" style="padding: 5rem 1rem; background: white;">
      <div style="max-width: 1200px; margin: 0 auto;">
        <div style="margin-bottom: 3rem;">
          <h2 class="cottage-heading" style="font-size: 2rem; color: var(--cottage-text-dark); margin-bottom: 0.5rem;">
            Becoming
          </h2>
          <p class="cottage-accent" style="font-size: 1rem; color: var(--cottage-wisteria); margin-bottom: 1.5rem;">
            Figure Works
          </p>
          <p class="cottage-body" style="color: var(--cottage-text-medium); max-width: 600px; line-height: 1.8;">
            Expressionistic figure studies that capture the human form in moments of profound introspection. These paintings ask us to witness without intruding—the universal experience of sitting with difficulty, of weathering change, of the body as vessel for emotional experience.
          </p>
        </div>

        <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 2rem;">
          <!-- A Becoming -->
          <div>
            <div style="border: 1px solid var(--cottage-taupe); border-radius: 8px; overflow: hidden; margin-bottom: 1rem; box-shadow: 0 2px 8px rgba(200, 167, 216, 0.08);">
              <img
                src={resolve_asset_url("/uploads/media/1763542139_3020310155b8abcf.jpg")}
                alt="A Becoming - Expressionist figure painting of nude torso emerging from gestural brushwork in earthy flesh tones"
                style="width: 100%; display: block;"
              />
            </div>
            <h3 class="cottage-heading" style="font-size: 1.125rem; color: var(--cottage-text-dark); margin-bottom: 0.25rem;">A Becoming</h3>
            <p class="cottage-body" style="font-size: 0.8125rem; color: var(--cottage-text-medium);">Oil on canvas</p>
          </div>

          <!-- Changes -->
          <div>
            <div style="border: 1px solid var(--cottage-taupe); border-radius: 8px; overflow: hidden; margin-bottom: 1rem; box-shadow: 0 2px 8px rgba(200, 167, 216, 0.08);">
              <img
                src={resolve_asset_url("/uploads/media/1763542139_22309219aa56fb95.jpg")}
                alt="Changes - expressionistic figure study of seated nude with arms wrapped around knees against blue background"
                style="width: 100%; display: block;"
              />
            </div>
            <h3 class="cottage-heading" style="font-size: 1.125rem; color: var(--cottage-text-dark); margin-bottom: 0.25rem;">Changes</h3>
            <p class="cottage-body" style="font-size: 0.8125rem; color: var(--cottage-text-medium);">Oil on canvas</p>
          </div>

          <!-- She Lays Down -->
          <div>
            <div style="border: 1px solid var(--cottage-taupe); border-radius: 8px; overflow: hidden; margin-bottom: 1rem; box-shadow: 0 2px 8px rgba(200, 167, 216, 0.08);">
              <img
                src={resolve_asset_url("/uploads/media/1763483281_a84d8a1756abb807.JPG")}
                alt="She Lays Down - reclining female nude in warm flesh tones against deep blue and yellow"
                style="width: 100%; display: block;"
              />
            </div>
            <h3 class="cottage-heading" style="font-size: 1.125rem; color: var(--cottage-text-dark); margin-bottom: 0.25rem;">She Lays Down</h3>
            <p class="cottage-body" style="font-size: 0.8125rem; color: var(--cottage-text-medium);">Oil on canvas</p>
          </div>
        </div>
      </div>
    </section>

    <!-- Abundance - Floral Works -->
    <section id="abundance" style="padding: 5rem 1rem; background: var(--cottage-beige);">
      <div style="max-width: 1200px; margin: 0 auto;">
        <div style="margin-bottom: 3rem;">
          <h2 class="cottage-heading" style="font-size: 2rem; color: var(--cottage-text-dark); margin-bottom: 0.5rem;">
            Abundance
          </h2>
          <p class="cottage-accent" style="font-size: 1rem; color: var(--cottage-wisteria); margin-bottom: 1.5rem;">
            Floral Works
          </p>
          <p class="cottage-body" style="color: var(--cottage-text-medium); max-width: 600px; line-height: 1.8;">
            Exuberant floral still lifes that celebrate colour, pattern, and the tension between order and organic profusion. These works demand attention, project outward, and perform their beauty with confidence—both natural and constructed, genuine and glamorous.
          </p>
        </div>

        <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 2rem;">
          <!-- Marilyn -->
          <div>
            <div style="border: 1px solid var(--cottage-taupe); border-radius: 8px; overflow: hidden; margin-bottom: 1rem; box-shadow: 0 2px 8px rgba(200, 167, 216, 0.08);">
              <img
                src={resolve_asset_url("/uploads/media/1763542139_1225c3b883e0ce02.jpg")}
                alt="Marilyn - vibrant floral with white daffodils and blue hydrangea against golden ochre ground"
                style="width: 100%; display: block;"
              />
            </div>
            <h3 class="cottage-heading" style="font-size: 1.125rem; color: var(--cottage-text-dark); margin-bottom: 0.25rem;">Marilyn</h3>
            <p class="cottage-body" style="font-size: 0.8125rem; color: var(--cottage-text-medium);">Oil on canvas</p>
          </div>

          <!-- Red Ground Floral -->
          <div>
            <div style="border: 1px solid var(--cottage-taupe); border-radius: 8px; overflow: hidden; margin-bottom: 1rem; box-shadow: 0 2px 8px rgba(200, 167, 216, 0.08);">
              <img
                src={resolve_asset_url("/uploads/media/1763483281_62762e1c677b1d02.jpg")}
                alt="Abundant mixed flowers in black and white patterned vase against coral-red background"
                style="width: 100%; display: block;"
              />
            </div>
            <h3 class="cottage-heading" style="font-size: 1.125rem; color: var(--cottage-text-dark); margin-bottom: 0.25rem;">Untitled (Red Ground)</h3>
            <p class="cottage-body" style="font-size: 0.8125rem; color: var(--cottage-text-medium);">Oil on canvas</p>
          </div>

          <!-- Ecstatic -->
          <div>
            <div style="border: 1px solid var(--cottage-taupe); border-radius: 8px; overflow: hidden; margin-bottom: 1rem; box-shadow: 0 2px 8px rgba(200, 167, 216, 0.08);">
              <img
                src={resolve_asset_url("/uploads/media/1763542139_f6add8cef5e11b3a.jpg")}
                alt="Ecstatic - floral still life in patterned vase above Georgian fireplace with vibrant red background"
                style="width: 100%; display: block;"
              />
            </div>
            <h3 class="cottage-heading" style="font-size: 1.125rem; color: var(--cottage-text-dark); margin-bottom: 0.25rem;">Ecstatic</h3>
            <p class="cottage-body" style="font-size: 0.8125rem; color: var(--cottage-text-medium);">Oil on canvas</p>
          </div>

          <!-- On The Kitchen Table -->
          <div>
            <div style="border: 1px solid var(--cottage-taupe); border-radius: 8px; overflow: hidden; margin-bottom: 1rem; box-shadow: 0 2px 8px rgba(200, 167, 216, 0.08);">
              <img
                src={resolve_asset_url("/uploads/media/1763483281_9f4cf777abd53640.jpg")}
                alt="Abundant mixed flowers in decorative compote bowl on striped textile with soft pink background"
                style="width: 100%; display: block;"
              />
            </div>
            <h3 class="cottage-heading" style="font-size: 1.125rem; color: var(--cottage-text-dark); margin-bottom: 0.25rem;">On The Kitchen Table</h3>
            <p class="cottage-body" style="font-size: 0.8125rem; color: var(--cottage-text-medium);">Oil on canvas</p>
          </div>

          <!-- Marilyn Studio -->
          <div>
            <div style="border: 1px solid var(--cottage-taupe); border-radius: 8px; overflow: hidden; margin-bottom: 1rem; box-shadow: 0 2px 8px rgba(200, 167, 216, 0.08);">
              <img
                src={resolve_asset_url("/uploads/media/1763542139_e7e47b872f6b7223.JPG")}
                alt="Marilyn - white daffodils rising from ruffled vessel against golden ochre background, studio light"
                style="width: 100%; display: block;"
              />
            </div>
            <h3 class="cottage-heading" style="font-size: 1.125rem; color: var(--cottage-text-dark); margin-bottom: 0.25rem;">Marilyn (Studio)</h3>
            <p class="cottage-body" style="font-size: 0.8125rem; color: var(--cottage-text-medium);">Oil on canvas</p>
          </div>

          <!-- I Love Three Times -->
          <div>
            <div style="border: 1px solid var(--cottage-taupe); border-radius: 8px; overflow: hidden; margin-bottom: 1rem; box-shadow: 0 2px 8px rgba(200, 167, 216, 0.08);">
              <img
                src={resolve_asset_url("/uploads/media/1763542139_5a2e8259c48f9c2c.JPG")}
                alt="I Love Three Times - three panel triptych of flowers rising from striped vessel against olive-green background"
                style="width: 100%; display: block;"
              />
            </div>
            <h3 class="cottage-heading" style="font-size: 1.125rem; color: var(--cottage-text-dark); margin-bottom: 0.25rem;">I Love Three Times</h3>
            <p class="cottage-body" style="font-size: 0.8125rem; color: var(--cottage-text-medium);">Oil on canvas, triptych</p>
          </div>
        </div>
      </div>
    </section>

    <!-- Shifting - Landscape Works -->
    <section id="shifting" style="padding: 5rem 1rem; background: white;">
      <div style="max-width: 1200px; margin: 0 auto;">
        <div style="margin-bottom: 3rem;">
          <h2 class="cottage-heading" style="font-size: 2rem; color: var(--cottage-text-dark); margin-bottom: 0.5rem;">
            Shifting
          </h2>
          <p class="cottage-accent" style="font-size: 1rem; color: var(--cottage-wisteria); margin-bottom: 1.5rem;">
            Landscape Works
          </p>
          <p class="cottage-body" style="color: var(--cottage-text-medium); max-width: 600px; line-height: 1.8;">
            Landscapes in perpetual transformation. The impasto application is extraordinary in its physicality—paint applied in thick, directional strokes that mimic geological strata. The canvas becomes a physical analogue for the terrain it depicts.
          </p>
        </div>

        <!-- Diptych - Full Width -->
        <div style="margin-bottom: 3rem;">
          <div style="border: 1px solid var(--cottage-taupe); border-radius: 8px; overflow: hidden; margin-bottom: 1rem; box-shadow: 0 2px 8px rgba(200, 167, 216, 0.08);">
            <img
              src={resolve_asset_url("/uploads/media/1763483281_14d2d6ab6485926c.jpg")}
              alt="Shifting - expressionist coastal landscape diptych with pale pathway through textured hillsides in warm earth tones"
              style="width: 100%; display: block;"
            />
          </div>
          <h3 class="cottage-heading" style="font-size: 1.125rem; color: var(--cottage-text-dark); margin-bottom: 0.25rem;">Shifting</h3>
          <p class="cottage-body" style="font-size: 0.8125rem; color: var(--cottage-text-medium);">Oil on canvas, diptych</p>
        </div>

        <!-- Individual Panels -->
        <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 2rem;">
          <!-- Part 1 -->
          <div>
            <div style="border: 1px solid var(--cottage-taupe); border-radius: 8px; overflow: hidden; margin-bottom: 1rem; box-shadow: 0 2px 8px rgba(200, 167, 216, 0.08);">
              <img
                src={resolve_asset_url("/uploads/media/1763483281_ebd1913da6ebeabd.jpg")}
                alt="Shifting Part 1 - pink architectural wall beside dense green and multicoloured vegetation"
                style="width: 100%; display: block;"
              />
            </div>
            <h3 class="cottage-heading" style="font-size: 1.125rem; color: var(--cottage-text-dark); margin-bottom: 0.25rem;">Shifting Part 1</h3>
            <p class="cottage-body" style="font-size: 0.8125rem; color: var(--cottage-text-medium);">Oil on canvas</p>
          </div>

          <!-- Part 2 -->
          <div>
            <div style="border: 1px solid var(--cottage-taupe); border-radius: 8px; overflow: hidden; margin-bottom: 1rem; box-shadow: 0 2px 8px rgba(200, 167, 216, 0.08);">
              <img
                src={resolve_asset_url("/uploads/media/1763483281_a7b4acd750ac636c.jpg")}
                alt="Shifting Part 2 - coastal pathway through richly textured terrain in warm earth tones"
                style="width: 100%; display: block;"
              />
            </div>
            <h3 class="cottage-heading" style="font-size: 1.125rem; color: var(--cottage-text-dark); margin-bottom: 0.25rem;">Shifting Part 2</h3>
            <p class="cottage-body" style="font-size: 0.8125rem; color: var(--cottage-text-medium);">Oil on canvas</p>
          </div>
        </div>
      </div>
    </section>

    <!-- Contact CTA -->
    <section style="padding: 5rem 1rem; background: var(--cottage-wisteria-deep); text-align: center;">
      <div style="max-width: 500px; margin: 0 auto;">
        <h3 class="cottage-heading" style="font-size: 1.5rem; color: white; margin-bottom: 1rem;">
          Interested in a piece?
        </h3>
        <p style="color: rgba(255, 255, 255, 0.85); margin-bottom: 2rem;">
          Contact for availability, pricing, and commission enquiries.
        </p>
        <a href="/contact" style="display: inline-block; padding: 0.875rem 2.5rem; border: 1px solid white; border-radius: 6px; font-size: 0.875rem; text-transform: uppercase; letter-spacing: 0.1em; text-decoration: none; color: white; transition: all 0.3s;">
          Enquire
        </a>
      </div>
    </section>

    <!-- Back to home -->
    <div style="border-top: 1px solid var(--cottage-taupe); padding: 2rem 1rem; background: white;">
      <div style="max-width: 1200px; margin: 0 auto;">
        <a href="/" style="font-size: 0.875rem; text-transform: uppercase; letter-spacing: 0.1em; color: var(--cottage-wisteria); text-decoration: none;">
          ← Back to home
        </a>
      </div>
    </div>
    """
  end

  defp render_curator(assigns) do
    ~H"""
    <!-- Page Header -->
    <section style="padding: 4rem 2rem 2rem; text-align: center;">
      <h1 class="curator-heading" style="font-size: 2.5rem; margin-bottom: 1rem;">
        The Work
      </h1>
      <p class="curator-body" style="color: var(--curator-text-muted); max-width: 600px; margin: 0 auto;">
        Three distinct bodies of work united by bold colour, gestural mark-making, and an unflinching approach to emotional truth.
      </p>
    </section>

    <!-- Becoming - Figure Works -->
    <section id="becoming" style="padding: 4rem 2rem; background: var(--curator-bg);">
      <div style="max-width: 1200px; margin: 0 auto;">
        <div style="margin-bottom: 3rem;">
          <h2 class="curator-heading" style="font-size: 2rem; margin-bottom: 0.5rem;">
            Becoming
          </h2>
          <p class="curator-heading-italic" style="font-size: 1rem; color: var(--curator-text-muted); margin-bottom: 1rem;">
            Figure Works
          </p>
          <p class="curator-body" style="color: var(--curator-text-muted); max-width: 600px;">
            Expressionistic figure studies that capture the human form in moments of profound introspection. The paintings ask us to witness without intruding—the universal experience of sitting with difficulty, of weathering change, of the body as vessel for emotional experience.
          </p>
        </div>

        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 2rem;">
          <!-- A BECOMING -->
          <div>
            <div class="curator-artwork-card" style="margin-bottom: 1rem;">
              <img
                src={resolve_asset_url("/uploads/media/1763542139_3020310155b8abcf.jpg")}
                alt="A BECOMING - Expressionist figure painting of nude torso emerging from gestural brushwork"
                style="width: 100%; display: block;"
              />
            </div>
            <h3 class="curator-heading" style="font-size: 1.125rem; margin-bottom: 0.25rem;">A Becoming</h3>
            <p class="curator-body" style="font-size: 0.8125rem; color: var(--curator-text-muted);">Oil on canvas</p>
          </div>

          <!-- Changes -->
          <div>
            <div class="curator-artwork-card" style="margin-bottom: 1rem;">
              <img
                src={resolve_asset_url("/uploads/media/1763542139_22309219aa56fb95.jpg")}
                alt="Changes - expressionistic figure study in blue"
                style="width: 100%; display: block;"
              />
            </div>
            <h3 class="curator-heading" style="font-size: 1.125rem; margin-bottom: 0.25rem;">Changes</h3>
            <p class="curator-body" style="font-size: 0.8125rem; color: var(--curator-text-muted);">Oil on canvas</p>
          </div>

          <!-- A Becoming Background (Process) -->
          <div>
            <div class="curator-artwork-card" style="margin-bottom: 1rem;">
              <img
                src={resolve_asset_url("/uploads/media/1763542139_ba6e66be3929fdcd.jpg")}
                alt="Process documentation - A Becoming in progress"
                style="width: 100%; display: block;"
              />
            </div>
            <h3 class="curator-heading" style="font-size: 1.125rem; margin-bottom: 0.25rem;">A Becoming (Process)</h3>
            <p class="curator-body" style="font-size: 0.8125rem; color: var(--curator-text-muted);">Work in progress</p>
          </div>

          <!-- Exhibition Shot -->
          <div>
            <div class="curator-artwork-card" style="margin-bottom: 1rem;">
              <img
                src={resolve_asset_url("/uploads/media/1763542139_5a2e8259c48f9c2c.JPG")}
                alt="Exhibition documentation with artist"
                style="width: 100%; display: block;"
              />
            </div>
            <h3 class="curator-heading" style="font-size: 1.125rem; margin-bottom: 0.25rem;">Exhibition View</h3>
            <p class="curator-body" style="font-size: 0.8125rem; color: var(--curator-text-muted);">A Becoming installed</p>
          </div>
        </div>
      </div>
    </section>

    <!-- Abundance - Florals -->
    <section id="abundance" style="padding: 4rem 2rem; background: var(--curator-bg-warm);">
      <div style="max-width: 1200px; margin: 0 auto;">
        <div style="margin-bottom: 3rem;">
          <h2 class="curator-heading" style="font-size: 2rem; margin-bottom: 0.5rem;">
            Abundance
          </h2>
          <p class="curator-heading-italic" style="font-size: 1rem; color: var(--curator-text-muted); margin-bottom: 1rem;">
            Floral Works
          </p>
          <p class="curator-body" style="color: var(--curator-text-muted); max-width: 600px;">
            Exuberant floral still lifes that celebrate colour, pattern, and the tension between order and organic profusion. These works demand attention, project outward, and perform their beauty with confidence—both natural and constructed, genuine and glamorous.
          </p>
        </div>

        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 2rem;">
          <!-- Ecstatic -->
          <div>
            <div class="curator-artwork-card" style="margin-bottom: 1rem;">
              <img
                src={resolve_asset_url("/uploads/media/1763542139_f6add8cef5e11b3a.jpg")}
                alt="Ecstatic - floral still life above Georgian fireplace"
                style="width: 100%; display: block;"
              />
            </div>
            <h3 class="curator-heading" style="font-size: 1.125rem; margin-bottom: 0.25rem;">Ecstatic</h3>
            <p class="curator-body" style="font-size: 0.8125rem; color: var(--curator-text-muted);">Oil on canvas, installed</p>
          </div>

          <!-- I Love Three Times (Full) -->
          <div>
            <div class="curator-artwork-card" style="margin-bottom: 1rem;">
              <img
                src={resolve_asset_url("/uploads/media/1763542139_5a2e8259c48f9c2c.JPG")}
                alt="I Love Three Times - triptych installation"
                style="width: 100%; display: block;"
              />
            </div>
            <h3 class="curator-heading" style="font-size: 1.125rem; margin-bottom: 0.25rem;">I Love Three Times</h3>
            <p class="curator-body" style="font-size: 0.8125rem; color: var(--curator-text-muted);">Oil on canvas, triptych</p>
          </div>

          <!-- Marilyn -->
          <div>
            <div class="curator-artwork-card" style="margin-bottom: 1rem;">
              <img
                src={resolve_asset_url("/uploads/media/1763542139_1225c3b883e0ce02.jpg")}
                alt="Marilyn - golden floral in natural light"
                style="width: 100%; display: block;"
              />
            </div>
            <h3 class="curator-heading" style="font-size: 1.125rem; margin-bottom: 0.25rem;">Marilyn</h3>
            <p class="curator-body" style="font-size: 0.8125rem; color: var(--curator-text-muted);">Oil on canvas</p>
          </div>

          <!-- Red Ground Floral -->
          <div>
            <div class="curator-artwork-card" style="margin-bottom: 1rem;">
              <img
                src={resolve_asset_url("/uploads/media/1763483281_62762e1c677b1d02.jpg")}
                alt="Floral still life with red ground"
                style="width: 100%; display: block;"
              />
            </div>
            <h3 class="curator-heading" style="font-size: 1.125rem; margin-bottom: 0.25rem;">Untitled (Red Ground)</h3>
            <p class="curator-body" style="font-size: 0.8125rem; color: var(--curator-text-muted);">Oil on canvas</p>
          </div>

          <!-- Marilyn Indoor -->
          <div>
            <div class="curator-artwork-card" style="margin-bottom: 1rem;">
              <img
                src={resolve_asset_url("/uploads/media/1763542139_e7e47b872f6b7223.JPG")}
                alt="Marilyn - indoor studio view"
                style="width: 100%; display: block;"
              />
            </div>
            <h3 class="curator-heading" style="font-size: 1.125rem; margin-bottom: 0.25rem;">Marilyn (Studio)</h3>
            <p class="curator-body" style="font-size: 0.8125rem; color: var(--curator-text-muted);">Oil on canvas</p>
          </div>

          <!-- I Love Three Times Alt -->
          <div>
            <div class="curator-artwork-card" style="margin-bottom: 1rem;">
              <img
                src={resolve_asset_url("/uploads/media/1763542139_3fcf4d765e5a5eeb.jpg")}
                alt="I Love Three Times - alternative installation"
                style="width: 100%; display: block;"
              />
            </div>
            <h3 class="curator-heading" style="font-size: 1.125rem; margin-bottom: 0.25rem;">I Love Three Times (Detail)</h3>
            <p class="curator-body" style="font-size: 0.8125rem; color: var(--curator-text-muted);">Oil on canvas, two panels</p>
          </div>

          <!-- Detail Red Ground -->
          <div>
            <div class="curator-artwork-card" style="margin-bottom: 1rem;">
              <img
                src={resolve_asset_url("/uploads/media/1763483281_c9cd48fa716cf037.jpg")}
                alt="Floral detail with red ground"
                style="width: 100%; display: block;"
              />
            </div>
            <h3 class="curator-heading" style="font-size: 1.125rem; margin-bottom: 0.25rem;">Untitled (Red Ground II)</h3>
            <p class="curator-body" style="font-size: 0.8125rem; color: var(--curator-text-muted);">Oil on canvas</p>
          </div>
        </div>
      </div>
    </section>

    <!-- Shifting - Landscapes -->
    <section id="shifting" style="padding: 4rem 2rem; background: var(--curator-bg);">
      <div style="max-width: 1200px; margin: 0 auto;">
        <div style="margin-bottom: 3rem;">
          <h2 class="curator-heading" style="font-size: 2rem; margin-bottom: 0.5rem;">
            Shifting
          </h2>
          <p class="curator-heading-italic" style="font-size: 1rem; color: var(--curator-text-muted); margin-bottom: 1rem;">
            Landscape Works
          </p>
          <p class="curator-body" style="color: var(--curator-text-muted); max-width: 600px;">
            Landscapes in perpetual transformation. The impasto application is extraordinary in its physicality—paint applied in thick, directional strokes that mimic geological strata. The canvas becomes a physical analogue for the terrain it depicts.
          </p>
        </div>

        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 2rem;">
          <!-- SHIFTING Diptych -->
          <div style="grid-column: span 2;">
            <div class="curator-artwork-card" style="margin-bottom: 1rem;">
              <img
                src={resolve_asset_url("/uploads/media/1763483281_14d2d6ab6485926c.jpg")}
                alt="SHIFTING - expressionist landscape diptych"
                style="width: 100%; display: block;"
              />
            </div>
            <h3 class="curator-heading" style="font-size: 1.125rem; margin-bottom: 0.25rem;">Shifting</h3>
            <p class="curator-body" style="font-size: 0.8125rem; color: var(--curator-text-muted);">Oil on canvas, diptych</p>
          </div>

          <!-- SHIFTING Part 1 -->
          <div>
            <div class="curator-artwork-card" style="margin-bottom: 1rem;">
              <img
                src={resolve_asset_url("/uploads/media/1763483281_ebd1913da6ebeabd.jpg")}
                alt="SHIFTING PART 1 - garden threshold"
                style="width: 100%; display: block;"
              />
            </div>
            <h3 class="curator-heading" style="font-size: 1.125rem; margin-bottom: 0.25rem;">Shifting Part 1</h3>
            <p class="curator-body" style="font-size: 0.8125rem; color: var(--curator-text-muted);">Oil on canvas</p>
          </div>
        </div>
      </div>
    </section>

    <!-- Contact CTA -->
    <section style="padding: 4rem 2rem; text-align: center;">
      <div style="max-width: 500px; margin: 0 auto;">
        <h3 class="curator-heading" style="font-size: 1.5rem; margin-bottom: 1rem;">
          Interested in a piece?
        </h3>
        <p class="curator-body" style="color: var(--curator-text-muted); margin-bottom: 2rem;">
          Contact for availability, pricing, and commission enquiries.
        </p>
        <a href="/contact" class="curator-button curator-button-primary">
          Enquire
        </a>
      </div>
    </section>
    """
  end

  defp render_default(assigns) do
    ~H"""
    <div class="min-h-screen bg-white">
      <!-- Page Header -->
      <div class="bg-gray-50 py-16 sm:py-24">
        <div class="mx-auto max-w-7xl px-6 lg:px-8">
          <div class="mx-auto max-w-2xl text-center">
            <h1 class="text-4xl font-bold tracking-tight text-gray-900 sm:text-5xl">
              The Work
            </h1>
            <p class="mt-6 text-lg leading-8 text-gray-600">
              Three distinct bodies of work united by bold colour, gestural mark-making, and an unflinching approach to emotional truth.
            </p>
          </div>
        </div>
      </div>

      <!-- Becoming - Figure Works -->
      <section id="becoming" class="py-16 sm:py-24">
        <div class="mx-auto max-w-7xl px-6 lg:px-8">
          <div class="mb-12">
            <h2 class="text-3xl font-bold tracking-tight text-gray-900">
              Becoming
            </h2>
            <p class="mt-1 text-lg text-gray-500 italic">
              Figure Works
            </p>
            <p class="mt-4 max-w-2xl text-gray-600 leading-7">
              Expressionistic figure studies that capture the human form in moments of profound introspection. The paintings ask us to witness without intruding—the universal experience of sitting with difficulty, of weathering change, of the body as vessel for emotional experience.
            </p>
          </div>

          <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-8">
            <!-- A BECOMING -->
            <div>
              <div class="aspect-[4/5] overflow-hidden rounded-lg bg-gray-100">
                <img
                  src={resolve_asset_url("/uploads/media/1763542139_3020310155b8abcf.jpg")}
                  alt="A Becoming - Expressionist figure painting"
                  class="w-full h-full object-cover hover:opacity-90 transition-opacity"
                />
              </div>
              <h3 class="mt-4 text-lg font-semibold text-gray-900">A Becoming</h3>
              <p class="text-sm text-gray-500">Oil on canvas</p>
            </div>

            <!-- Changes -->
            <div>
              <div class="aspect-[4/5] overflow-hidden rounded-lg bg-gray-100">
                <img
                  src={resolve_asset_url("/uploads/media/1763542139_22309219aa56fb95.jpg")}
                  alt="Changes - expressionistic figure study"
                  class="w-full h-full object-cover hover:opacity-90 transition-opacity"
                />
              </div>
              <h3 class="mt-4 text-lg font-semibold text-gray-900">Changes</h3>
              <p class="text-sm text-gray-500">Oil on canvas</p>
            </div>

            <!-- She Lays Down -->
            <div>
              <div class="aspect-[4/5] overflow-hidden rounded-lg bg-gray-100">
                <img
                  src={resolve_asset_url("/uploads/media/1763483281_a84d8a1756abb807.JPG")}
                  alt="She Lays Down - reclining figure"
                  class="w-full h-full object-cover hover:opacity-90 transition-opacity"
                />
              </div>
              <h3 class="mt-4 text-lg font-semibold text-gray-900">She Lays Down</h3>
              <p class="text-sm text-gray-500">Oil on canvas</p>
            </div>
          </div>
        </div>
      </section>

      <!-- Abundance - Florals -->
      <section id="abundance" class="py-16 sm:py-24 bg-gray-50">
        <div class="mx-auto max-w-7xl px-6 lg:px-8">
          <div class="mb-12">
            <h2 class="text-3xl font-bold tracking-tight text-gray-900">
              Abundance
            </h2>
            <p class="mt-1 text-lg text-gray-500 italic">
              Floral Works
            </p>
            <p class="mt-4 max-w-2xl text-gray-600 leading-7">
              Exuberant floral still lifes that celebrate colour, pattern, and the tension between order and organic profusion. These works demand attention, project outward, and perform their beauty with confidence—both natural and constructed, genuine and glamorous.
            </p>
          </div>

          <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-8">
            <!-- Ecstatic -->
            <div>
              <div class="aspect-[4/5] overflow-hidden rounded-lg bg-gray-100">
                <img
                  src={resolve_asset_url("/uploads/media/1763542139_f6add8cef5e11b3a.jpg")}
                  alt="Ecstatic - floral still life"
                  class="w-full h-full object-cover hover:opacity-90 transition-opacity"
                />
              </div>
              <h3 class="mt-4 text-lg font-semibold text-gray-900">Ecstatic</h3>
              <p class="text-sm text-gray-500">Oil on canvas</p>
            </div>

            <!-- Marilyn -->
            <div>
              <div class="aspect-[4/5] overflow-hidden rounded-lg bg-gray-100">
                <img
                  src={resolve_asset_url("/uploads/media/1763542139_1225c3b883e0ce02.jpg")}
                  alt="Marilyn - golden floral"
                  class="w-full h-full object-cover hover:opacity-90 transition-opacity"
                />
              </div>
              <h3 class="mt-4 text-lg font-semibold text-gray-900">Marilyn</h3>
              <p class="text-sm text-gray-500">Oil on canvas</p>
            </div>

            <!-- I Love Three Times -->
            <div>
              <div class="aspect-[4/5] overflow-hidden rounded-lg bg-gray-100">
                <img
                  src={resolve_asset_url("/uploads/media/1763542139_5a2e8259c48f9c2c.JPG")}
                  alt="I Love Three Times - triptych"
                  class="w-full h-full object-cover hover:opacity-90 transition-opacity"
                />
              </div>
              <h3 class="mt-4 text-lg font-semibold text-gray-900">I Love Three Times</h3>
              <p class="text-sm text-gray-500">Oil on canvas, triptych</p>
            </div>

            <!-- Red Ground Floral -->
            <div>
              <div class="aspect-[4/5] overflow-hidden rounded-lg bg-gray-100">
                <img
                  src={resolve_asset_url("/uploads/media/1763483281_62762e1c677b1d02.jpg")}
                  alt="Floral with red ground"
                  class="w-full h-full object-cover hover:opacity-90 transition-opacity"
                />
              </div>
              <h3 class="mt-4 text-lg font-semibold text-gray-900">Untitled (Red Ground)</h3>
              <p class="text-sm text-gray-500">Oil on canvas</p>
            </div>

            <!-- Coral Ground Detail -->
            <div>
              <div class="aspect-[4/5] overflow-hidden rounded-lg bg-gray-100">
                <img
                  src={resolve_asset_url("/uploads/media/1763483281_c9cd48fa716cf037.jpg")}
                  alt="Floral detail with coral ground"
                  class="w-full h-full object-cover hover:opacity-90 transition-opacity"
                />
              </div>
              <h3 class="mt-4 text-lg font-semibold text-gray-900">Untitled (Coral Ground)</h3>
              <p class="text-sm text-gray-500">Oil on canvas</p>
            </div>

            <!-- I Love Three Times Detail -->
            <div>
              <div class="aspect-[4/5] overflow-hidden rounded-lg bg-gray-100">
                <img
                  src={resolve_asset_url("/uploads/media/1763542139_3fcf4d765e5a5eeb.jpg")}
                  alt="I Love Three Times detail"
                  class="w-full h-full object-cover hover:opacity-90 transition-opacity"
                />
              </div>
              <h3 class="mt-4 text-lg font-semibold text-gray-900">I Love Three Times (Detail)</h3>
              <p class="text-sm text-gray-500">Oil on canvas, two panels</p>
            </div>
          </div>
        </div>
      </section>

      <!-- Shifting - Landscapes -->
      <section id="shifting" class="py-16 sm:py-24">
        <div class="mx-auto max-w-7xl px-6 lg:px-8">
          <div class="mb-12">
            <h2 class="text-3xl font-bold tracking-tight text-gray-900">
              Shifting
            </h2>
            <p class="mt-1 text-lg text-gray-500 italic">
              Landscape Works
            </p>
            <p class="mt-4 max-w-2xl text-gray-600 leading-7">
              Landscapes in perpetual transformation. The impasto application is extraordinary in its physicality—paint applied in thick, directional strokes that mimic geological strata. The canvas becomes a physical analogue for the terrain it depicts.
            </p>
          </div>

          <div class="grid grid-cols-1 gap-8">
            <!-- SHIFTING Diptych - Full Width -->
            <div>
              <div class="aspect-[21/9] overflow-hidden rounded-lg bg-gray-100">
                <img
                  src={resolve_asset_url("/uploads/media/1763483281_14d2d6ab6485926c.jpg")}
                  alt="Shifting - expressionist landscape diptych"
                  class="w-full h-full object-cover hover:opacity-90 transition-opacity"
                />
              </div>
              <h3 class="mt-4 text-lg font-semibold text-gray-900">Shifting</h3>
              <p class="text-sm text-gray-500">Oil on canvas, diptych</p>
            </div>

            <!-- Individual panels -->
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-8">
              <!-- SHIFTING Part 1 -->
              <div>
                <div class="aspect-[4/5] overflow-hidden rounded-lg bg-gray-100">
                  <img
                    src={resolve_asset_url("/uploads/media/1763483281_ebd1913da6ebeabd.jpg")}
                    alt="Shifting Part 1"
                    class="w-full h-full object-cover hover:opacity-90 transition-opacity"
                  />
                </div>
                <h3 class="mt-4 text-lg font-semibold text-gray-900">Shifting Part 1</h3>
                <p class="text-sm text-gray-500">Oil on canvas</p>
              </div>

              <!-- SHIFTING Part 2 -->
              <div>
                <div class="aspect-[4/5] overflow-hidden rounded-lg bg-gray-100">
                  <img
                    src={resolve_asset_url("/uploads/media/1763483281_a7b4acd750ac636c.jpg")}
                    alt="Shifting Part 2"
                    class="w-full h-full object-cover hover:opacity-90 transition-opacity"
                  />
                </div>
                <h3 class="mt-4 text-lg font-semibold text-gray-900">Shifting Part 2</h3>
                <p class="text-sm text-gray-500">Oil on canvas</p>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- Contact CTA -->
      <div class="bg-gray-900 py-16">
        <div class="mx-auto max-w-7xl px-6 lg:px-8 text-center">
          <h2 class="text-2xl font-bold text-white">
            Interested in a piece?
          </h2>
          <p class="mt-4 text-gray-300 max-w-xl mx-auto">
            Contact for availability, pricing, and commission enquiries.
          </p>
          <div class="mt-8">
            <.link
              navigate={~p"/contact"}
              class="rounded-md bg-white px-4 py-2.5 text-sm font-semibold text-gray-900 shadow-sm hover:bg-gray-100"
            >
              Enquire
            </.link>
          </div>
        </div>
      </div>

      <!-- Back to home -->
      <div class="border-t border-gray-200 bg-white">
        <div class="mx-auto max-w-7xl px-6 lg:px-8 py-8">
          <.link navigate={~p"/"} class="text-sm font-semibold text-gray-900 hover:text-gray-600">
            ← Back to home
          </.link>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Work")}
  end
end
