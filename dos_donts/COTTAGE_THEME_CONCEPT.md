# "Cottage" Theme Concept for Olivia Tew Portfolio

## Executive Summary

Based on research into contemporary impressionist artist websites and Olivia's artistic practice (cottage garden studio, Devon village, expressive oil paintings, floral still life, romantic untamed beauty), I recommend a **"Cottage"** theme that combines:

- Soft yet bold pastel color palette inspired by English cottage gardens
- Romantic, feminine aesthetic with breathing room
- Clean minimalist layouts that let the vibrant paintings shine
- Delicate typography with warmth and personality
- Nature-inspired design elements

---

## Artist Profile Analysis

**Olivia Tew's Key Characteristics:**
- Devon cottage garden studio location
- Fashion background (sophisticated, curated aesthetic)
- Oil painting with impasto technique (textured, tactile)
- Expressive mark-making and loose gestural style
- Distinctive color usage: "soft and bold at the same time"
- Floral arrangements and everyday scenes
- Evokes energy, freedom, nostalgia
- Romantic, untamed beauty
- Relaxed, carefree aura

**Design Implications:**
The website should feel like stepping into her cottage studio - light-filled, romantic, organized yet relaxed, with the paintings as vibrant focal points against soft, natural backgrounds.

---

## Color Palette: "Wisteria Garden"

### Primary Colors (Inspired by "Wisteria Lane" palette)

**Backgrounds & Neutrals:**
- `#FAF7F5` - Soft cream (warm white, like cottage walls)
- `#F5F1ED` - Warm beige (lighter variant)
- `#E8E3DD` - Taupe mist (borders, subtle dividers)

**Accent Colors (Soft yet Bold):**
- `#C8A7D8` - Wisteria purple (primary accent - romantic, garden-inspired)
- `#B89AC5` - Lavender mist (secondary purple)
- `#9FB8A3` - Sage green (grounding, natural)
- `#7A9B7E` - Garden green (deeper green for contrast)

**Typography & Details:**
- `#4A3F4B` - Plum charcoal (dark text, sophisticated)
- `#6B5D66` - Dusty mauve (secondary text)
- `#8B7E87` - Soft grey-purple (tertiary text, captions)

**Interactive Elements:**
- `#D4B5E0` - Light wisteria (hover states)
- `#A88AB7` - Deep lavender (active states, buttons)

### Why This Palette Works

1. **Soft and Bold**: Purple-green combination is both gentle and striking
2. **Garden Connection**: Wisteria and sage evoke English cottage gardens
3. **Sophisticated Femininity**: Not overly sweet or pastel - has depth
4. **Let Paintings Shine**: Neutral backgrounds with purple accents won't compete with vibrant oil paintings
5. **Nostalgic**: Purple and green feel vintage, romantic, timeless

---

## Typography System

### Primary Font: **Newsreader** (Serif)
- Use for: Main headings, artwork titles, feature text
- Weight: 300 (Light) for large headings, 400 (Regular) for smaller
- Why: Elegant serif with old-world charm, readable, sophisticated
- Google Fonts: `@import url('https://fonts.googleapis.com/css2?family=Newsreader:wght@300;400;500&display=swap')`

### Secondary Font: **Montserrat** (Sans-serif)
- Use for: Body text, navigation, buttons, labels
- Weight: 300 (Light), 400 (Regular), 500 (Medium)
- Why: Clean, modern sans-serif that pairs beautifully with Newsreader
- Google Fonts: `@import url('https://fonts.googleapis.com/css2?family=Montserrat:wght@300;400;500&display=swap')`

### Accent Font: **Cormorant Garamond** (Serif Italic)
- Use for: Pull quotes, special callouts, signature elements
- Weight: 300 Italic
- Why: Delicate, romantic, handwritten feel for special touches
- Google Fonts: Already loaded (can reuse from Gallery theme)

---

## Design Elements & Patterns

### 1. Soft Borders & Shadows

Replace hard edges with gentle, organic touches:

