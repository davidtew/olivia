# Deploying Series with Curator's Insights (Media Analyses)

## Overview

This document details the complete process for deploying a new series to production, including the **critical step** of uploading media analyses data that powers the curator's insights feature in lightbox modals.

**Related Documentation**:
- `/dos_donts/incremental_deployment.md` - General incremental deployment methodology
- `/dos_donts/theme_development.md` - Theme development patterns

---

## The Complete Deployment Checklist

When deploying a new series with curator's insights, you MUST upload:

- [ ] **Series record** (series table)
- [ ] **Artwork records** (artworks table)
- [ ] **Media file records** (media table)
- [ ] **Image files to S3** (Tigris storage)
- [ ] **Media analyses records** (media_analyses table) ← **CRITICAL - Don't forget!**

**Missing any of these will result in incomplete functionality.**

---

## Why Media Analyses Are Critical

### What Are Media Analyses?

Media analyses are database records in the `media_analyses` table that contain:

```elixir
# Schema: lib/olivia/media/analysis.ex
schema "media_analyses" do
  field :llm_response, :map  # JSONB containing interpretation and technical_details
  field :iteration, :integer
  belongs_to :media_file, Olivia.Media.MediaFile

  timestamps()
end
```

### The JSONB Structure

```json
{
  "interpretation": "Detailed curatorial interpretation of the artwork...",
  "technical_details": {
    "medium": "Oil on canvas",
    "style": "Contemporary expressionist figurative",
    "colour_palette": ["Prussian blue", "cadmium yellow", "flesh pink"],
    "composition": "Horizontal format with reclining figure..."
  }
}
```

### Where They Appear

Media analyses power the **curator's insights** section that appears in the lightbox modal when users click on artwork images:

```heex
<!-- lib/olivia_web/live/series_live/show.ex -->
<%= if @lightbox_artwork.latest_analysis && @lightbox_artwork.latest_analysis.llm_response do %>
  <div class="mt-6 space-y-4">
    <div>
      <h4 class="text-sm font-semibold text-gray-900 mb-2">Interpretation</h4>
      <p class="text-sm text-gray-600 leading-relaxed">
        <%= Map.get(@lightbox_artwork.latest_analysis.llm_response, "interpretation", "") %>
      </p>
    </div>

    <div>
      <h4 class="text-sm font-semibold text-gray-900 mb-2">Technical Details</h4>
      <!-- renders colour_palette, medium, style, composition -->
    </div>
  </div>
<% end %>
```

**Without media analyses**: The lightbox will display the enlarged image, but no interpretation or technical details will appear.

---

## Step-by-Step Deployment Process

### Prerequisites

1. Series works locally on `localhost:4000`
2. All artworks have media files uploaded locally
3. Media analyses have been generated locally (via `/admin/media` analyzer)
4. Code changes are committed

### Step 1: Deploy Code Changes

```bash
fly deploy -a olivia-art-portfolio
```

Wait for deployment to complete and verify:
```bash
fly status -a olivia-art-portfolio
fly logs -a olivia-art-portfolio
```

### Step 2: Extract Local Database Data

Use the MCP tool `mcp__Tidewave__execute_sql_query` or connect to local database:

```sql
-- Get series data
SELECT id, title, slug, summary, body_md, position, published
FROM series
WHERE slug = 'embodiment';

-- Get artworks data
SELECT id, title, slug, year, medium, description_md, position,
       published, series_id, status, currency, media_file_id
FROM artworks
WHERE series_id = 4
ORDER BY position;

-- Get media file data
SELECT id, filename, url, content_type, file_size, status, asset_type
FROM media
WHERE id IN (8, 29, 30, 32)
ORDER BY id;

-- Get media analyses data (CRITICAL!)
SELECT ma.id, ma.media_file_id, ma.llm_response, ma.iteration
FROM media_analyses ma
JOIN media m ON ma.media_file_id = m.id
JOIN artworks a ON a.media_file_id = m.id
WHERE a.series_id = 4
ORDER BY ma.media_file_id, ma.iteration DESC;
```

