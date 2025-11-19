# Theme Development - Do's and Don'ts

Lessons learned during Curator theme development. This document helps avoid common pitfalls when working with the Olivia site's theme system.

---

## Flash Messages

### DON'T
- Render flash messages in `root.html.heex` for themed layouts
- Use `@flash` in static HTML layouts (it's not available there)

### DO
- Render flash messages inside each LiveView's `render_*` function
- Use `Phoenix.Flash.get(@flash, :info)` and `Phoenix.Flash.get(@flash, :error)`

**Example pattern for themed LiveViews:**
```elixir
defp render_curator(assigns) do
  ~H"""
  <!-- Flash Messages - MUST be in LiveView render, not root.html.heex -->
  <div :if={Phoenix.Flash.get(@flash, :info) || Phoenix.Flash.get(@flash, :error)} style="...">
    <p :if={Phoenix.Flash.get(@flash, :info)} style="background: var(--curator-sage); ...">
      <%= Phoenix.Flash.get(@flash, :info) %>
    </p>
    <p :if={Phoenix.Flash.get(@flash, :error)} style="background: var(--curator-coral); ...">
      <%= Phoenix.Flash.get(@flash, :error) %>
    </p>
  </div>

  <!-- Rest of content -->
  """
end
```

**Why:** LiveView flash messages live in the socket and are only accessible in LiveView templates, not in the static root layout.

---

## Asset Paths

### DON'T
```html
<link href={~p"/assets/app.css"} />
<script src={~p"/assets/app.js"}></script>
```

### DO
```html
<link href={~p"/assets/css/app.css"} />
<script src={~p"/assets/js/app.js"}></script>
```

**Why:** Phoenix assets are compiled into subdirectories. Using wrong paths causes 404 errors.

---

## CSS and Media Queries

### DON'T
```html
<nav style="display: flex;">
```
Then expect media queries to work.

### DO
```html
<nav class="curator-nav">
```
```css
.curator-nav {
  display: flex;
}

@media (max-width: 768px) {
  .curator-nav {
    display: none;
  }
}
```

**Why:** Inline styles have highest specificity and cannot be overridden by media queries in CSS.

---

## Theme Architecture

### How themes work:
1. `ThemePlug` reads theme from cookie (persists 1 year)
2. Sets theme in session
3. `ThemeHook` reads session and assigns to socket
4. LiveViews check `assigns[:theme]` to select render function

### Adding a new theme:

1. **Register in ThemeComponents** (`lib/olivia_web/components/theme_components.ex`):
   ```elixir
   def theme_ids, do: ["curator", "gallery", "cottage", "your-new-theme"]
   ```

2. **Create layout** (`lib/olivia_web/components/layouts/your_theme.html.heex`)

3. **Add render functions** to each LiveView:
   - `home_live.ex` → `render_your_theme/1`
   - `page_live.ex` → `render_your_theme/1`
   - `contact_live.ex` → `render_your_theme/1`
   - `work_live.ex` → `render_your_theme/1`

4. **Update the render dispatch** in each LiveView:
   ```elixir
   def render(assigns) do
     cond do
       assigns[:theme] == "curator" -> render_curator(assigns)
       assigns[:theme] == "your-new-theme" -> render_your_theme(assigns)
       # ...
       true -> render_default(assigns)
     end
   end
   ```

---

## Special Page Layouts

### DON'T
- Assume special layouts exist in all themes
- Only implement special layouts in `render_default`

### DO
- Check each theme's render function for special page handling
- Implement special layouts (about, hotels-designers, etc.) in ALL themes

**Example from page_live.ex:**
```elixir
defp render_default(assigns) do
  case assigns.page.slug do
    "about" -> render_about_default(assigns)
    "hotels-designers" -> render_hotels_designers_default(assigns)
    _ -> render_page_default(assigns)
  end
end

defp render_curator(assigns) do
  case assigns.page.slug do
    "about" -> render_about_curator(assigns)
    "hotels-designers" -> render_hotels_designers_curator(assigns)  # Don't forget this!
    _ -> render_page_curator(assigns)
  end
end
```

**Current gap:** The "hotels-designers" special layout only exists in `render_default`. It needs to be added to gallery, cottage, and curator themes.

---

## Images and Media

### Referencing uploaded media:
```elixir
src="/uploads/media/filename.png"
```

### Finding artist photos:
Query the media table for files tagged/titled appropriately:
```sql
SELECT id, title, file_name FROM media_files
WHERE title ILIKE '%artist%' OR title ILIKE '%portrait%';
```

Media IDs for artist photos:
- ID 3: Professional portrait
- ID 16: Gallery shot with artwork

---

## Mailer Error Handling

### DON'T
```elixir
Communications.deliver_notification(enquiry)
# Crashes if email delivery fails
```

### DO
```elixir
case Communications.deliver_notification(enquiry) do
  {:ok, _} -> :ok
  {:error, reason} ->
    Logger.warning("Failed to send notification: #{inspect(reason)}")
    :ok  # Don't fail the request
end
```

**Why:** Email delivery failures shouldn't crash user-facing operations.

---

## Navigation Components

### Mobile responsive navigation:
- Use a hamburger menu component
- Include both mobile and desktop nav in the layout
- Toggle visibility with CSS classes, not JavaScript where possible

### Theme selector:
Located at `/theme` endpoint via `ThemeController.set/2`.

---

## Testing Theme Changes

1. **Switch themes** via cookie or `/theme?theme=curator`
2. **Test on mobile viewport** - many issues only appear at smaller sizes
3. **Check flash messages** - submit a contact form to verify they display
4. **Verify all special pages** - about, hotels-designers, contact, etc.

---

## File Locations Reference

- **Theme layouts:** `lib/olivia_web/components/layouts/`
- **Theme components:** `lib/olivia_web/components/theme_components.ex`
- **Theme plug:** `lib/olivia_web/plugs/theme_plug.ex`
- **Theme hook:** `lib/olivia_web/live/theme_hook.ex`
- **LiveViews with themes:** `lib/olivia_web/live/`
  - `home_live.ex`
  - `page_live.ex`
  - `contact_live.ex`
  - `work_live.ex`

---

*Last updated: 2024-11-19 - Curator theme development session*

---

## Additional Notes from "Original" Theme Development (2024-11-19)

### Responsive Navigation Fix for Inline Styles

#### The Problem
When themes use inline styles with `display: none`, Tailwind's responsive classes like `md:flex` cannot override them due to CSS specificity rules.

```html
<!-- This DOES NOT work -->
<nav style="display: none; gap: 2rem;" class="md:flex">
```

#### The Solution
Add explicit media queries in the theme's `<style>` block that use `!important`:

```css
/* Responsive navigation for Gallery/Cottage themes */
@media (min-width: 768px) {
  .hidden.md\:flex {
    display: flex !important;
  }
  .md\:hidden {
    display: none !important;
  }
}
```

Then use Tailwind classes without inline `display`:
```html
<nav style="gap: 2rem; align-items: center;" class="hidden md:flex">
```

**Why this works:** The CSS media query with `!important` overrides the `.hidden` class at the breakpoint, while `hidden` provides the default mobile state.

---

### Hardcoded Content for Curated Themes

#### When to Use
When a theme requires specific curated content (like an art exhibition) rather than database-driven content.

#### Pattern for Series Pages
```elixir
def mount(%{"slug" => slug}, _session, socket) do
  # Handle hardcoded series for curated themes
  if slug in ["becoming", "abundance", "shifting"] do
    title = case slug do
      "becoming" -> "Becoming"
      "abundance" -> "Abundance"
      "shifting" -> "Shifting"
    end

    {:ok,
     socket
     |> assign(:page_title, "#{title} - Olivia Tew")
     |> assign(:slug, slug)
     |> assign(:series, %{title: title, summary: "", body_md: nil})
     |> assign(:artworks, [])}
  else
    # Fall back to database lookup for other themes
    series = Content.get_series_by_slug!(slug, published: true)
    # ...
  end
end
```

#### Pattern for Conditional Rendering
Use separate `if` blocks rather than nested conditionals:
```elixir
defp render_default(assigns) do
  ~H"""
  <%= if @slug == "becoming" do %>
    <!-- Becoming content -->
  <% end %>

  <%= if @slug == "abundance" do %>
    <!-- Abundance content -->
  <% end %>

  <%= if @slug not in ["becoming", "abundance", "shifting"] do %>
    <!-- Database fallback -->
  <% end %>
  """
end
```

**Why:** Avoids HEEx syntax errors with nested if/else and makes each section self-contained.

---

### Qualifying Previous Statements

#### On "Special Layouts in ALL Themes"
The document states special layouts should exist in all themes. However:
- **Acceptable exception:** If a theme is curated/hardcoded, it may intentionally not support certain database-driven pages
- **Better guidance:** Document which pages each theme supports and provide graceful fallbacks

#### On CSS Classes vs Inline Styles
The document advises using CSS classes over inline styles for media query support. However:
- **Hybrid approach works:** Use inline styles for theme-specific properties (colours, spacing) and Tailwind classes for responsive behaviour
- **The `!important` media query pattern** resolves the specificity issue while keeping theme styles encapsulated

---

### Theme-Specific Image Curation

When curating images for a themed exhibition:

1. **Categorise by subject matter:** Figures, florals, landscapes
2. **Identify hero images:** Choose the strongest work for each category
3. **Consider aspect ratios:** Diptychs need special treatment (21:9 vs 4:5)
4. **Document image URLs:** Keep a reference of which images go where

**Example curated structure:**
- **Becoming (3 figures):** A Becoming, Changes, She Lays Down
- **Abundance (6 florals):** Ecstatic, Marilyn, I Love Three Times + 3 details
- **Shifting (3 landscapes):** Diptych full, Part 1, Part 2

---

### Root Layout Architecture

The site uses conditional root layouts in `root.html.heex`:

```elixir
<%= if @theme == "gallery" do %>
  <!-- Complete HTML structure for Gallery theme -->
<% end %>

<%= if @theme == "cottage" do %>
  <!-- Complete HTML structure for Cottage theme -->
<% end %>

<%= if @theme not in ["gallery", "cottage", "curator"] do %>
  <!-- Original/default theme uses components -->
  <OliviaWeb.Layouts.navigation />
  {@inner_content}
  <OliviaWeb.Layouts.footer />
<% end %>
```

**Key difference:** Themes with inline styles (Gallery, Cottage) have complete HTML in root.html.heex, while the Original theme uses component-based layouts from `layouts.ex`.

---

### Testing Checklist for New Themes

- [ ] Theme selector visible on desktop (>768px)
- [ ] Theme selector works in mobile menu
- [ ] All four themes switch correctly
- [ ] Special pages render (about, hotels-designers, contact)
- [ ] Series index shows correct content (hardcoded or database)
- [ ] Individual series pages render
- [ ] Flash messages display on form submission
- [ ] Newsletter subscription works
- [ ] Images load correctly
- [ ] Mobile responsive layout works

---

*Updated: 2024-11-19 - Original theme development session*

---

## Gallery Theme Development (2024-11-19)

### Curatorial Approach: View Images Before Designing

#### The Process
When building a theme around actual artwork, don't design first. Instead:

1. **Query the database** to see what exists:
   ```elixir
   import Ecto.Query
   Olivia.Repo.all(from m in Olivia.Media.MediaFile,
     where: m.status != "archived",
     select: %{id: m.id, filename: m.filename, alt_text: m.alt_text, asset_type: m.asset_type}
   )
   ```

2. **Review each image** to understand subject matter, aspect ratios, and visual weight

3. **Categorise into bodies of work** based on subject and style:
   - Becoming (Figure Works): 3 pieces
   - Abundance (Floral Works): 6 pieces
   - Shifting (Landscape Works): 3 pieces

4. **Select hero images** - choose the strongest piece from each category for prominent placement

**Why:** Designing around actual content rather than placeholders produces more cohesive, intentional results.

---

### Direct Media URL Pattern

#### When to Use
For curated themes with specific artwork placement, hardcode the URLs directly rather than using dynamic queries.

```elixir
defp render_gallery(assigns) do
  ~H"""
  <!-- Hero Image -->
  <img src="/uploads/media/1763542139_3020310155b8abcf.jpg" alt="A Becoming" />

  <!-- Grid of selected works -->
  <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 1.5rem;">
    <img src="/uploads/media/1763262332_e8e18c1dd88bd64a.jpg" alt="Changes" />
    <img src="/uploads/media/1763245421_9d0ae99bed52c4f1.png" alt="Ecstatic" />
    <img src="/uploads/media/1763245431_a32125c01d1a2ef6.png" alt="Marilyn" />
    <img src="/uploads/media/1763262391_c4ddd6b2e5ecf7ed.jpg" alt="Diptych - Shifting Part 1" />
  </div>
  """
end
```

**When NOT to use:** If the theme needs to display user-configurable content or pull from database collections.

**Document your selections:** Keep a reference of which image IDs map to which URLs and their intended placement.

---

### Design System Documentation

#### Gallery Theme Colours
Document specific colour values to maintain consistency across all pages:

```css
/* Gallery Theme Palette */
--gallery-dark: #2c2416;        /* Primary text, headings */
--gallery-muted: #6b5d54;       /* Body text, buttons */
--gallery-accent: #8b7355;      /* Labels, links, decorative */
--gallery-divider: #c4b5a0;     /* Borders, divider lines */
--gallery-cream: #faf8f5;       /* Backgrounds, inputs */
--gallery-light-border: #e8e6e3; /* Subtle dividers */
```

#### Typography Patterns
```css
/* Gallery Labels */
font-size: 0.75rem;
text-transform: uppercase;
letter-spacing: 0.1em;
color: #8b7355;

/* Gallery Headings */
font-size: 2.5rem;
color: #2c2416;

/* Gallery Body */
font-size: 1.125rem;
color: #6b5d54;
line-height: 1.8;
```

#### Visual Elements
- **Divider lines:** 60px wide, 1px height, #c4b5a0 colour
- **Image frames:** White background, subtle shadow, padding
- **Section spacing:** 5rem vertical padding for major sections

**Why document this:** Ensures contact forms, about pages, and artwork pages all feel like the same theme.

---

### Multi-Page Consistency

#### Pages That Need Theme Implementation
When creating a curated theme, implement ALL public pages:

1. **Home (home_live.ex)** - Hero, collection previews, featured works
2. **Work (work_live.ex)** - Full artwork catalogue by category
3. **About (page_live.ex with slug check)** - Artist bio, process, studio
4. **Contact (contact_live.ex)** - Styled form matching theme

#### Conditional Rendering for Special Pages
```elixir
defp render_gallery(assigns) do
  case assigns.page.slug do
    "about" -> render_about_gallery(assigns)
    "hotels-designers" -> render_hotels_designers_gallery(assigns)
    _ -> render_page_gallery(assigns)
  end
end
```

**Why:** Users can navigate between pages and expect consistent styling.

---

### Database Schema Awareness

#### Know Your Fields
The MediaFile schema uses specific field names:
- `filename` (not `title`)
- `alt_text` (for image descriptions)
- `asset_type` (image, document, etc.)
- `asset_role` (hero, thumbnail, etc.)
- `status` (active, archived, quarantine)

Query correctly:
```elixir
# DO
from m in MediaFile, where: m.status != "archived"

# DON'T - status is a string, not atom
from m in MediaFile, where: m.status != :archived
```

---

### Qualifying Previous Statements

#### On "CSS Classes vs Inline Styles"
The document recommends CSS classes for media query support. However:

**Gallery theme successfully uses mostly inline styles** because:
- Each theme is self-contained in its render function
- No external CSS file to manage
- Colours and spacing are easily visible in context
- Media queries are only needed for navigation (handled in root layout)

**Hybrid approach:** Use inline styles for theme-specific values, but use classes only when responsive behaviour is truly needed.

#### On "Implement Special Layouts in ALL Themes"
The document states all themes need special page implementations. However:

**Practical approach:** Implement special pages when the theme is actively used. The Gallery theme now has:
- Home page with full curation
- Work page with categorised artwork
- About page with artist photos and bio
- Contact page with styled form

But doesn't need `hotels-designers` if that page isn't relevant to the Gallery aesthetic.

---

### Testing Gallery Theme Changes

After implementing, verify:
- [ ] Home hero image loads correctly
- [ ] All artwork images display (check console for 404s)
- [ ] Collection grids align properly
- [ ] About page artist photos appear
- [ ] Contact form styling matches theme
- [ ] Newsletter signup works
- [ ] Navigation between pages maintains theme
- [ ] Mobile viewport shows content correctly
- [ ] Back-to-home links work

---

*Updated: 2024-11-19 - Gallery theme curation session*

---

## Cottage Theme Development (2024-11-19)

### Curatorial Workflow: Let AI Analysis Inform Organisation

#### The Novel Technique
The Cottage theme was curated using AI-generated artwork analyses stored in the `media_analyses` table. This provided:

1. **Rich contextual descriptions** beyond simple alt text
2. **Consistent vocabulary** for describing technique and style
3. **Curatorial connections** between works (artistic influences, emotional resonance)

**Query pattern for curated content:**
```sql
SELECT
  m.id, m.filename, m.alt_text,
  a.analysis_data->'analysis'->'artwork_identification' as identification,
  a.analysis_data->'analysis'->'formal_analysis' as formal,
  a.analysis_data->'analysis'->'contextual_interpretation' as context
FROM media m
LEFT JOIN LATERAL (
  SELECT analysis_data FROM media_analyses
  WHERE media_id = m.id
  ORDER BY inserted_at DESC LIMIT 1
) a ON true
WHERE m.status != 'archived'
ORDER BY m.inserted_at DESC;
```

**Why this works:** The AI analyses provide consistent, detailed descriptions that can be synthesised into cohesive curatorial text across multiple pages.

---

### Organising Bodies of Work

#### Pattern: Theme-Appropriate Groupings

Different themes can organise the same artwork differently:

| Theme | Organisation | Logic |
|-------|-------------|-------|
| Gallery | Formal categories | Museum-style classification |
| Cottage | Bodies of work | Artist's practice narrative |

**Cottage organisation:**
- **Becoming** - Figure works about emergence and transformation
- **Abundance** - Florals celebrating colour and joy
- **Shifting** - Landscapes in perpetual transformation

The naming creates a narrative arc (becoming → abundance → shifting) rather than just categorical labels.

---

### In-Template Conditional Rendering

#### Pattern: Single Function, Multiple Sections

The Cottage theme's `page_live.ex` uses a simpler pattern than the case-statement approach:

```elixir
defp render_cottage(assigns) do
  ~H"""
  <%= if @page.slug == "about" do %>
    <!-- About page with specific layout -->
    <section>...</section>
    <section>...</section>
    <section>...</section>
  <% else %>
    <!-- Generic page layout -->
    <div>
      <h1><%= @page.title %></h1>
      <div :for={section <- @sections}>...</div>
    </div>
  <% end %>
  """
end
```

**Advantages over separate functions:**
- Keeps theme context self-contained
- Easier to see overall structure
- No function explosion for each special page

**Disadvantages:**
- Can become unwieldy with many special pages
- Harder to test individual layouts

**Guidance:** Use in-template conditionals for 1-2 special pages; use separate functions for 3+.

---

### Hybrid Static/Dynamic Content

#### Pattern: Hardcoded Layouts with Dynamic Elements

The Cottage about page is fully hardcoded but includes a dynamic newsletter form:

```elixir
<!-- Hardcoded structure and images -->
<section style="padding: 5rem 1rem; background: white;">
  <div style="max-width: 500px; margin: 0 auto; text-align: center;">
    <h2 class="cottage-heading">Stay in Touch</h2>

    <!-- Dynamic form handled by LiveView -->
    <form phx-submit="subscribe">
      <input name="email" type="email" required />
      <button type="submit" class="cottage-button">Subscribe</button>
    </form>
  </div>
</section>
```

**Key insight:** Hardcoded themes can still include interactive elements via `phx-submit` handlers.

---

### Anchor Links for In-Page Navigation

#### Technique: Section IDs with Hash Links

The home page links to specific sections on the work page:

```elixir
# Home page
<a href="/work#becoming">Becoming</a>
<a href="/work#abundance">Abundance</a>
<a href="/work#shifting">Shifting</a>

# Work page
<section id="becoming">...</section>
<section id="abundance">...</section>
<section id="shifting">...</section>
```

**Browser behaviour:** Works natively without JavaScript - browser scrolls to anchor after page loads.

---

### CSS Custom Property Consistency

#### Technique: Reference Design Document Variables

The Cottage theme uses variables defined in the concept document:

```css
/* From COTTAGE_THEME_CONCEPT.md */
--cottage-cream: #FAF7F5;
--cottage-beige: #F5F1ED;
--cottage-taupe: #E8E3DD;
--cottage-wisteria: #C8A7D8;
--cottage-wisteria-deep: #A88AB7;
--cottage-text-dark: #4A3F4B;
--cottage-text-medium: #6B5D66;
```

**Implementation pattern:**
```elixir
<section style="background: var(--cottage-beige); padding: 5rem 1rem;">
  <h2 class="cottage-heading" style="color: var(--cottage-text-dark);">
    The Practice
  </h2>
</section>
```

**Why reference the document:** Ensures all theme implementations match the original design specification.

---

### Image Selection Strategy

#### Technique: Contextual Image Selection

Different contexts require different image selections from the same pool:

| Context | Image | Why |
|---------|-------|-----|
| Hero (home) | Marilyn (garden light) | Golden warmth, welcoming, accessible |
| Hero (gallery theme) | A Becoming | Bold, dramatic, formal |
| About portrait | Exhibition photo | Shows artist with work |
| About practice | A Becoming | Illustrates technique discussed |
| Collectors section | I Love Three Times | Shows work in domestic context |

**Key insight:** The same artwork can serve different purposes depending on context.

---

### Qualifying Previous Document Statements

#### On "Query the Database to See What Exists"

The document recommends querying to see what images exist. **Refinement:**

Query with AI analyses gives richer context:
```sql
-- Not just this
SELECT id, filename FROM media;

-- But this
SELECT m.*, a.analysis_data FROM media m
LEFT JOIN media_analyses a ON a.media_id = m.id;
```

The analysis provides enough context to make curatorial decisions without viewing each image.

---

#### On "Direct Media URL Pattern"

The document shows hardcoding URLs. **Qualification:**

**Be precise with filenames.** The media table stores the actual uploaded filename with timestamps:
- `1763542139_1225c3b883e0ce02.jpg` (correct)
- `marilyn.jpg` (incorrect - won't exist)

Always query the database to get exact filenames rather than guessing.

---

#### On "Implement ALL Public Pages"

The previous note says implement all public pages. **Nuance:**

Some pages can use generic rendering with the `else` branch:
```elixir
<% else %>
  <!-- Generic page layout -->
  <h1><%= @page.title %></h1>
  <div :for={section <- @sections}>
    <%= raw(Earmark.as_html!(section.content_md || "")) %>
  </div>
<% end %>
```

This handles `hotels-designers`, `collect`, and any future pages without explicit implementation.

---

### Novel Pattern: Signature Elements

#### Technique: Artist Signature as Design Element

The Cottage theme concept includes an artist signature element:

```elixir
<div class="cottage-accent" style="font-style: italic; margin-top: 2rem;">
  ~ Olivia
</div>
```

This personal touch reinforces the "cottage studio" aesthetic but wasn't implemented in this session. Consider adding to the about page bio section.

---

### Testing Notes

The Cottage theme was verified via browser snapshots:
- Home page sections render correctly
- Work page has all three series (Becoming, Abundance, Shifting)
- About page shows portrait, practice section, studio images
- Contact form styling matches theme

**Note:** The work page uses 3 distinct section IDs that can be located individually.

---

### Summary: Cottage Theme Innovations

1. **AI-informed curation** - Used stored analyses to write curatorial text
2. **Narrative organisation** - Bodies of work tell a story (becoming → abundance → shifting)
3. **In-template conditionals** - Simpler pattern for few special pages
4. **Anchor navigation** - Hash links for direct section access
5. **Hybrid static/dynamic** - Hardcoded layouts with interactive forms
6. **Contextual image selection** - Same image, different purposes based on context

---

*Updated: 2024-11-19 - Cottage theme curation session*