```css
.cottage-card {
  border: 1px solid #E8E3DD;
  border-radius: 8px; /* Soft rounded corners */
  box-shadow: 0 2px 8px rgba(200, 167, 216, 0.08); /* Very subtle purple shadow */
}
```

### 2. Breathing Room Layout

Inspired by minimalist gallery approach but warmer:

- **Generous whitespace**: 4-6rem padding between sections
- **Asymmetric grids**: Not rigid - feels organic
- **Max content width**: 1200px for relaxed reading
- **Image frames**: Soft borders around artworks like gallery frames

### 3. Nature-Inspired Accents

Subtle decorative elements:

```css
/* Delicate divider lines */
.cottage-divider {
  height: 1px;
  background: linear-gradient(90deg,
    transparent 0%,
    #C8A7D8 50%,
    transparent 100%);
  margin: 3rem auto;
  max-width: 200px;
}

/* Organic hover effects */
.cottage-link:hover {
  color: #C8A7D8;
  border-bottom: 2px solid #C8A7D8;
  transition: all 0.3s ease;
}
```

### 4. Typography Styling

```css
.cottage-heading {
  font-family: 'Newsreader', Georgia, serif;
  font-weight: 300;
  letter-spacing: 0.03em;
  color: #4A3F4B;
  line-height: 1.3;
}

.cottage-body {
  font-family: 'Montserrat', -apple-system, sans-serif;
  font-weight: 300;
  letter-spacing: 0.01em;
  color: #6B5D66;
  line-height: 1.7;
}

.cottage-accent {
  font-family: 'Cormorant Garamond', serif;
  font-style: italic;
  font-weight: 300;
  color: #8B7E87;
}
```

---

## Layout Concepts

### Header / Navigation

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│    Olivia Tew                        Collections        │
│    Visual Artist                     About              │
│                                      Contact            │
│                                      [Theme Toggle]     │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

**Design Details:**
- Soft cream background `#FAF7F5`
- Logo/name in Newsreader serif, large and elegant
- Subtitle "Visual Artist" in Montserrat, small caps, letterspaced
- Navigation links with wisteria purple underline on hover
- Delicate 1px border bottom in `#E8E3DD`

---

### Hero Section (Homepage)

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│                    [Featured Artwork]                   │
│                     Large Image Grid                    │
│                                                         │
│              Romantic. Expressive. Uplifting.           │
│                                                         │
│    Oil paintings from a cottage garden studio in Devon  │
│                                                         │
│                  [View Collections →]                   │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

**Design Details:**
- Asymmetric image grid with soft rounded corners
- Short tagline in Newsreader italic, centered
- Description in Montserrat light
- CTA button with wisteria purple fill `#C8A7D8`
- Generous padding: 6rem vertical

---

### Artwork Card Design

```
┌────────────────────────┐
│                        │
│    [Artwork Image]     │
│                        │
├────────────────────────┤
│ Title                  │
│ Medium, Year           │
│ £1,200                 │
└────────────────────────┘
```

**Design Details:**
- Soft border `#E8E3DD` with 8px border-radius
- Gentle purple shadow on hover (lift effect)
- Title in Newsreader serif
- Details in Montserrat, smaller, grey-purple
- Price in wisteria purple if available

---

### About Page Layout

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│                    About the Artist                     │
│                                                         │
│   ┌──────────────┐     Olivia Tew is a visual artist  │
│   │              │     who works from her cottage       │
│   │  Portrait    │     garden studio in a small        │
│   │  Photo       │     Devon village...                │
│   │              │                                      │
│   └──────────────┘     [Biography continues]           │
│                                                         │
│                        ~ Olivia                         │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

**Design Details:**
- Two-column layout: image + text
- Soft rounded portrait with subtle border
- Signature in Cormorant Garamond italic at end
- Pull quotes in larger Newsreader italic with wisteria color

---

### Footer

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│         Collections  |  About  |  Contact              │
│                                                         │
│              Instagram  •  Email  •  Newsletter         │
│                                                         │
│              © 2025 Olivia Tew. All rights reserved.   │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