### Step 3: Create SQL Upload Script

Create a SQL script (e.g., `/tmp/insert_embodiment_full.sql`) with ALL data:

```sql
-- 1. Insert series
INSERT INTO series (id, title, slug, summary, body_md, position, published, inserted_at, updated_at)
VALUES (
  4,
  'Embodiment: Studies in Gesture and Form',
  'embodiment',
  'An investigation of the human figure...',
  'Body markdown content...',
  4,
  true,
  NOW(),
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  summary = EXCLUDED.summary,
  body_md = EXCLUDED.body_md,
  updated_at = NOW();

-- 2. Insert media files
INSERT INTO media (id, filename, url, content_type, file_size, status, asset_type, inserted_at, updated_at)
VALUES
  (8, 'She Lays Down.JPG', '/uploads/media/1763483281_a84d8a1756abb807.JPG', 'image/jpeg', 4831914, 'quarantine', 'artwork', NOW(), NOW()),
  (29, 'IN MOTION V.jpg', '/uploads/media/1763722108_e75261efc20f18a5.jpg', 'image/jpeg', 542819, 'quarantine', 'artwork', NOW(), NOW()),
  (30, 'IN MOTION IV.jpg', '/uploads/media/1763722108_d70e2e2341d3cccd.jpg', 'image/jpeg', 557338, 'quarantine', 'artwork', NOW(), NOW()),
  (32, 'IN MOTION III.jpg', '/uploads/media/1763722109_e4982724359e6940.jpg', 'image/jpeg', 626053, 'quarantine', 'artwork', NOW(), NOW())
ON CONFLICT (id) DO UPDATE SET
  filename = EXCLUDED.filename,
  url = EXCLUDED.url,
  updated_at = NOW();

-- 3. Insert artworks
INSERT INTO artworks (title, slug, year, medium, description_md, position, published, series_id, inserted_at, updated_at, status, currency, media_file_id)
VALUES
  ('She Lays Down', 'she-lays-down', 2024, 'Oil on canvas', '...', 1, true, 4, NOW(), NOW(), 'available', 'GBP', NULL),
  ('IN MOTION V', 'in-motion-v', 2024, 'Oil on canvas', '...', 2, true, 4, NOW(), NOW(), 'available', 'GBP', NULL),
  ('IN MOTION IV', 'in-motion-iv', 2024, 'Oil on canvas', '...', 3, true, 4, NOW(), NOW(), 'available', 'GBP', NULL),
  ('IN MOTION III', 'in-motion-iii', 2024, 'Oil on prepared ochre ground', '...', 4, true, 4, NOW(), NOW(), 'available', 'GBP', NULL)
ON CONFLICT (slug) DO UPDATE SET
  series_id = EXCLUDED.series_id,
  position = EXCLUDED.position,
  updated_at = NOW();

-- 4. Link artworks to media files
UPDATE artworks SET media_file_id = 8 WHERE slug = 'she-lays-down';
UPDATE artworks SET media_file_id = 29 WHERE slug = 'in-motion-v';
UPDATE artworks SET media_file_id = 30 WHERE slug = 'in-motion-iv';
UPDATE artworks SET media_file_id = 32 WHERE slug = 'in-motion-iii';

-- 5. Insert media analyses (CRITICAL STEP!)
-- Use PostgreSQL dollar-quote syntax for JSON with apostrophes

-- She Lays Down (media_file_id: 8, id: 3)
INSERT INTO media_analyses (id, media_file_id, llm_response, iteration, inserted_at, updated_at)
VALUES (
  3,
  8,
  $${"interpretation": "This figurative oil painting presents a reclining female nude rendered with confident, gestural brushwork against dramatically simplified colour fields. The composition divides into three primary zones: a deep Prussian blue backdrop, a warm yellow ground plane, and a vertical cream element at the right edge that suggests architectural space. The figure herself is constructed through an accumulation of flesh tones—pinks, mauves, ochres, and siennas—applied with directness that captures both the volume of the body and the immediacy of the painter's response to it.\n\nThe title 'She Lays Down' introduces a narrative dimension that transforms this from academic study to something more contemplative. There's a sense of surrender in the pose—knees raised, torso receding, head turned away—that suggests rest, vulnerability, or perhaps exhaustion. The simplified background refuses to provide context or setting, isolating the figure in a space that feels both protective and exposed.", "technical_details": {"medium": "Oil on canvas", "style": "Contemporary expressionist figurative", "colour_palette": ["Prussian blue", "cadmium yellow", "flesh pink", "raw sienna", "burnt umber", "mauve", "cream", "rose madder"], "composition": "Horizontal format with reclining figure spanning canvas; tripartite colour division (blue/yellow/cream) creating geometric tension with organic figure"}}$$::jsonb,
  1,
  NOW(),
  NOW()
) ON CONFLICT (id) DO UPDATE SET llm_response = EXCLUDED.llm_response, updated_at = NOW();

-- IN MOTION V (media_file_id: 29, id: 29)
INSERT INTO media_analyses (id, media_file_id, llm_response, iteration, inserted_at, updated_at)
VALUES (
  29,
  29,
  $${"interpretation": "This bold figure painting captures a woman bent forward at the waist—possibly picking something up from the ground—through economical, constructive mark-making against a vibrant pink-mauve ground. The pose is unconventional for figure painting: rather than the traditional standing contrapposto or reclining nude, we see the figure in active, everyday gesture, her torso parallel to the ground, arms reaching downward. The artist renders this challenging foreshortened view through rapid, gestural brushwork in ochres, yellows, burgundies, pale pinks, and touches of blue, building form through accumulated marks rather than conventional anatomical description.", "technical_details": {"medium": "Oil on canvas with prepared pink-mauve ground", "style": "Contemporary observational painting; gestural figuration with post-impressionist influences", "colour_palette": ["vibrant_pink_mauve", "ochre", "bright_yellow", "burgundy_red", "pale_pink", "earth_tones", "blue_accent"], "composition": "Figure bent forward at waist in horizontal orientation; foreshortened view; constructed through accumulated gestural marks"}}$$::jsonb,
  2,
  NOW(),
  NOW()
) ON CONFLICT (id) DO UPDATE SET llm_response = EXCLUDED.llm_response, iteration = EXCLUDED.iteration, updated_at = NOW();

-- IN MOTION IV (media_file_id: 30, id: 25)
INSERT INTO media_analyses (id, media_file_id, llm_response, iteration, inserted_at, updated_at)
VALUES (
  25,
  30,
  $${"interpretation": "This striking figure painting captures embodied motion through urgent, gestural mark-making against a saturated magenta-pink ground. The figure—rendered in flesh tones of ochre, cream, white, and sienna—emerges from and dissolves into the vibrant background, creating a sense of dynamic transformation rather than static pose. The body reads as caught mid-gesture: limbs extended, torso twisted, the entire form suggesting dance, yoga, or simply the unselfconscious movements of daily life elevated to painterly subject. The pink ground isn't merely background but active participant—it advances rather than recedes, creating compressed pictorial space that emphasises the figure's physicality whilst denying traditional depth.", "technical_details": {"medium": "Oil on canvas (or board)", "style": "Contemporary expressionist figure painting with Fauvist colour and loose gestural approach", "colour_palette": ["magenta_pink", "hot_pink", "ochre_yellow", "burnt_sienna", "cream_white", "flesh_pink", "deep_burgundy", "olive_green_accent"], "composition": "Vertical format emphasising upward energy; figure occupies central column with limbs extending to edges; compressed pictorial space created by advancing pink ground"}}$$::jsonb,
  1,
  NOW(),
  NOW()
) ON CONFLICT (id) DO UPDATE SET llm_response = EXCLUDED.llm_response, updated_at = NOW();

-- IN MOTION III (media_file_id: 32, id: 26)
INSERT INTO media_analyses (id, media_file_id, llm_response, iteration, inserted_at, updated_at)
VALUES (
  26,
  32,
  $${"interpretation": "This figure study demonstrates remarkable confidence in capturing the essential architecture of the human form through economical, decisive mark-making. Executed on a warm ochre-orange ground that provides both chromatic harmony and conceptual warmth, the painting depicts a classical contrapposto pose—a standing female torso with weight shifted to one leg, arms raised behind the head. The artist works with a limited palette of earth tones, ochres, purples, and highlights of pale yellow-white, building form through layered brushwork that feels both immediate and considered. The technique reveals an artist thinking through paint rather than drawing, with darker marks defining shadows and structure whilst lighter passages suggest planes catching light.", "technical_details": {"medium": "Oil on prepared ground (possibly canvas or board with ochre/terracotta underpainting)", "style": "Contemporary observational painting with classical references; life room practice", "colour_palette": ["warm_ochre_ground", "burnt_umber", "purple_browns", "raw_sienna", "pale_yellow_white", "terracotta"], "composition": "Single centralised figure, classical contrapposto stance, arms raised creating upward movement; figure emerges atmospherically from warm ground"}}$$::jsonb,
  1,
  NOW(),
  NOW()
) ON CONFLICT (id) DO UPDATE SET llm_response = EXCLUDED.llm_response, updated_at = NOW();

-- 6. Verify everything is linked correctly
SELECT a.id, a.title, a.slug, a.media_file_id,
       m.filename,
       ma.id as analysis_id,
       LENGTH(ma.llm_response::text) as analysis_length,
       ma.iteration
FROM artworks a
LEFT JOIN media m ON a.media_file_id = m.id
LEFT JOIN media_analyses ma ON m.id = ma.media_file_id
WHERE a.series_id = 4
ORDER BY a.position, ma.iteration DESC;
```

