# Theme Implementation Guide for Olivia Portfolio

## Executive Summary

This guide documents the challenges, patterns, and best practices for implementing themes in the Olivia Portfolio Phoenix LiveView application. It's based on implementing the "Gallery" theme alongside the "Original" theme.

**Key Insight**: Themes in this app are not just CSS changes - they fundamentally alter the HTML structure, layout, typography, and component rendering. This requires careful coordination across multiple layers.

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Hard Problems Encountered](#hard-problems-encountered)
3. [The DO's - Critical Success Patterns](#the-dos---critical-success-patterns)
4. [The DON'Ts - Common Pitfalls](#the-donts---common-pitfalls)
5. [Step-by-Step Theme Creation Checklist](#step-by-step-theme-creation-checklist)
6. [File-by-File Implementation Guide](#file-by-file-implementation-guide)
7. [Testing and Validation](#testing-and-validation)
8. [Troubleshooting Guide](#troubleshooting-guide)

---

## Architecture Overview

### How Themes Work in This Application

```
User Cookie/Session (theme="gallery")
         ↓
    ThemeHook (lib/olivia_web/live/theme_hook.ex)
         ↓
    Assigns[:theme] set on socket
         ↓
    root.html.heex - Conditional HTML structure
         ↓
    LiveView render/1 - Conditional rendering
         ↓
    render_gallery/1 or render_default/1
```

### Key Files Involved

1. **Session/State Management**
   - `lib/olivia_web/live/theme_hook.ex` - Sets `assigns[:theme]`
   - `lib/olivia_web/controllers/theme_controller.ex` - Handles theme toggle
   - `lib/olivia_web/plugs/theme_plug.ex` - Loads theme from session

2. **Layout Layer**
   - `lib/olivia_web/components/layouts/root.html.heex` - Root HTML wrapper
   - `lib/olivia_web/components/layouts.ex` - Layout components
   - `lib/olivia_web/components/layouts/gallery.html.heex` - (NOT USED - see mistakes)

3. **Page Rendering Layer**
   - `lib/olivia_web/live/home_live.ex`
   - `lib/olivia_web/live/page_live.ex`
   - `lib/olivia_web/live/contact_live.ex`
   - `lib/olivia_web/live/series_live/index.ex`
   - `lib/olivia_web/live/series_live/show.ex`
   - `lib/olivia_web/live/artwork_live/show.ex`

---

## Hard Problems Encountered

### 1. **The Layout Trap - Hardcoded Structure**

**Problem**: Initially, `root.html.heex` always rendered the same layout structure with `<OliviaWeb.Layouts.navigation>` and `<OliviaWeb.Layouts.footer>` components, regardless of theme.

**Why Hard**:
- The entire HTML structure (header, navigation, footer) was identical for both themes
- Changing CSS alone couldn't achieve the Gallery aesthetic
- Required fundamental restructuring of the root layout

**Solution**: Made `root.html.heex` conditional at the top level:
```heex
<%= if assigns[:theme] == "gallery" do %>
  <!-- Completely different HTML structure -->
<% else %>
  <!-- Original HTML structure -->
<% end %>
```

**Lesson**: Themes that require different layouts need conditional HTML, not just CSS.

---

### 2. **The Inline vs. Class Styling Confusion**

**Problem**: Gallery theme uses inline styles throughout, while Original theme uses Tailwind CSS classes.

**Why Hard**:
- Two completely different styling approaches in the same codebase
- Easy to accidentally mix them
- Maintenance nightmare if not carefully organized

**Solution**: Establish clear convention:
- **Gallery theme**: Inline styles + minimal CSS classes (`.gallery-heading`, `.gallery-script`, `.gallery-form`)
- **Original theme**: Tailwind CSS classes only

**Lesson**: Pick one styling approach per theme and stick to it religiously.

---

### 3. **Markdown Rendering Nightmare**

**Problem**: CMS content is rendered from Markdown using Earmark. The generated HTML elements (h1, h2, p, etc.) inherit no theme styling.

**Why Hard**:
- Earmark generates raw HTML with no classes or styles
- Cannot directly style the Markdown output through inline styles
- Generated elements don't inherit parent font-family for specificity reasons
- Must use CSS cascade to style generated content

**Initial Mistake**: Applied styles only to the wrapper div, expecting inheritance:
```heex
<div style="color: #4a4034; font-size: 1.125rem;">
  <%= raw(Earmark.as_html!(section.content_md)) %>
</div>
```

**Solution**: Added specific CSS rules targeting generated elements:
```css
main h1, main h2, main h3 {
  font-family: 'Cormorant Garamond', Georgia, serif;
  font-weight: 400;
  /* ... */
}
```

**Lesson**: Always account for dynamically generated HTML. Use CSS rules in `<style>` tags for markdown content.

---

### 4. **The Form Styling Challenge**

**Problem**: Phoenix form components (`<.input>`, `<.form>`) generate their own HTML with default classes.

**Why Hard**:
- Form components are defined in `core_components.ex`
- They have built-in Tailwind classes
- Can't easily override without modifying components or using high-specificity CSS

**Solution**:
1. Added `.gallery-form` class wrapper to form element
2. Created comprehensive CSS rules targeting form inputs within `.gallery-form`
3. Styled by element type: `input[type="text"]`, `select`, `textarea`, `label`

**Lesson**: Component-based forms need wrapper classes with specific CSS overrides per theme.

---

### 5. **The Conditional Render Pattern**

**Problem**: Each LiveView page needs to render completely different HTML for different themes.

**Why Hard**:
- Can't just change CSS - need different markup structure
- Must maintain two separate render functions per page
- Easy to forget to update both when adding features

**Solution**: Establish consistent pattern across ALL LiveViews:
```elixir
def render(assigns) do
  if assigns[:theme] == "gallery" do
    render_gallery(assigns)
  else
    render_default(assigns)
  end
end

defp render_gallery(assigns) do
  ~H"""
  <!-- Gallery HTML -->
  """
end

defp render_default(assigns) do
  ~H"""
  <!-- Original HTML -->
  """
end
```

**Lesson**: Use the exact same pattern in every LiveView for consistency.

---

### 6. **Typography System Complexity**

**Problem**: Gallery theme uses a two-font system (Cormorant Garamond serif + Lato sans-serif) while Original uses default system fonts.

**Why Hard**:
- Must load Google Fonts in Gallery theme only
- Must ensure correct font applied to correct elements
- Headings use serif, body uses sans-serif
- Font-weight must be carefully controlled (400 not 700)

**Solution**:
1. Load fonts in Gallery `<head>`: `@import url('https://fonts.googleapis.com/...')`
2. Define CSS classes: `.gallery-heading`, `.gallery-script`
3. Apply CSS rules to markdown-generated content
4. Set body default font to Lato

**Lesson**: Complex typography requires CSS classes + element-specific rules + font loading.

---

### 7. **Database Content Management**

**Problem**: CMS content had hardcoded incorrect data (e.g., "Olivia Graham" instead of "Olivia Tew").

**Why Hard**:
- Content is in database, not code
- Changes require SQL updates
- Must find ALL instances across multiple tables/columns
- Risk of missing some instances

**Solution**: Systematic SQL search and replace:
```sql
UPDATE page_sections
SET content_md = REPLACE(content_md, 'Olivia Graham', 'Olivia Tew')
WHERE content_md LIKE '%Olivia Graham%'
```

**Lesson**: Always verify CMS content is theme-agnostic and accurate before implementing themes.

---

### 8. **Theme Persistence State Management**

**Problem**: Theme choice must persist across page navigations but also be easily toggleable.

**Why Hard**:
- LiveView has both session and socket state
- Must coordinate between controller, plug, and hook
- Theme must be available in ALL LiveViews
- Must work with LiveView navigation (pushes)

**Solution**: Three-layer approach:
1. **ThemeController**: Sets session cookie on toggle
2. **ThemePlug**: Loads theme from session into conn.assigns
3. **ThemeHook**: Copies from conn.assigns to socket.assigns in `on_mount`

**Lesson**: Theme state needs persistence (session), initialization (plug), and propagation (hook).

---

## The DO's - Critical Success Patterns

### ✅ DO #1: Start with Root Layout

**Always begin theme implementation by updating `root.html.heex` first.**

```heex
<%= if assigns[:theme] == "your_theme_name" do %>
<!DOCTYPE html>
<html lang="en" class="your-theme-class">
  <head>
    <!-- Theme-specific fonts, CSS -->
  </head>
  <body>
    <!-- Completely custom header -->
    <main>{@inner_content}</main>
    <!-- Completely custom footer -->
  </body>
</html>
<% else %>
  <!-- Existing layout -->
<% end %>
```

**Why**: Root layout controls the entire page structure. Get this right first, then work down to pages.

---

### ✅ DO #2: Use Consistent Conditional Rendering Pattern

**Apply this exact pattern to EVERY LiveView:**

```elixir
@impl true
def render(assigns) do
  if assigns[:theme] == "your_theme_name" do
    render_your_theme_name(assigns)
  else
    render_default(assigns)
  end
end

defp render_your_theme_name(assigns) do
  ~H"""
  <!-- Your theme HTML -->
  """
end

defp render_default(assigns) do
  ~H"""
  <!-- Default HTML -->
  """
end
```

**Why**: Consistency makes maintenance easy and prevents bugs.

---

### ✅ DO #3: Define Theme Typography System Upfront

**Before writing any HTML, define your font system:**

1. Choose fonts (serif/sans-serif/mono)
2. Define when each is used (headings vs. body)
3. Create CSS classes for common patterns
4. Load fonts in `<head>`

**Example Gallery Theme System:**
- **Headings**: Cormorant Garamond, serif, weight 400
- **Body**: Lato, sans-serif, weight 300-400
- **Script/Italic**: Cormorant Garamond, italic, weight 300

---

### ✅ DO #4: Account for Markdown Content

**Always add CSS rules for markdown-generated elements:**

```css
main h1, main h2, main h3, main h4, main h5, main h6 {
  font-family: 'Your Heading Font', serif;
  /* ... */
}

main p {
  /* ... */
}

main ul, main ol {
  /* ... */
}

main a {
  /* ... */
}
```

**Why**: Earmark-generated HTML won't have your theme classes.

---

### ✅ DO #5: Create Theme-Specific Form Styles

**For each theme with forms, create wrapper class:**

```css
.your-theme-form input[type="text"],
.your-theme-form input[type="email"],
.your-theme-form select,
.your-theme-form textarea {
  /* Theme-specific input styles */
}

.your-theme-form label {
  /* Theme-specific label styles */
}
```

**Then apply the wrapper class:**
```heex
<.form class="your-theme-form" for={@form} ...>
```

---

### ✅ DO #6: Test Every Page Type

**Create checklist of all page types and test each:**

- [ ] Home page
- [ ] Static pages (About, Collect, etc.)
- [ ] Series/Collection index
- [ ] Series/Collection detail
- [ ] Artwork detail
- [ ] Contact form
- [ ] Any other custom pages

**Why**: Easy to miss a page and leave it unstyled.

---

### ✅ DO #7: Use Semantic Color Variables (If Using CSS)

**For CSS-based themes, define color system:**

```css
.your-theme {
  --color-primary: #8b7355;
  --color-text-dark: #2c2416;
  --color-text-medium: #6b5d54;
  --color-background: #faf8f5;
  --color-border: #e8e6e3;
}
```

**For inline styles (like Gallery), document the color palette:**
```markdown
# Gallery Theme Colors
- Background: #faf8f5 (warm cream)
- Primary text: #2c2416 (dark brown)
- Secondary text: #6b5d54 (medium brown)
- Accent: #8b7355 (warm brown)
- Borders: #e8e6e3 (light tan)
```

---

### ✅ DO #8: Keep Theme Logic Simple

**Theme detection should be a simple equality check:**

```elixir
if assigns[:theme] == "theme_name" do
```

**DON'T use complex logic:**
```elixir
# ❌ BAD
if assigns[:theme] in ["gallery", "museum", "modern"] do
```

**Why**: Simple boolean logic is easier to debug and maintain.

---

### ✅ DO #9: Document Your Theme

**Create a theme documentation file including:**
- Name and description
- Color palette (hex codes + names)
- Typography system
- Key design principles
- Example screenshots
- Which pages support it

---

### ✅ DO #10: Verify Theme Persistence

**Test theme switching thoroughly:**

1. Set theme to new theme
2. Navigate to different pages
3. Refresh browser
4. Open in new tab
5. Close and reopen browser

**Ensure theme persists in all scenarios.**

---

## The DON'Ts - Common Pitfalls

### ❌ DON'T #1: Mix Styling Approaches

**Don't mix Tailwind classes with inline styles in the same theme:**

```heex
<!-- ❌ BAD -->
<div class="flex items-center" style="color: #8b7355;">
```

**Pick one approach per theme:**
```heex
<!-- ✅ GOOD - All inline -->
<div style="display: flex; align-items: center; color: #8b7355;">

<!-- ✅ GOOD - All classes -->
<div class="flex items-center text-brown-600">
```

---

### ❌ DON'T #2: Forget the Layout Layer

**Don't only style pages and forget the root layout:**

**Problem**: You styled all LiveViews beautifully, but the header/footer are still default.

**Solution**: Always check `root.html.heex` first.

---

### ❌ DON'T #3: Assume CSS Inheritance Works

**Don't rely on font-family inheritance for specific elements:**

```heex
<!-- ❌ BAD - h1 won't inherit font-family reliably -->
<div style="font-family: 'Cormorant Garamond';">
  <%= raw(Earmark.as_html!(@content)) %>
</div>
```

**Solution**: Use explicit CSS rules for generated elements.

---

### ❌ DON'T #4: Hardcode Theme Names in Multiple Places

**Don't scatter theme name strings everywhere:**

```elixir
# ❌ BAD - typo risk
if assigns[:theme] == "galery" do  # oops, typo!
```

**Better**: Use module attributes or constants:
```elixir
@gallery_theme "gallery"

if assigns[:theme] == @gallery_theme do
```

**Even Better**: Consider a Theme module:
```elixir
defmodule OliviaWeb.Theme do
  def gallery, do: "gallery"
  def original, do: "original"

  def is_gallery?(theme), do: theme == gallery()
end
```

---

### ❌ DON'T #5: Skip Form Testing

**Don't assume forms will work without testing:**

Forms have:
- Input field styling
- Label styling
- Error message styling
- Focus states
- Disabled states
- Validation states

**Test all form states in your theme.**

---

### ❌ DON'T #6: Ignore Mobile/Responsive Design

**Don't only test on desktop.**

The Gallery theme uses fixed layouts that may not work on mobile:
```css
/* Needs media queries! */
nav style="display: flex; gap: 2rem;"
```

**Solution**: Add responsive styles for each theme.

---

### ❌ DON'T #7: Copy-Paste Without Understanding

**Don't blindly copy the Gallery theme pattern without understanding why it works.**

**Understand**:
- Why root layout is conditional
- Why each LiveView needs render functions
- Why markdown needs CSS rules
- Why forms need wrapper classes

**Then adapt to your theme's needs.**

---

### ❌ DON'T #8: Forget About Edge Cases

**Don't only test happy path. Test**:
- Missing images
- Long text / overflow
- Empty states
- Error states
- Loading states
- No data scenarios

---

### ❌ DON'T #9: Neglect Accessibility

**Don't forget accessible design:**
- Color contrast ratios (WCAG AA minimum)
- Focus states on interactive elements
- Semantic HTML
- ARIA labels where needed
- Keyboard navigation

**Example**: Gallery theme links need visible focus state:
```css
.nav-link:focus {
  outline: 2px solid #8b7355;
  outline-offset: 2px;
}
```

---

### ❌ DON'T #10: Modify Core Components Without Documentation

**If you modify `core_components.ex` for a theme, document it heavily.**

Changes to core components affect ALL themes. Better to:
1. Use CSS overrides
2. Create theme-specific component variants
3. Use wrapper classes

---

## Step-by-Step Theme Creation Checklist

### Phase 1: Planning (Before Writing Code)

- [ ] Define theme name (lowercase, single word preferred)
- [ ] Choose color palette (5-7 colors with hex codes)
- [ ] Choose typography system (1-3 fonts max)
- [ ] Decide styling approach (Tailwind classes vs. inline styles)
- [ ] Sketch layouts for key page types
- [ ] Identify unique design elements (navigation style, footer, cards, etc.)
- [ ] Plan responsive breakpoints

### Phase 2: Infrastructure Setup

- [ ] Verify ThemeHook exists and works
- [ ] Verify ThemePlug exists and works
- [ ] Verify ThemeController exists and works
- [ ] Test theme toggle with existing themes
- [ ] Add your theme name to toggle logic if needed

### Phase 3: Root Layout Implementation

- [ ] Open `lib/olivia_web/components/layouts/root.html.heex`
- [ ] Add conditional block for your theme
- [ ] Define `<head>` section with fonts/CSS
- [ ] Create theme-specific CSS classes in `<style>` tag
- [ ] Build custom header/navigation
- [ ] Build custom footer
- [ ] Add markdown content styles
- [ ] Add form styles
- [ ] Test with a simple page

### Phase 4: Page-by-Page Implementation

For each LiveView module:

- [ ] Add conditional `render/1` function
- [ ] Create `render_your_theme/1` function
- [ ] Implement hero/header section
- [ ] Implement main content area
- [ ] Implement any CTAs or actions
- [ ] Implement footer/navigation links
- [ ] Test page independently
- [ ] Test page with navigation from other pages

**Pages to implement:**
- [ ] `home_live.ex`
- [ ] `page_live.ex` (for About, Collect, etc.)
- [ ] `contact_live.ex`
- [ ] `series_live/index.ex`
- [ ] `series_live/show.ex`
- [ ] `artwork_live/show.ex`

### Phase 5: Component Styling

- [ ] Forms (inputs, labels, buttons, errors)
- [ ] Links and navigation
- [ ] Cards/artwork displays
- [ ] Badges (status indicators)
- [ ] Images and aspect ratios
- [ ] Typography (headings, paragraphs, lists)

### Phase 6: Testing

- [ ] Visual regression testing (compare to mockups)
- [ ] Test on desktop (1920px, 1440px, 1280px)
- [ ] Test on tablet (768px, 1024px)
- [ ] Test on mobile (375px, 414px)
- [ ] Test all navigation flows
- [ ] Test theme switching from each page
- [ ] Test browser refresh persistence
- [ ] Test form submission and validation
- [ ] Test error states
- [ ] Test empty/no-data states
- [ ] Test with real content (long titles, missing images, etc.)

### Phase 7: Polish

- [ ] Add transitions and hover states
- [ ] Verify focus states for accessibility
- [ ] Check color contrast ratios
- [ ] Optimize font loading
- [ ] Add any micro-interactions
- [ ] Final cross-browser testing

### Phase 8: Documentation

- [ ] Document color palette
- [ ] Document typography system
- [ ] Document key spacing/sizing values
- [ ] Add theme to project README
- [ ] Create theme preview screenshots
- [ ] Document any known limitations

---

## File-by-File Implementation Guide

### 1. `lib/olivia_web/components/layouts/root.html.heex`

**Purpose**: Root HTML wrapper for all pages

**What to add**:
```heex
<%= if assigns[:theme] == "your_theme" do %>
<!DOCTYPE html>
<html lang="en" class="your-theme-class">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="csrf-token" content={get_csrf_token()} />
    <.live_title suffix=" · Your Theme Name">
      <%= assigns[:page_title] || "Default Title" %>
    </.live_title>

    <!-- Essential assets -->
    <link phx-track-static rel="stylesheet" href={~p"/assets/app.css"} />
    <script defer phx-track-static type="text/javascript" src={~p"/assets/app.js"}></script>

    <!-- Theme-specific styles -->
    <style>
      /* Import fonts */
      @import url('https://fonts.googleapis.com/css2?family=Your+Font&display=swap');

      /* Theme classes */
      .your-theme-heading {
        font-family: 'Your Font', serif;
      }

      /* Markdown content styles */
      main h1, main h2, main h3 {
        font-family: 'Your Font', serif;
        /* ... */
      }

      /* Form styles */
      .your-theme-form input {
        /* ... */
      }
    </style>
  </head>

  <body>
    <!-- Custom header -->
    <header>
      <!-- Your navigation -->
    </header>

    <!-- Main content -->
    <main>
      {@inner_content}
    </main>

    <!-- Custom footer -->
    <footer>
      <!-- Your footer -->
    </footer>
  </body>
</html>
<% else %>
  <!-- Existing theme branches -->
<% end %>
```

---

### 2. Each LiveView Module

**Pattern for ALL LiveViews:**

```elixir
defmodule OliviaWeb.YourLive do
  use OliviaWeb, :live_view

  @impl true
  def render(assigns) do
    if assigns[:theme] == "your_theme" do
      render_your_theme(assigns)
    else
      render_default(assigns)
    end
  end

  defp render_your_theme(assigns) do
    ~H"""
    <!-- Hero/Header section -->
    <div class="your-theme-hero">
      <h1><%= @page_title %></h1>
    </div>

    <!-- Main content -->
    <div class="your-theme-content">
      <!-- Page-specific content -->
    </div>

    <!-- Footer/Navigation links -->
    <div class="your-theme-footer">
      <.link navigate={~p"/"}>Back</.link>
    </div>
    """
  end

  defp render_default(assigns) do
    ~H"""
    <!-- Existing default rendering -->
    """
  end

  # Keep existing mount, handle_event, etc.
end
```

---

## Testing and Validation

### Visual Testing Checklist

For each theme page, verify:

- [ ] **Typography**: Correct fonts loading and applying
- [ ] **Colors**: All colors match palette
- [ ] **Spacing**: Consistent padding/margins
- [ ] **Alignment**: Elements properly aligned
- [ ] **Borders**: Correct colors and widths
- [ ] **Shadows**: If applicable, subtle and consistent
- [ ] **Images**: Correct aspect ratios, loading, placeholders
- [ ] **Icons**: If used, correct size and color

### Functional Testing Checklist

- [ ] **Navigation**: All links work
- [ ] **Theme Toggle**: Switches to/from your theme correctly
- [ ] **Theme Persistence**: Survives page refresh
- [ ] **Forms**: Submit, validate, display errors correctly
- [ ] **Responsive**: Works on mobile, tablet, desktop
- [ ] **Accessibility**: Keyboard navigation, focus states, contrast
- [ ] **Performance**: Fonts load quickly, no layout shift

### Browser Testing Matrix

Test in:
- [ ] Chrome (latest)
- [ ] Firefox (latest)
- [ ] Safari (latest)
- [ ] Edge (latest)
- [ ] Mobile Safari (iOS)
- [ ] Mobile Chrome (Android)

---

## Troubleshooting Guide

### Problem: Theme not applying at all

**Symptoms**: All pages show default theme

**Checklist**:
1. Check `assigns[:theme]` value in LiveView mount:
   ```elixir
   IO.inspect(assigns[:theme], label: "Theme in mount")
   ```
2. Verify ThemeHook is in router:
   ```elixir
   live_session :default, on_mount: [OliviaWeb.ThemeHook] do
   ```
3. Check session cookie value in browser dev tools
4. Verify ThemePlug is in pipeline
5. Check theme toggle controller is setting session correctly

---

### Problem: Some pages work, others don't

**Symptoms**: Theme works on home page but not others

**Checklist**:
1. Check if affected pages have `render/1` conditional logic
2. Verify affected pages have `render_your_theme/1` function
3. Check for typos in theme name string
4. Ensure affected pages are in the correct `live_session` with ThemeHook

---

### Problem: Fonts not loading

**Symptoms**: Wrong fonts displaying

**Checklist**:
1. Verify `@import url()` in `<style>` tag
2. Check browser Network tab for font loading errors
3. Verify font name spelling in `font-family` rules
4. Check font-weight values match available weights
5. Ensure CSS specificity is high enough

---

### Problem: Markdown content not styled

**Symptoms**: CMS content looks different from mockup

**Checklist**:
1. Check `main h1, main h2` etc. CSS rules exist
2. Verify CSS rules are in the correct theme branch
3. Check CSS specificity (may need `main > div h1`)
4. Inspect element to see what styles are actually applied
5. Check if Earmark is actually being called: `<%= raw(Earmark.as_html!(...)) %>`

---

### Problem: Forms look wrong

**Symptoms**: Inputs have default styles

**Checklist**:
1. Verify form has wrapper class: `<.form class="your-theme-form">`
2. Check `.your-theme-form input[type="text"]` CSS rules exist
3. Verify CSS specificity is high enough to override defaults
4. Check if Phoenix form components are adding conflicting classes
5. Use browser inspector to see what styles are being applied

---

### Problem: Theme not persisting

**Symptoms**: Theme resets on page refresh

**Checklist**:
1. Check ThemeController is setting session: `put_session(conn, :theme, theme)`
2. Verify cookie is being set in browser dev tools
3. Check ThemePlug is reading session: `conn.assigns[:theme] = get_session(conn, :theme)`
4. Ensure ThemeHook is copying to socket: `socket = assign(socket, :theme, theme)`
5. Check browser cookie settings (third-party cookies, etc.)

---

### Problem: Responsive design broken

**Symptoms**: Theme looks bad on mobile

**Checklist**:
1. Add viewport meta tag: `<meta name="viewport" content="width=device-width, initial-scale=1">`
2. Check if inline styles use fixed widths (use `max-width` instead)
3. Add media queries for mobile breakpoints
4. Test with browser responsive design mode
5. Consider using `grid-template-columns: 1fr` for single column on mobile

---

### Problem: Performance issues

**Symptoms**: Slow page loads, layout shift

**Checklist**:
1. Use `font-display: swap` for web fonts
2. Preload critical fonts: `<link rel="preload" as="font">`
3. Optimize images (use appropriate sizes, formats)
4. Avoid layout shift by setting aspect ratios on images
5. Minimize inline styles if possible (CSS rules are cached)

---

## Systematic Three-Theme Implementation Process

### Overview: The `cond` Pattern

When you have **three or more themes**, you MUST use `cond do` instead of `if/else`:

```elixir
cond do
  assigns[:theme] == "cottage" -> render_cottage(assigns)
  assigns[:theme] == "gallery" -> render_gallery(assigns)
  true -> render_default(assigns)  # Original theme is the default/fallback
end
```

**Why `cond` not `if/elsif`**:
- HEEx templates use `cond do` for multi-way branching
- More scalable than nested `if/else`
- Cleaner, more maintainable code
- Easy to add fourth, fifth theme later

---

### CRITICAL: Methodology for Implementing Third Theme

This section documents the **EXACT PROCESS** for adding the "Cottage" theme (or any third theme). Follow these steps **IN ORDER**:

#### Step 1: Create Theme Dropdown Component

**BEFORE implementing any theme code**, update the UI to support theme selection:

1. **Update ThemeController** to accept all three themes:
   ```elixir
   @valid_themes ["original", "gallery", "cottage"]

   def set_theme(conn, %{"theme" => theme} = params) when theme in @valid_themes do
     redirect_to = params["redirect_to"] || "/"

     conn
     |> put_resp_header("cache-control", "no-cache, no-store, must-revalidate")
     |> ThemePlug.set_theme(theme)
     |> redirect(to: redirect_to)
   end
   ```

2. **Add route** in `router.ex`:
   ```elixir
   get "/set-theme/:theme", ThemeController, :set_theme
   ```

3. **Create dropdowns** in BOTH existing themes:

   **Original theme** (in `layouts.ex`):
   ```heex
   <div class="relative">
     <button id="theme-dropdown-toggle" onclick="..." class="...">
       Theme
       <svg><!-- dropdown icon --></svg>
     </button>
     <div id="theme-dropdown-menu" class="hidden ...">
       <a href="/set-theme/original">Original</a>
       <a href="/set-theme/gallery">Gallery</a>
       <a href="/set-theme/cottage">Cottage</a>
     </div>
   </div>
   ```

   **Gallery theme** (in `root.html.heex` Gallery branch):
   ```heex
   <div style="position: relative;">
     <button id="gallery-theme-toggle" onclick="..." style="...">
       Theme
       <svg><!-- dropdown icon --></svg>
     </button>
     <div id="gallery-theme-menu" class="hidden" style="...">
       <a href="/set-theme/original">Original</a>
       <a href="/set-theme/gallery">Gallery</a>
       <a href="/set-theme/cottage">Cottage</a>
     </div>
   </div>
   ```

4. **Add JavaScript** for click-outside-to-close behavior

**IMPORTANT**: Use unique IDs for each theme's dropdown to avoid JavaScript conflicts:
- Original: `theme-dropdown-toggle`, `theme-dropdown-menu`
- Gallery: `gallery-theme-toggle`, `gallery-theme-menu`
- Cottage: `cottage-theme-toggle`, `cottage-theme-menu`

---

#### Step 2: Update Root Layout to `cond` Pattern

**File**: `lib/olivia_web/components/layouts/root.html.heex`

**Change from**:
```heex
<%= if assigns[:theme] == "gallery" do %>
  <!-- Gallery HTML -->
<% else %>
  <!-- Original HTML -->
<% end %>
```

**Change to**:
```heex
<%= cond do %>
<% assigns[:theme] == "cottage" -> %>
  <!DOCTYPE html>
  <html lang="en" class="h-full">
    <head>
      <!-- Cottage fonts, CSS, etc. -->
    </head>
    <body>
      <!-- Cottage header -->
      <main>{@inner_content}</main>
      <!-- Cottage footer -->
    </body>
  </html>

<% assigns[:theme] == "gallery" -> %>
  <!DOCTYPE html>
  <!-- Gallery HTML (unchanged) -->
  </html>

<% true -> %>
  <!DOCTYPE html>
  <!-- Original HTML (unchanged) -->
  </html>
<% end %>
```

**Key points**:
- Cottage theme goes FIRST (new themes at top)
- Gallery theme in middle
- Original theme in `true` branch (fallback/default)
- Each branch is a COMPLETE HTML document from `<!DOCTYPE>` to `</html>`

---

#### Step 3: Implement Cottage Theme in Root Layout

Based on your theme specification document (e.g., `COTTAGE_THEME_CONCEPT.md`):

**A. Load Fonts**:
```html
<style>
  @import url('https://fonts.googleapis.com/css2?family=Newsreader:wght@300;400;500&family=Montserrat:wght@300;400;500&display=swap');
</style>
```

**B. Define CSS Variables**:
```css
:root {
  --cottage-cream: #FAF7F5;
  --cottage-wisteria: #C8A7D8;
  --cottage-sage: #9FB8A3;
  --cottage-text-dark: #4A3F4B;
  /* ... all theme colors */
}
```

**C. Define CSS Classes**:
```css
.cottage-heading {
  font-family: 'Newsreader', Georgia, serif;
  font-weight: 300;
  letter-spacing: 0.03em;
  color: var(--cottage-text-dark);
}

.cottage-body {
  font-family: 'Montserrat', -apple-system, sans-serif;
  font-weight: 300;
  color: var(--cottage-text-medium);
}

.cottage-button {
  background: var(--cottage-wisteria);
  color: white;
  border-radius: 6px;
  padding: 0.75rem 1.5rem;
  /* ... */
}

.cottage-form input[type="text"],
.cottage-form input[type="email"],
.cottage-form textarea {
  /* ... form styling */
}
```

**D. Style Markdown Content** (CRITICAL - don't forget):
```css
main h1, main h2, main h3, main h4, main h5, main h6 {
  font-family: 'Newsreader', Georgia, serif;
  font-weight: 400;
  color: var(--cottage-text-dark);
  margin-top: 2rem;
  margin-bottom: 1rem;
}

main p {
  font-family: 'Montserrat', sans-serif;
  font-weight: 300;
  line-height: 1.7;
  margin-bottom: 1rem;
}

main a {
  color: var(--cottage-wisteria);
  border-bottom: 1px solid var(--cottage-wisteria);
  text-decoration: none;
}
```

**E. Build Header with Dropdown**:
```html
<header style="background: var(--cottage-cream); border-bottom: 1px solid var(--cottage-taupe); padding: 2rem;">
  <nav style="max-width: 1200px; margin: 0 auto; display: flex; justify-content: space-between; align-items: center;">
    <div>
      <h1 class="cottage-heading" style="font-size: 2rem; margin: 0;">
        <a href="/" style="color: var(--cottage-text-dark); text-decoration: none;">Olivia Tew</a>
      </h1>
      <p class="cottage-body" style="margin: 0; font-size: 0.875rem; text-transform: uppercase; letter-spacing: 0.1em;">Visual Artist</p>
    </div>
    <div style="display: flex; gap: 2rem; align-items: center;">
      <a href="/series" class="cottage-body">Collections</a>
      <a href="/about" class="cottage-body">About</a>
      <a href="/contact" class="cottage-body">Contact</a>

      <!-- Theme dropdown -->
      <div style="position: relative;">
        <button id="cottage-theme-toggle" class="cottage-button">
          Theme
          <svg><!-- down arrow --></svg>
        </button>
        <div id="cottage-theme-menu" class="hidden">
          <a href="/set-theme/original">Original</a>
          <a href="/set-theme/gallery">Gallery</a>
          <a href="/set-theme/cottage" class="active">Cottage</a>
        </div>
      </div>
    </div>
  </nav>
</header>
```

**F. Build Footer**:
```html
<footer style="background: var(--cottage-cream); border-top: 1px solid var(--cottage-taupe); padding: 3rem 1rem; margin-top: 4rem;">
  <div style="max-width: 1200px; margin: 0 auto; text-align: center;">
    <div class="cottage-body" style="font-size: 0.875rem; color: var(--cottage-text-light);">
      <a href="/series">Collections</a> |
      <a href="/about">About</a> |
      <a href="/contact">Contact</a>
    </div>
    <p class="cottage-body" style="margin-top: 1rem; font-size: 0.75rem; color: var(--cottage-text-light);">
      © <%= Date.utc_today().year %> Olivia Tew. All rights reserved.
    </p>
  </div>
</footer>
```

**G. Add JavaScript for Dropdown**:
```javascript
<script>
  document.addEventListener('click', function(event) {
    const dropdown = document.getElementById('cottage-theme-menu');
    const toggle = document.getElementById('cottage-theme-toggle');
    if (dropdown && toggle && !dropdown.contains(event.target) && !toggle.contains(event.target)) {
      dropdown.classList.add('hidden');
    }
  });
</script>
```

---

#### Step 4: Test Root Layout Works

**BEFORE continuing to LiveViews**, test the root layout:

1. Navigate to `http://localhost:4000/`
2. Click theme dropdown, select "Cottage"
3. Verify:
   - Fonts load correctly
   - Colors match specification
   - Header and footer render
   - Dropdown works

**If this doesn't work, STOP and fix it before continuing.**

---

#### Step 5: Systematically Update All LiveViews

**THE EXACT PATTERN**: For EACH LiveView module, follow these steps:

**Files to update**:
1. `lib/olivia_web/live/home_live.ex`
2. `lib/olivia_web/live/page_live.ex`
3. `lib/olivia_web/live/contact_live.ex`
4. `lib/olivia_web/live/series_live/index.ex`
5. `lib/olivia_web/live/series_live/show.ex`
6. `lib/olivia_web/live/artwork_live/show.ex`

**For each file:**

**A. Read the file first**

**B. Locate the existing `render/1` function**:
```elixir
@impl true
def render(assigns) do
  if assigns[:theme] == "gallery" do
    render_gallery(assigns)
  else
    render_default(assigns)
  end
end
```

**C. Change to `cond` pattern**:
```elixir
@impl true
def render(assigns) do
  cond do
    assigns[:theme] == "cottage" -> render_cottage(assigns)
    assigns[:theme] == "gallery" -> render_gallery(assigns)
    true -> render_default(assigns)
  end
end
```

**D. Add `render_cottage/1` function** (copy structure from `render_gallery/1` as template):
```elixir
defp render_cottage(assigns) do
  ~H"""
  <!-- Cottage-specific HTML using .cottage-* classes -->
  """
end
```

**E. Implement Cottage theme HTML** based on page type:

**Homepage (`home_live.ex`)**:
```heex
<div style="max-width: 1200px; margin: 0 auto; padding: 4rem 1rem;">
  <div style="text-align: center; margin-bottom: 3rem;">
    <h1 class="cottage-heading" style="font-size: 3rem; margin-bottom: 1rem;">
      Welcome
    </h1>
    <p class="cottage-body" style="font-size: 1.25rem; color: var(--cottage-text-medium);">
      Oil paintings from a cottage garden studio in Devon
    </p>
  </div>

  <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 2rem;">
    <%= for artwork <- @featured_artworks do %>
      <div class="cottage-card">
        <img src={artwork.image_url} alt={artwork.title} />
        <h3 class="cottage-heading"><%= artwork.title %></h3>
        <p class="cottage-body"><%= artwork.year %></p>
      </div>
    <% end %>
  </div>
</div>
```

**Static Page (`page_live.ex`)**:
```heex
<div style="max-width: 800px; margin: 0 auto; padding: 4rem 1rem;">
  <%= for section <- @page.sections do %>
    <div style="margin-bottom: 3rem;">
      <%= if section.title do %>
        <h2 class="cottage-heading" style="font-size: 2rem; margin-bottom: 1.5rem;">
          <%= section.title %>
        </h2>
      <% end %>

      <div class="cottage-body">
        <%= raw(Earmark.as_html!(section.content_md)) %>
      </div>
    </div>
  <% end %>
</div>
```

**Contact Form (`contact_live.ex`)**:
```heex
<div style="max-width: 600px; margin: 0 auto; padding: 4rem 1rem;">
  <h1 class="cottage-heading" style="font-size: 2.5rem; margin-bottom: 2rem; text-align: center;">
    Get in Touch
  </h1>

  <.form class="cottage-form" for={@form} phx-submit="save">
    <.input field={@form[:name]} type="text" label="Name" required />
    <.input field={@form[:email]} type="email" label="Email" required />
    <.input field={@form[:message]} type="textarea" label="Message" required />

    <button type="submit" class="cottage-button" style="width: 100%; margin-top: 1rem;">
      Send Message
    </button>
  </.form>
</div>
```

**F. Test the page** immediately after implementation

**G. Move to next LiveView** - repeat A through F

---

#### Step 6: Verification Checklist

After implementing Cottage theme across ALL pages:

- [ ] Root layout loads Cottage fonts
- [ ] Root layout defines all CSS variables
- [ ] Root layout has Cottage header with dropdown
- [ ] Root layout has Cottage footer
- [ ] Markdown content is styled correctly
- [ ] Forms are styled correctly
- [ ] All 6 LiveViews have `cond` pattern
- [ ] All 6 LiveViews have `render_cottage/1` function
- [ ] Home page displays in Cottage theme
- [ ] Static pages (About, Collect, etc.) display correctly
- [ ] Contact form displays and submits correctly
- [ ] Series index displays correctly
- [ ] Series detail displays correctly
- [ ] Artwork detail displays correctly
- [ ] Theme dropdown works on all pages
- [ ] Theme persists across navigation
- [ ] Theme persists across browser refresh
- [ ] Can switch between all three themes smoothly

---

### Template Code for Quick Reference

#### Root Layout `cond` Template:
```heex
<%= cond do %>
<% assigns[:theme] == "NEW_THEME" -> %>
  <!DOCTYPE html>
  <html lang="en" class="h-full">
    <head>
      <meta charset="utf-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1" />
      <meta name="csrf-token" content={get_csrf_token()} />
      <.live_title><%= assigns[:page_title] || "Olivia Tew" %></.live_title>
      <link phx-track-static rel="stylesheet" href={~p"/assets/app.css"} />
      <script defer phx-track-static type="text/javascript" src={~p"/assets/app.js"}></script>
      <style>
        /* Fonts, CSS variables, theme classes */
      </style>
    </head>
    <body>
      <header><!-- Custom header --></header>
      <main>{@inner_content}</main>
      <footer><!-- Custom footer --></footer>
    </body>
  </html>

<% assigns[:theme] == "gallery" -> %>
  <!-- Gallery HTML -->

<% true -> %>
  <!-- Original HTML -->
<% end %>
```

#### LiveView `cond` Template:
```elixir
@impl true
def render(assigns) do
  cond do
    assigns[:theme] == "NEW_THEME" -> render_new_theme(assigns)
    assigns[:theme] == "gallery" -> render_gallery(assigns)
    true -> render_default(assigns)
  end
end

defp render_new_theme(assigns) do
  ~H"""
  <div class="new-theme-container">
    <!-- Theme-specific HTML -->
  </div>
  """
end

defp render_gallery(assigns) do
  ~H"""
  <!-- Existing Gallery HTML -->
  """
end

defp render_default(assigns) do
  ~H"""
  <!-- Existing Original HTML -->
  """
end
```

---

### Common Mistakes and How to Avoid Them

#### Mistake 1: Implementing Pages Before Root Layout
**Problem**: You implement Cottage in all LiveViews but forget to add Cottage branch to root.html.heex
**Result**: Content renders but header/footer are wrong theme
**Solution**: ALWAYS implement root layout first, test it, THEN move to pages

#### Mistake 2: Forgetting to Convert `if/else` to `cond`
**Problem**: You add a third theme but keep using `if assigns[:theme] == "gallery"`
**Result**: New theme never gets triggered
**Solution**: ALWAYS change to `cond do` when adding third theme

#### Mistake 3: Inconsistent Theme Order in `cond` Blocks
**Problem**: Different files have different order (Cottage first vs Gallery first)
**Result**: Confusing to maintain, hard to debug
**Solution**: Pick ONE order and use it everywhere:
```
1. Cottage (newest)
2. Gallery (middle)
3. Original (default/fallback in `true` branch)
```

#### Mistake 4: Forgetting Markdown Styling
**Problem**: You implement theme but forget markdown CSS rules
**Result**: About page, static pages render with wrong fonts/colors
**Solution**: ALWAYS add `main h1, main p, main a` rules in root layout `<style>` tag

#### Mistake 5: Forgetting Form Styling
**Problem**: You implement theme but forget `.cottage-form` CSS rules
**Result**: Contact form looks broken
**Solution**: ALWAYS add form input styles in root layout, apply wrapper class in form

#### Mistake 6: Testing Only One Page
**Problem**: You test home page, it works, you assume all pages work
**Result**: Other pages are broken and you don't know
**Solution**: Test EVERY page type after implementation

#### Mistake 7: Mixing Inline Styles with CSS Classes
**Problem**: Some elements use `class="cottage-heading"`, others use `style="font-family: ..."`
**Result**: Inconsistent styling, hard to maintain
**Solution**: Pick ONE approach per theme:
- Cottage: CSS custom properties + classes
- Gallery: Inline styles
- Original: Tailwind classes

---

### Why This Methodology Matters

**Without systematic process**:
- Easy to forget pages
- Easy to make typos in theme names
- Easy to have inconsistent patterns
- Hard to debug when things break
- Tempting to skip testing

**With systematic process**:
- Every page gets consistent treatment
- Clear checklist to follow
- Easy to debug (know exactly where to look)
- Confidence that nothing is missed
- Documentation for future theme additions

---

## Creating a Fourth Theme (Hypothetical "Modern")

If you needed to add a fourth theme later, the process is:

1. **Update ThemeController**: Add "modern" to `@valid_themes`
2. **Update all dropdowns**: Add "Modern" link to all three existing theme dropdowns
3. **Update root.html.heex**: Add `<% assigns[:theme] == "modern" -> %>` as FIRST branch
4. **Update ALL LiveViews**: Add `assigns[:theme] == "modern" -> render_modern(assigns)` as FIRST branch
5. **Implement `render_modern/1`** in all 6 LiveViews
6. **Test systematically** using the checklist

The `cond` pattern scales infinitely - you can have 5, 10, 20 themes if needed.

---

## Summary

### The Three Hardest Problems

1. **Conditional Layout Structure**: Themes need different HTML, not just CSS
2. **Markdown Content Styling**: Generated HTML needs explicit CSS rules
3. **State Propagation**: Theme must flow through session → plug → hook → socket

### The Three Most Important DO's

1. **Start with root layout** - get the structure right first
2. **Use consistent patterns** - same render structure in every LiveView
3. **Test everything** - forms, markdown, navigation, persistence

### The Three Most Dangerous DON'Ts

1. **Don't mix styling approaches** - pick Tailwind OR inline styles, not both
2. **Don't forget markdown** - always add CSS rules for generated content
3. **Don't skip testing** - edge cases will break your theme

---

## Conclusion

Implementing themes in Phoenix LiveView with fundamentally different designs (not just color schemes) is complex because it touches every layer:
- Session management
- Layout rendering
- Component conditional logic
- CSS specificity and inheritance
- Form component styling
- Markdown rendering

The key to success is:
1. Understanding the flow: session → plug → hook → socket → render
2. Being systematic: use checklists, follow patterns
3. Testing thoroughly: every page, every state, every device

Good luck implementing your third theme! 🎨