**Design Details:**
- Soft cream background
- Delicate top border in taupe
- Links in muted purple
- Small Montserrat text
- Bullets as separator dots in wisteria purple

---

## Key Design Principles

### 1. Minimalist but Warm
**NOT**: Cold, stark white minimalism
**YES**: Warm, inviting minimalism with personality

### 2. Soft but Confident
**NOT**: Overly girly, saccharine, juvenile
**YES**: Sophisticated feminine, romantic, professional

### 3. Let Paintings Lead
**NOT**: Decorative website competing with art
**YES**: Subtle design that showcases vibrant paintings

### 4. Organic Not Rigid
**NOT**: Perfect grids, hard edges, corporate feel
**YES**: Gentle curves, asymmetry, breathing room

### 5. Garden-Inspired Not Literal
**NOT**: Flower graphics, vines, obvious botanical motifs
**YES**: Garden color palette, natural spacing, organic flow

---

## Comparison with Existing Themes

### Original Theme
- **Style**: Professional, corporate, Tailwind default
- **Colors**: Greys, blacks, whites
- **Feel**: Serious, straightforward
- **Best for**: Corporate portfolio

### Gallery Theme
- **Style**: Museum, elegant, serif-heavy
- **Colors**: Warm browns, creams, tans
- **Feel**: Refined, classical, formal
- **Best for**: Traditional gallery representation

### Cottage Theme (NEW)
- **Style**: Romantic minimalist, soft feminine
- **Colors**: Wisteria purples, sage greens, soft creams
- **Feel**: Warm, inviting, artistic, personal
- **Best for**: Artist's personal brand, direct collector sales

**Why All Three?**
- **Original**: For professional contexts (press, institutions)
- **Gallery**: For formal exhibitions and serious collectors
- **Cottage**: For personal connection, Instagram audience, emerging collectors

---

## Design Inspiration Examples

### Primary Inspiration: Erin Hanson Portfolio
**What to borrow:**
- Clean grid layouts for artwork
- Generous whitespace around images
- Simple filtering/navigation
- Neutral backgrounds letting paintings shine

**What to adapt:**
- Add warmer color palette (wisteria + sage vs. pure grey)
- Softer, more romantic typography
- Rounded corners vs. hard edges
- More personality and warmth

### Secondary Inspiration: Cottagecore Aesthetic
**What to borrow:**
- Soft, nature-inspired colors
- Romantic, nostalgic feeling
- Organic, relaxed layouts
- Vintage-inspired typography

**What to avoid:**
- Literal flower graphics
- Overly decorative elements
- Cluttered, busy layouts
- Juvenile or cutesy styling

---

## Technical Implementation Notes

### CSS Classes Naming Convention

```css
.cottage-heading        /* Large serif headings */
.cottage-subheading     /* Smaller serif headings */
.cottage-body           /* Body text sans-serif */
.cottage-accent         /* Italic serif accent text */
.cottage-card           /* Artwork/content cards */
.cottage-button         /* CTA buttons */
.cottage-link           /* Text links */
.cottage-divider        /* Section dividers */
.cottage-nav            /* Navigation elements */
```

### Color Variables (for consistency)

```css
:root {
  /* Neutrals */
  --cottage-cream: #FAF7F5;
  --cottage-beige: #F5F1ED;
  --cottage-taupe: #E8E3DD;

  /* Purples */
  --cottage-wisteria: #C8A7D8;
  --cottage-lavender: #B89AC5;
  --cottage-wisteria-light: #D4B5E0;
  --cottage-wisteria-deep: #A88AB7;

  /* Greens */
  --cottage-sage: #9FB8A3;
  --cottage-garden: #7A9B7E;

  /* Text */
  --cottage-text-dark: #4A3F4B;
  --cottage-text-medium: #6B5D66;
  --cottage-text-light: #8B7E87;
}
```

---

## Responsive Design Considerations

### Mobile (< 768px)
- Single column layouts
- Larger touch targets (48px minimum)
- Simplified navigation (hamburger menu)
- Larger font sizes for readability
- Reduced padding (2rem instead of 4rem)

