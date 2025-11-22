# Interactive Artwork Features - Implementation Spec

## Overview

This document outlines interactive features to add value and engagement to artwork presentations, particularly for the Embodiment series as a proof-of-concept.

## Feature 1: Expandable Curator's Insights

### What It Does
Each artwork card has a "View Curator's Insights" button that expands to reveal:
- Deep AI-generated art-historical analysis
- Technical details (palette, composition, medium)
- Contextual interpretation
- Artistic influences and references

### Implementation

**Frontend (Alpine.js or LiveView)**
```heex
<div class="mt-4" x-data="{ open: false }">
  <button
    @click="open = !open"
    class="text-sm font-semibold text-gray-600 hover:text-gray-900"
  >
    <span x-show="!open">View Curator's Insights →</span>
    <span x-show="open">Hide Insights ←</span>
  </button>

  <div
    x-show="open"
    x-collapse
    class="mt-4 p-4 bg-gray-50 rounded-lg prose prose-sm"
  >
    <h4>Interpretation</h4>
    <p><%= artwork.latest_analysis.llm_response["interpretation"] %></p>

    <h4>Technical Details</h4>
    <ul>
      <li><strong>Palette:</strong> <%= Enum.join(artwork.latest_analysis.llm_response["technical_details"]["colour_palette"], ", ") %></li>
      <li><strong>Composition:</strong> <%= artwork.latest_analysis.llm_response["technical_details"]["composition"] %></li>
      <li><strong>Style:</strong> <%= artwork.latest_analysis.llm_response["technical_details"]["style"] %></li>
    </ul>
  </div>
</div>
```

**Data Requirements**
- Artworks must have `latest_analysis` preloaded
- Analysis must contain `llm_response` with interpretation and technical_details

### Value Proposition
- **Educational**: Teaches visitors about art appreciation
- **Authoritative**: Shows depth of curatorial knowledge
- **Engaging**: Encourages longer page visits
- **Differentiating**: Unique feature not found on typical artist websites

---

## Feature 2: Image Zoom with Hotspots

### What It Does
Click on an artwork image to:
1. Open full-screen lightbox view
2. Show interactive hotspots on specific areas
3. Hotspots reveal focused commentary when clicked

### Implementation Approach

**Libraries Needed**
- PhotoSwipe or similar lightbox library
- Custom hotspot overlay system

**Data Structure** (store in `artwork.metadata` or separate table):
```json
{
  "hotspots": [
    {
      "x": 45,
      "y": 30,
      "label": "Gesture",
      "commentary": "Note the economical mark-making that suggests the arm's reach without detailed anatomical rendering."
    },
    {
      "x": 60,
      "y": 75,
      "label": "Ground",
      "commentary": "The warm ochre ground participates actively, creating atmospheric emergence rather than mere background."
    }
  ]
}
```

**UI Flow**
1. User clicks artwork image
2. Lightbox opens with full-resolution image
3. Subtle pulse indicators show hotspot locations
4. Click hotspot → popup with commentary
5. Navigate between artworks in lightbox

### Value Proposition
- **Interactive**: Transforms passive viewing into active exploration
- **Educational**: Directs attention to specific technical/compositional choices
- **Premium**: Signals high-value presentation
- **Scalable**: Can add more hotspots over time

---

## Feature 3: Comparative Slider

### What It Does
Shows two artworks side-by-side with:
- Synchronized zoom
- Draggable divider to compare
- Highlights similarities/differences in approach

### Implementation

**UI Component**
```heex
<div class="comparative-view hidden" id="compare-modal">
  <div class="grid grid-cols-2 gap-4">
    <div>
      <img id="compare-image-1" />
      <h3 id="compare-title-1"></h3>
    </div>
    <div>
      <img id="compare-image-2" />
      <h3 id="compare-title-2"></h3>
    </div>
  </div>
  <div class="mt-4 prose">
    <p id="compare-commentary"></p>
  </div>
</div>
```

**Interaction**
- Checkbox on each artwork: "Select to compare"
- Once 2 selected → "Compare Selected" button appears
- Opens modal with side-by-side view + AI-generated comparison

### Value Proposition
- **Educational**: Shows artistic evolution within series
- **Engagement**: Encourages viewing multiple works
- **Sophisticated**: Appeals to serious collectors/critics

---

## Feature 4: Technical Process Timeline

### What It Does
If progress photos exist, shows painting evolution:
- Underpainting → blocking → details → finish
- Slider to scrub through stages
- Commentary on each stage's decisions

### Implementation

**Data Requirements**
- Multiple images per artwork stored in order
- Associated commentary for each stage