**Key Points**:

- **Use `$$...$$ ::jsonb`** for JSON with apostrophes (PostgreSQL dollar-quote syntax)
- **Use `ON CONFLICT` clauses** for idempotency (safe to re-run)
- **Include verification queries** at the end to confirm success
- **Link artworks to media AFTER** both are created (foreign key constraint)

### Step 4: Execute SQL on Production

```bash
fly postgres connect -a olivia-art-portfolio-db -d olivia_art_portfolio < /tmp/insert_embodiment_full.sql
```

**Expected Output**:
```
INSERT 0 1  (series)
INSERT 0 4  (media)
INSERT 0 4  (artworks)
UPDATE 4    (artwork-media links)
INSERT 0 1  (analysis 1)
INSERT 0 1  (analysis 2)
INSERT 0 1  (analysis 3)
INSERT 0 1  (analysis 4)

 id | title          | slug           | media_file_id | filename              | analysis_id | analysis_length | iteration
----+----------------+----------------+---------------+-----------------------+-------------+-----------------+-----------
  X | She Lays Down  | she-lays-down  |             8 | She Lays Down.JPG     |           3 |            1409 |         1
  X | IN MOTION V    | in-motion-v    |            29 | IN MOTION V.jpg       |          29 |            1137 |         2
  X | IN MOTION IV   | in-motion-iv   |            30 | IN MOTION IV.jpg      |          25 |            1244 |         1
  X | IN MOTION III  | in-motion-iii  |            32 | IN MOTION III.jpg     |          26 |            1281 |         1
```