### Tablet (768px - 1024px)
- Two-column layouts where appropriate
- Medium spacing
- Full navigation visible

### Desktop (> 1024px)
- Multi-column layouts (2-3 columns)
- Generous spacing as designed
- Hover effects enabled

---

## Accessibility Requirements

### Color Contrast
All text colors must meet WCAG AA standards:
- `#4A3F4B` on `#FAF7F5` ✓ (Ratio: 9.8:1)
- `#6B5D66` on `#FAF7F5` ✓ (Ratio: 5.8:1)
- `#C8A7D8` on `#FAF7F5` ⚠️ (Check for button text - may need darker variant)

### Focus States
```css
.cottage-link:focus,
.cottage-button:focus {
  outline: 2px solid #A88AB7;
  outline-offset: 2px;
}
```

### Semantic HTML
- Use proper heading hierarchy (h1 → h2 → h3)
- `<main>`, `<nav>`, `<footer>` landmarks
- Alt text for all artwork images
- ARIA labels where needed

---

## Content Strategy for Cottage Theme

### Tone of Voice
- **Warm**: "I'd love to hear from you"
- **Personal**: "From my cottage studio"
- **Confident**: "Bold, expressive work"
- **Inviting**: "Explore the collection"

### Imagery Style
- **Natural light photography**: Soft, bright
- **Lifestyle shots**: Paintings in homes, studio shots
- **Detail shots**: Close-ups of impasto texture
- **Behind-the-scenes**: Process, garden, inspiration

### Microcopy Examples
- Navigation: "Collections" not "Portfolio"
- CTA: "View the Collection →" not "See More"
- About: "Artist's Story" not "Biography"
- Contact: "Let's Connect" not "Contact Form"

---

## Success Metrics

How to know if Cottage theme is working:

### Qualitative
- Visitors say site feels "welcoming" and "beautiful"
- Matches Olivia's brand personality
- Collectors feel connected to artist's story
- Reflects cottage garden studio aesthetic

### Quantitative
- Time on site increases (engaged browsing)
- Contact form submissions increase
- Instagram/social media traffic converts better
- Returning visitors choose Cottage theme

---

## Implementation Roadmap

### Phase 1: Foundation (Week 1)
- [ ] Define color variables
- [ ] Load fonts (Newsreader, Montserrat)
- [ ] Create root layout conditional for "cottage" theme
- [ ] Build basic CSS classes
- [ ] Test color contrast and accessibility

### Phase 2: Components (Week 2)
- [ ] Header/navigation component
- [ ] Footer component
- [ ] Card component
- [ ] Button components
- [ ] Form styling

### Phase 3: Pages (Week 3)
- [ ] Homepage hero and featured work
- [ ] Collections index page
- [ ] Collection detail page
- [ ] Artwork detail page
- [ ] About page
- [ ] Contact page

### Phase 4: Polish (Week 4)
- [ ] Responsive testing all breakpoints
- [ ] Transitions and hover effects
- [ ] Loading states
- [ ] Error states
- [ ] Cross-browser testing
- [ ] Accessibility audit

---

## Summary

The **Cottage** theme bridges the gap between the professional Original theme and the formal Gallery theme by creating a **warm, romantic, personal** aesthetic that:

1. **Reflects Olivia's practice**: Cottage garden studio, Devon village, romantic aesthetic
2. **Showcases the work**: Minimalist approach lets vibrant paintings shine
3. **Attracts target audience**: Emerging collectors, Instagram followers, people seeking romantic art
4. **Differentiates brand**: Unique position in market - not corporate, not formal gallery

**Core Identity**: Romantic minimalism with garden-inspired palette - sophisticated, feminine, welcoming, and deeply connected to Olivia's artistic practice and location.

---

## Next Steps

1. Review this concept with stakeholder
2. Create mockups in Figma/design tool
3. Test color palette with actual painting images
4. Refine typography hierarchy
5. Begin implementation following THEME_IMPLEMENTATION_GUIDE.md
6. Iterate based on feedback

**Remember**: The goal is "soft and bold at the same time" - just like Olivia's paintings.
