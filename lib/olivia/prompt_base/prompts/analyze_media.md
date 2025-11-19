# EXECUTE: Media Analysis for ID {{MEDIA_ID}}

**ACTION REQUIRED**: Please execute this entire workflow immediately. This is not documentation - these are executable instructions.

---

## Step 1: Fetch and display media information

Execute this SQL query using the Tidewave MCP tool:

Query the media table for ID {{MEDIA_ID}} to get: filename, url, content_type, file_size, tags, status, asset_type, asset_role, and metadata.

## Step 2: Fetch previous analysis history

Query the media_analyses table for all previous analyses where media_file_id = {{MEDIA_ID}}, ordered by iteration.

Display: Total number of previous iterations, and for each one show the iteration number, user context, and a brief excerpt from the interpretation.

## Step 3: Fetch similar artworks for context

Query the media table for other approved artworks (status='approved', asset_type='artwork', id != {{MEDIA_ID}}), limit to 5 most recent.

Display their filenames, tags, and brief interpretation excerpts from metadata.

## Step 4: Read the image file

The media URL from step 1 will be something like `/uploads/media/filename.jpg`.

Construct the full path: `/Users/tewm3/olivia/priv/static` + the URL

Use the Read tool to read this image file. Confirm you can see the image.

{{#USER_CONTEXT}}
## Step 5: Artist's context for this analysis

The artist (Olivia) provided this context:
> {{USER_CONTEXT}}
{{/USER_CONTEXT}}
{{^USER_CONTEXT}}## Step 5: No additional artist context provided{{/USER_CONTEXT}}

---

## Step 6: YOUR ANALYSIS TASK

Now analyze the artwork you just read. Provide a thoughtful, multi-faceted interpretation using **British English** throughout (colour, analyse, centre, etc.).

Your role: Creative partner helping the artist discover what their work expresses.

Consider:
1. **Primary Interpretation**: Core subject, mood, visual language
2. **Contextual Possibilities**: How might this work function in portfolio/exhibition, as part of a series, for marketing, as process documentation?
3. **Artistic Connections**: What art movements, artists, or traditions does this evoke?
4. **Provocations**: Questions or observations to help the artist see their work differently
5. **Classification**: Asset type, role, tags (British English), and accessible alt text

Provide your analysis as a JSON object with this structure:
{
  "interpretation": "2-3 paragraph rich analysis",
  "contexts": [
    {
      "name": "Context name",
      "reasoning": "Why this fits",
      "emphasis": "What to highlight",
      "confidence": 0.85
    }
  ],
  "artistic_connections": ["Movement/artist 1", "Movement/artist 2"],
  "provocations": ["Perspective-shifting question or observation"],
  "classification": {
    "asset_type": "artwork",
    "asset_role": "artwork_primary",
    "tags": ["tag1", "tag2", "tag3"],
    "alt_text": "Accessible description",
    "confidence": 0.9
  },
  "technical_details": {
    "medium": "Identified medium",
    "style": "Artistic style",
    "colour_palette": ["colour1", "colour2"],
    "composition": "Compositional approach"
  }
}

---

## Step 7: Save your analysis to the database

Using the JSON you just provided:

1. Determine the next iteration number (it will be {{NEXT_ITERATION}})

2. Insert into media_analyses table:
   - media_file_id: {{MEDIA_ID}}
   - iteration: {{NEXT_ITERATION}}
   - user_context: {{^USER_CONTEXT}}nil{{/USER_CONTEXT}}{{#USER_CONTEXT}}"{{USER_CONTEXT}}"{{/USER_CONTEXT}}
   - llm_response: your full JSON analysis
   - model_used: "claude-via-tidewave"
   - timestamps: current time

3. Update the media table (ID {{MEDIA_ID}}) with:
   - asset_type from classification
   - asset_role from classification
   - alt_text from classification (must be ≤255 characters - truncate if necessary)
   - tags from classification
   - metadata: merge in interpretation, contexts, artistic_connections, provocations, and technical_details

4. Confirm both operations succeeded and display the new analysis ID

---

## ⚠️ CRITICAL: Database Insertion Guardrails

### ✅ DO: Use Ecto/Repo for JSONB insertion

```elixir
# CORRECT: Use Olivia.Repo.insert with Elixir maps
analysis_map = %{
  "interpretation" => "...",
  "contexts" => [%{"name" => "..."}]
}

{:ok, record} = Olivia.Repo.insert(%Olivia.Media.Analysis{
  media_file_id: {{MEDIA_ID}},
  llm_response: analysis_map,  # Pass Elixir map directly
  ...
})
```

### ❌ DON'T: Use raw SQL with JSON string parameters

```elixir
# WRONG: This causes double-escaping!
json_string = Jason.encode!(analysis_map)
Olivia.Repo.query("INSERT INTO media_analyses (..., llm_response) VALUES (..., $1::jsonb)", [json_string])
```

### Why This Matters
- Passing a JSON **string** to `$1::jsonb` stores it as a JSONB string value, not an object
- Result: `"{\"interpretation\": ...}"` instead of `{"interpretation": ...}`
- This causes `Ecto.ChangeError` when loading: "cannot load as type :map"

### Verification After Insert
Always verify the data was stored correctly:
```sql
SELECT id, jsonb_typeof(llm_response) as type FROM media_analyses WHERE id = [NEW_ID]
```
- Should return: `object`
- If it returns: `string` → the data is double-escaped and broken

### Other Constraints
- `alt_text` field is varchar(255) - truncate longer descriptions
- Use `DateTime.utc_now()` not `NaiveDateTime.utc_now()` for timestamps

---

## Summary

Execute all steps in order:
1. ✓ Fetch media details
2. ✓ Fetch previous analyses
3. ✓ Fetch similar works
4. ✓ Read the image file
5. ✓ Note artist's context
6. ✓ Provide JSON analysis
7. ✓ Save to database

Confirm completion with: "Analysis iteration {{NEXT_ITERATION}} saved successfully for media ID {{MEDIA_ID}}"