**Critical Check**: Verify that `analysis_id` is NOT NULL and `analysis_length` > 0 for all artworks.

### Step 5: Upload Media Files to S3

Create upload script (see `/dos_donts/incremental_deployment.md` for template):

```bash
#!/bin/bash
# /tmp/upload_embodiment_images.sh

set -e

echo "Getting S3 credentials from Fly..."
AWS_ACCESS_KEY_ID=$(fly ssh console -a olivia-art-portfolio -C "printenv AWS_ACCESS_KEY_ID")
AWS_SECRET_ACCESS_KEY=$(fly ssh console -a olivia-art-portfolio -C "printenv AWS_SECRET_ACCESS_KEY")
AWS_ENDPOINT_URL=$(fly ssh console -a olivia-art-portfolio -C "printenv AWS_ENDPOINT_URL_S3")
BUCKET=$(fly ssh console -a olivia-art-portfolio -C "printenv S3_BUCKET")

export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_ENDPOINT_URL_S3=$AWS_ENDPOINT_URL
export AWS_REGION=auto

FILES=(
  "priv/static/uploads/media/1763483281_a84d8a1756abb807.JPG:uploads/media/1763483281_a84d8a1756abb807.JPG"
  "priv/static/uploads/media/1763722108_e75261efc20f18a5.jpg:uploads/media/1763722108_e75261efc20f18a5.jpg"
  "priv/static/uploads/media/1763722108_d70e2e2341d3cccd.jpg:uploads/media/1763722108_d70e2e2341d3cccd.jpg"
  "priv/static/uploads/media/1763722109_e4982724359e6940.jpg:uploads/media/1763722109_e4982724359e6940.jpg"
)

for file_pair in "${FILES[@]}"; do
  IFS=':' read -r local_path s3_key <<< "$file_pair"
  filename=$(basename "$local_path")
  echo "  Uploading $filename..."
  aws s3 cp "$local_path" "s3://$BUCKET/$s3_key"
  echo "  ✓ $filename uploaded"
done

echo "✓ All images uploaded!"
```

