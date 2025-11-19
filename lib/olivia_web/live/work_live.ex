defmodule OliviaWeb.WorkLive do
  use OliviaWeb, :live_view

  @impl true
  def render(assigns) do
    cond do
      assigns[:theme] == "curator" -> render_curator(assigns)
      assigns[:theme] == "cottage" -> render_default(assigns)
      assigns[:theme] == "gallery" -> render_default(assigns)
      true -> render_default(assigns)
    end
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
                src="/uploads/media/1763542139_3020310155b8abcf.jpg"
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
                src="/uploads/media/1763542139_22309219aa56fb95.jpg"
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
                src="/uploads/media/1763542139_ba6e66be3929fdcd.jpg"
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
                src="/uploads/media/1763542139_5a2e8259c48f9c2c.JPG"
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
                src="/uploads/media/1763542139_f6add8cef5e11b3a.jpg"
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
                src="/uploads/media/1763542139_5a2e8259c48f9c2c.JPG"
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
                src="/uploads/media/1763542139_1225c3b883e0ce02.jpg"
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
                src="/uploads/media/1763483281_62762e1c677b1d02.jpg"
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
                src="/uploads/media/1763542139_e7e47b872f6b7223.JPG"
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
                src="/uploads/media/1763542139_3fcf4d765e5a5eeb.jpg"
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
                src="/uploads/media/1763483281_c9cd48fa716cf037.jpg"
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
                src="/uploads/media/1763483281_14d2d6ab6485926c.jpg"
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
                src="/uploads/media/1763483281_ebd1913da6ebeabd.jpg"
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
    <div style="min-height: 100vh; display: flex; align-items: center; justify-content: center; padding: 2rem;">
      <div style="text-align: center;">
        <h1 style="font-size: 2rem; margin-bottom: 1rem;">Work</h1>
        <p style="color: #666; margin-bottom: 2rem;">This page is optimized for the Curator theme.</p>
        <a href="/set-theme/curator" style="color: #c45a4a; text-decoration: underline;">Switch to Curator theme</a>
        <span style="margin: 0 1rem; color: #999;">or</span>
        <a href="/series" style="color: #c45a4a; text-decoration: underline;">View Series</a>
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
