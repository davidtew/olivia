defmodule OliviaWeb.ProcessLive do
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
        Process
      </h1>
      <p class="curator-body" style="color: var(--curator-text-muted); max-width: 600px; margin: 0 auto;">
        Behind the finished work—the testing, the iterations, the domestic rituals of making.
      </p>
    </section>

    <!-- Process Introduction -->
    <section style="padding: 3rem 2rem;">
      <div style="max-width: 700px; margin: 0 auto;">
        <blockquote class="curator-heading-italic" style="font-size: 1.25rem; line-height: 1.6; color: var(--curator-text-light); margin-bottom: 2rem; text-align: center;">
          "There's something testing and ceremonial about viewing paintings outside in natural light—it's where the artist sees colour relationships without artificial interference, where decisions get made about what works and what doesn't."
        </blockquote>
        <div class="curator-divider"></div>
      </div>
    </section>

    <!-- From Nascent to Becoming -->
    <section style="padding: 4rem 2rem; background: var(--curator-bg-warm);">
      <div style="max-width: 1200px; margin: 0 auto;">
        <div style="margin-bottom: 3rem;">
          <h2 class="curator-heading" style="font-size: 1.75rem; margin-bottom: 1rem;">
            From Nascent to Becoming
          </h2>
          <p class="curator-body" style="color: var(--curator-text-muted); max-width: 600px;">
            This process documentation captures 'A BECOMING' in its nascent state—before the figure fully resolved from the gestural ground. The photograph documents the moment of potential, before decisions about where the figure resolves and where it remains in flux.
          </p>
        </div>

        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(400px, 1fr)); gap: 3rem; align-items: start;">
          <!-- Process Shot -->
          <div>
            <div class="curator-artwork-card" style="margin-bottom: 1rem;">
              <img
                src="/uploads/media/1763542139_ba6e66be3929fdcd.jpg"
                alt="A Becoming in progress on outdoor easel"
                style="width: 100%; display: block;"
              />
            </div>
            <p class="curator-body" style="font-size: 0.875rem; color: var(--curator-text-muted);">
              <strong>Nascent stage</strong> — The figure has not yet fully resolved from the gestural ground of flesh pinks, ochres, and siennas.
            </p>
          </div>

          <!-- Final Work -->
          <div>
            <div class="curator-artwork-card" style="margin-bottom: 1rem;">
              <img
                src="/uploads/media/1763542139_3020310155b8abcf.jpg"
                alt="A BECOMING - finished work"
                style="width: 100%; display: block;"
              />
            </div>
            <p class="curator-body" style="font-size: 0.875rem; color: var(--curator-text-muted);">
              <strong>Resolved</strong> — The figure emerges from and dissolves into the painterly ground, the tension between construction and dissolution productive.
            </p>
          </div>
        </div>
      </div>
    </section>

    <!-- Light Studies -->
    <section style="padding: 4rem 2rem;">
      <div style="max-width: 1200px; margin: 0 auto;">
        <div style="margin-bottom: 3rem;">
          <h2 class="curator-heading" style="font-size: 1.75rem; margin-bottom: 1rem;">
            Natural Light Testing
          </h2>
          <p class="curator-body" style="color: var(--curator-text-muted); max-width: 600px;">
            Viewing work in different lighting conditions reveals different truths. The golden ground that glows outdoors in sunlight takes on a different character under studio lighting—both valid, both revealing different aspects of the painting's nature.
          </p>
        </div>

        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(350px, 1fr)); gap: 3rem; align-items: start;">
          <!-- Marilyn Outdoor -->
          <div>
            <div class="curator-artwork-card" style="margin-bottom: 1rem;">
              <img
                src="/uploads/media/1763542139_1225c3b883e0ce02.jpg"
                alt="Marilyn in natural garden light"
                style="width: 100%; display: block;"
              />
            </div>
            <p class="curator-body" style="font-size: 0.875rem; color: var(--curator-text-muted);">
              <strong>Natural light</strong> — The golden ground positively glows with warmth that studio lighting couldn't capture.
            </p>
          </div>

          <!-- Marilyn Indoor -->
          <div>
            <div class="curator-artwork-card" style="margin-bottom: 1rem;">
              <img
                src="/uploads/media/1763542139_e7e47b872f6b7223.JPG"
                alt="Marilyn in studio lighting"
                style="width: 100%; display: block;"
              />
            </div>
            <p class="curator-body" style="font-size: 0.875rem; color: var(--curator-text-muted);">
              <strong>Studio light</strong> — More controlled, revealing the structural relationships between forms and the precision of mark-making.
            </p>
          </div>
        </div>
      </div>
    </section>

    <!-- Context Studies -->
    <section style="padding: 4rem 2rem; background: var(--curator-bg-warm);">
      <div style="max-width: 1200px; margin: 0 auto;">
        <div style="margin-bottom: 3rem;">
          <h2 class="curator-heading" style="font-size: 1.75rem; margin-bottom: 1rem;">
            Living With Work
          </h2>
          <p class="curator-body" style="color: var(--curator-text-muted); max-width: 600px;">
            Work that lives with the maker, tested in the crucible of daily viewing. Different contexts unlock different colour readings—the same triptych reveals cool tones against a grey wall that were less visible against pink.
          </p>
        </div>

        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(350px, 1fr)); gap: 3rem; align-items: start;">
          <!-- I Love Three Times - Pink Wall -->
          <div>
            <div class="curator-artwork-card" style="margin-bottom: 1rem;">
              <img
                src="/uploads/media/1763542139_5a2e8259c48f9c2c.JPG"
                alt="I Love Three Times on pink wall"
                style="width: 100%; display: block;"
              />
            </div>
            <p class="curator-body" style="font-size: 0.875rem; color: var(--curator-text-muted);">
              <strong>Pink wall</strong> — The warm context emphasizes the jewel tones and warmth of the flowers.
            </p>
          </div>

          <!-- I Love Three Times - Grey Wall -->
          <div>
            <div class="curator-artwork-card" style="margin-bottom: 1rem;">
              <img
                src="/uploads/media/1763542139_3fcf4d765e5a5eeb.jpg"
                alt="I Love Three Times on grey-blue wall"
                style="width: 100%; display: block;"
              />
            </div>
            <p class="curator-body" style="font-size: 0.875rem; color: var(--curator-text-muted);">
              <strong>Grey-blue wall</strong> — The cooler setting reveals tones that were hidden, and the vessel's patterns become more prominent.
            </p>
          </div>
        </div>
      </div>
    </section>

    <!-- The Outdoor Studio -->
    <section style="padding: 4rem 2rem;">
      <div style="max-width: 900px; margin: 0 auto; text-align: center;">
        <h2 class="curator-heading" style="font-size: 1.75rem; margin-bottom: 1.5rem;">
          The Outdoor Studio
        </h2>
        <p class="curator-body" style="color: var(--curator-text-muted); margin-bottom: 2rem;">
          The domestic garden studio—potted plants, turquoise fence, brick houses in the background. Paint palettes with mixed flesh tones, brushes, mixing surfaces arranged on a wooden deck. There's something testing and ceremonial about viewing paintings outside in natural light.
        </p>
        <div class="curator-artwork-card" style="max-width: 700px; margin: 0 auto;">
          <img
            src="/uploads/media/1763542139_ba6e66be3929fdcd.jpg"
            alt="Artist's outdoor workspace with paintings in progress"
            style="width: 100%; display: block;"
          />
        </div>
      </div>
    </section>

    <!-- Back to Work CTA -->
    <section style="padding: 4rem 2rem; background: var(--curator-bg-warm); text-align: center;">
      <div style="max-width: 500px; margin: 0 auto;">
        <h3 class="curator-heading" style="font-size: 1.5rem; margin-bottom: 1rem;">
          View the Collection
        </h3>
        <p class="curator-body" style="color: var(--curator-text-muted); margin-bottom: 2rem;">
          Explore the finished works across all three bodies of work.
        </p>
        <a href="/work" class="curator-button">
          View Work
        </a>
      </div>
    </section>
    """
  end

  defp render_default(assigns) do
    ~H"""
    <div style="min-height: 100vh; display: flex; align-items: center; justify-content: center; padding: 2rem;">
      <div style="text-align: center;">
        <h1 style="font-size: 2rem; margin-bottom: 1rem;">Process</h1>
        <p style="color: #666; margin-bottom: 2rem;">This page is optimized for the Curator theme.</p>
        <a href="/set-theme/curator" style="color: #c45a4a; text-decoration: underline;">Switch to Curator theme</a>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Process")}
  end
end