Run:
```bash
chmod +x /tmp/upload_embodiment_images.sh
/tmp/upload_embodiment_images.sh
```

### Step 6: Verify Production

1. **Check database**:
```bash
fly postgres connect -a olivia-art-portfolio-db -d olivia_art_portfolio
```

```sql
-- Verify analyses exist
SELECT ma.id, ma.media_file_id, ma.iteration, LENGTH(ma.llm_response::text) as response_length, a.title
FROM media_analyses ma
JOIN media m ON ma.media_file_id = m.id
JOIN artworks a ON a.media_file_id = m.id
WHERE a.series_id = 4
ORDER BY ma.media_file_id, ma.iteration DESC;
```

2. **Check S3**:
```bash
export AWS_ACCESS_KEY_ID=$(fly ssh console -a olivia-art-portfolio -C "printenv AWS_ACCESS_KEY_ID")
export AWS_SECRET_ACCESS_KEY=$(fly ssh console -a olivia-art-portfolio -C "printenv AWS_SECRET_ACCESS_KEY")
export AWS_ENDPOINT_URL_S3=$(fly ssh console -a olivia-art-portfolio -C "printenv AWS_ENDPOINT_URL_S3")
BUCKET=$(fly ssh console -a olivia-art-portfolio -C "printenv S3_BUCKET")

aws s3 ls "s3://$BUCKET/uploads/media/" | grep -E "(1763483281|1763722108|1763722109)"
```

3. **Check production website**:
- Visit `https://oliviatew.co.uk/series/embodiment`
- Click on any artwork image to open lightbox
- Verify **"Interpretation"** section appears below image
- Verify **"Technical Details"** section appears with colour palette, medium, style, composition
- Test all 4 artworks

---

## Troubleshooting

### Issue: Lightbox Shows Image But No Interpretation

**Symptom**: When clicking artwork images, the lightbox modal displays the enlarged image but the "Interpretation" and "Technical Details" sections are missing.

**Cause**: Missing `media_analyses` records in production database.

**Diagnosis**:
```sql
-- Check if analyses exist
SELECT a.id, a.title, a.media_file_id,
       ma.id as analysis_id,
       LENGTH(ma.llm_response::text) as response_length
FROM artworks a
LEFT JOIN media_analyses ma ON a.media_file_id = ma.media_file_id
WHERE a.series_id = 4;
```

If `analysis_id` is NULL for any artwork, analyses are missing.

**Solution**: Create and execute SQL script to insert analyses (see Step 3 above).

### Issue: JSON Syntax Errors When Uploading Analyses

**Error**: `ERROR: syntax error at or near "1"` or `ERROR: invalid input syntax for type json`