**UI**
```heex
<div x-data="{ stage: 0, stages: <%= length(@progress_images) %> }">
  <img :src="progressImages[stage]" />
  <input
    type="range"
    min="0"
    :max="stages - 1"
    x-model="stage"
    class="w-full"
  />
  <p x-text="commentary[stage]"></p>
  <div class="text-xs text-gray-500">
    Stage <span x-text="stage + 1"></span> of <span x-text="stages"></span>
  </div>
</div>
```

### Value Proposition
- **Transparency**: Shows skill and time investment
- **Educational**: Demystifies artistic process
- **Authenticity**: Connects viewer to artist's journey

---

## Feature 5: "See In Your Space" AR Preview

### What It Does
Mobile button that uses phone camera to overlay artwork at correct scale on a wall

### Implementation

**Libraries**
- AR.js or model-viewer with AR mode
- Requires artwork dimensions in database

**Code Example**
```html
<model-viewer
  ar
  ar-modes="scene-viewer webxr quick-look"
  src="artwork-plane.glb"
  camera-controls
  ios-src="artwork.usdz"
>
  <button slot="ar-button">
    View in Your Space
  </button>
</model-viewer>
```

### Value Proposition
- **Practical**: Helps collectors visualize purchase
- **Modern**: Shows technical sophistication
- **Mobile-First**: Targets how people actually browse

---

## Recommended Implementation Order

### Phase 1: Curator's Insights (Immediate)
- Easiest to implement
- Uses existing AI analysis data
- Highest value-to-effort ratio
- Can deploy this week

### Phase 2: Image Zoom (Next Sprint)
- Requires lightbox library integration
- Hotspots can be added manually via admin
- Moderate complexity

### Phase 3: Comparative Slider (Future)
- Requires building comparison UI
- May need AI to generate comparison commentary
- Medium priority

### Phase 4: AR Preview (Future)
- Requires 3D model generation
- Most complex technically
- High "wow factor" but lower practical value initially

### Phase 5: Process Timeline (When Available)
- Requires Olivia to photograph work-in-progress
- Can't implement until content exists
- Very high value once available

---

## Data Schema Changes Needed

### For Curator's Insights (Phase 1)
✅ Already have this data in `media_analyses.llm_response`

### For Hotspots (Phase 2)
Add to `artworks.metadata` or create new table:
```sql
CREATE TABLE artwork_hotspots (
  id SERIAL PRIMARY KEY,
  artwork_id INTEGER REFERENCES artworks(id),
  x_percent DECIMAL(5,2), -- percentage from left
  y_percent DECIMAL(5,2), -- percentage from top
  label VARCHAR(100),
  commentary TEXT,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
```

### For Progress Photos (Phase 5)
```sql
CREATE TABLE artwork_progress_images (
  id SERIAL PRIMARY KEY,
  artwork_id INTEGER REFERENCES artworks(id),
  stage_number INTEGER,
  image_url VARCHAR(255),
  caption TEXT,
  created_at TIMESTAMP
);
```

---

## Existing Data: Embodiment Series

We currently have complete AI analysis for all 4 Embodiment works:

**IN MOTION III** (ID: 32)
- Interpretation: Classical contrapposto on ochre ground
- Palette: warm_ochre_ground, burnt_umber, purple_browns, raw_sienna, pale_yellow_white, terracotta
- Style: Contemporary observational painting with classical references

**IN MOTION IV** (ID: 30)
- Interpretation: Dynamic figure on saturated magenta-pink ground
- Palette: magenta_pink, hot_pink, ochre_yellow, burnt_sienna, cream_white
- Style: Contemporary expressionist figure painting with Fauvist colour

**IN MOTION V** (ID: 29)
- Interpretation: Woman bending forward on pink-mauve ground
- Palette: vibrant_pink_mauve, ochre, bright_yellow, burgundy_red, pale_pink
- Style: Contemporary observational painting; gestural figuration

**She Lays Down** (ID: 8)
- Interpretation: Reclining nude with simplified colour fields
- Palette: Prussian blue, cadmium yellow, flesh pink, raw sienna, burnt umber
- Style: Contemporary expressionist figurative

---

## Next Steps

1. **Implement Phase 1** (Curator's Insights) on Embodiment series as proof-of-concept
2. **User test** with Olivia and potential collectors
3. **Measure engagement** (time on page, click-through rates)
4. **Iterate** based on feedback
5. **Roll out** to other series if successful
6. **Plan Phase 2** based on Phase 1 results

---

## Notes

- All features should have annotation support for reviewer theme
- Mobile-first design essential (most traffic is mobile)
- Keep accessibility in mind (keyboard navigation, screen readers)
- Progressive enhancement: features should degrade gracefully
- Consider performance: lazy-load analysis text, optimize images