**Cause**: Single quotes, apostrophes, or newlines in JSON breaking SQL parser.

**Solution**: Use PostgreSQL dollar-quote syntax:
```sql
INSERT INTO media_analyses (id, media_file_id, llm_response, iteration, inserted_at, updated_at)
VALUES (
  3,
  8,
  $${"interpretation": "Text with apostrophes like 'this' works fine", "technical_details": {...}}$$::jsonb,
  1,
  NOW(),
  NOW()
);
```

**Key**: Everything between `$$` delimiters is treated as literal string. Cast to `::jsonb` at the end.

### Issue: Analysis Appears for Some Artworks But Not Others

**Cause**: Partial upload - some INSERT statements succeeded, others failed.

**Diagnosis**:
```sql
SELECT a.title, a.media_file_id, ma.id, ma.iteration
FROM artworks a
LEFT JOIN media_analyses ma ON a.media_file_id = ma.media_file_id
WHERE a.series_id = 4
ORDER BY a.position;
```

**Solution**: Re-run the SQL script - `ON CONFLICT` clauses make it safe to re-run, updating existing records and inserting missing ones.

---

## Real-World Example: Embodiment Series Deployment

### What Happened

**Initial deployment** (successful):
- ✓ Code deployed to production
- ✓ Series record created (id: 4)
- ✓ 4 Artwork records created
- ✓ 4 Media file records created
- ✓ Image files uploaded to S3
- ✗ **FORGOT to upload media_analyses records**

**Result**: Production showed Embodiment series, images loaded, lightbox worked, but **no curator's insights appeared**.

**Fix**: Created `/tmp/insert_analyses_simple.sql` with 4 INSERT statements using dollar-quote syntax, uploaded to production.

**Outcome**: All 4 analyses successfully inserted, curator's insights now appear in lightbox on production.

### Lesson Learned

**Always verify analyses are uploaded** by checking:
1. Database has records in `media_analyses` table
2. Production lightbox displays interpretation text
3. All artworks in series have analyses (not just some)

---

## DOs and DON'Ts

### ✅ DO

- **DO** upload media analyses records as part of series deployment
- **DO** use PostgreSQL dollar-quote syntax (`$$...$$::jsonb`) for JSON
- **DO** include verification queries in SQL scripts
- **DO** test lightbox on production after deployment
- **DO** check that ALL artworks have analyses (not just first one)
- **DO** use `ON CONFLICT` clauses for idempotent SQL
- **DO** keep SQL scripts in version control for reference

### ❌ DON'T

- **DON'T** forget to upload analyses - they're as critical as images
- **DON'T** try to escape JSON manually with `\'` - use dollar-quotes
- **DON'T** assume code deployment includes data
- **DON'T** skip verification step after deployment
- **DON'T** upload only some analyses - ensure completeness

---

## Generating Analyses Locally

If you need to generate analyses for new artworks before deployment:

1. **Upload artwork locally** via `/admin/artworks` on `localhost:4000`
2. **Upload media file** for the artwork
3. **Navigate to `/admin/media`**
4. **Find the media file** in the table
5. **Click "Analyze"** button to generate curator's insights
6. **Review and edit** the generated interpretation if needed
7. **Extract data** for production upload using SQL query:

```sql
SELECT ma.id, ma.media_file_id, ma.llm_response, ma.iteration
FROM media_analyses ma
JOIN media m ON ma.media_file_id = m.id
JOIN artworks a ON a.media_file_id = m.id
WHERE a.slug = 'your-artwork-slug';
```

8. **Format as INSERT statement** with dollar-quote syntax
9. **Upload to production** as part of deployment

---

## Summary

**Complete Series Deployment = Data + Code + Media + Analyses**

1. Deploy code changes
2. Upload database records (series, artworks, media, **analyses**)
3. Upload image files to S3
4. Verify all components work together on production

**The media_analyses table is NOT optional** if you want curator's insights to appear in lightbox modals.

**Always include this step in your deployment checklist.**
