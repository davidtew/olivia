# Media Analysis via Tidewave - Quick Reference

## Overview

This system allows you (Olivia) to analyze artwork images using Claude via Tidewave, with the analysis results saved directly to the database. No API keys required!

## How It Works

1. **Upload Image** → Goes to quarantine status at `/admin/media`
2. **Click "Analyze"** → Opens modal with context textarea
3. **Add Your Context** (optional) → Your thoughts, questions, or notes
4. **Click "Generate Prompt"** → System creates a complete Tidewave prompt
5. **Copy to Clipboard** → One-click copy of the full prompt
6. **Paste into Tidewave Chat** → This conversation interface
7. **Claude Analyzes** → Reads image, provides thoughtful analysis
8. **Auto-Saves to Database** → Results written to `media_analyses` and `media` tables
9. **UI Refreshes** → New analysis appears in the workspace

## User Journey

```
Media Workspace → Select Image → Analyze Button → Add Context →
Generate Prompt → Copy → Paste to Tidewave → Claude Executes →
Analysis Saved → Refresh UI → View Results
```

## What the Prompt Does

When you paste the generated prompt into Tidewave, Claude will:

### 1. Fetch Data
- Media file details (ID {{MEDIA_ID}})
- Previous analysis iterations
- Similar approved artworks for context
- Artist's notes for this iteration

### 2. Read the Image
- Locates file: `/Users/tewm3/olivia/priv/static/[url]`
- Reads and base64 encodes it
- Prepares for vision analysis

### 3. Analyze Thoughtfully
Provides multi-faceted interpretation covering:
- **Primary interpretation**: Subject, mood, visual language
- **Contextual possibilities**: Portfolio, series, marketing, process
- **Artistic connections**: Movements, artists, traditions
- **Provocations**: Questions to shift perspective
- **Classification**: Asset type, role, tags, alt text
- **Technical details**: Medium, style, colour palette, composition

### 4. Save Results
- Inserts new row in `media_analyses` table
- Updates `media` table with classification
- Links to previous iterations for dialogue continuity

## Files Created

### Core Modules
- **`lib/olivia/prompt_base/prompts/analyze_media.md`**
  - Master template with all instructions
  - Variable substitution: `{{MEDIA_ID}}`, `{{USER_CONTEXT}}`, etc.

- **`lib/olivia/prompt_base/media_analysis_prompt.ex`**
  - Elixir module for generating prompts
  - `generate(media_id, user_context)` → Full prompt
  - `generate_quick(media_id, user_context)` → Simplified version
  - `get_media_path(media_id)` → Just the file path

### UI Components
- **`lib/olivia_web/live/admin/media_live/workspace.ex`**
  - Updated modal with "Generate Prompt" workflow
  - Copy to clipboard button
  - Generated prompt display area

- **`assets/js/hooks/copy_to_clipboard.js`**
  - JavaScript hook for clipboard functionality
  - Visual feedback on copy
  - Fallback for older browsers

## Example Usage

### Scenario: First Analysis
1. Upload new painting → ID 5, status "quarantine"
2. Click image in workspace
3. Click "Analyze" button
4. Add context: "This explores the theme of isolation during lockdown"
5. Click "Generate Prompt"
6. Copy the generated prompt
7. Paste here in Tidewave
8. Claude reads `/Users/tewm3/olivia/priv/static/uploads/media/painting.jpg`
9. Provides analysis in JSON format
10. Saves as iteration 1 in `media_analyses`
11. Updates `media` table with classification

### Scenario: Iterative Refinement
1. Select same image (ID 5)
2. Click "Analyze" again
3. Add new context: "Actually, I want to emphasize the colour relationships"
4. Generate & copy new prompt
5. Paste to Tidewave
6. Claude sees previous analysis (iteration 1)
7. Builds on it with new focus
8. Saves as iteration 2
9. Media file updated with refined understanding

## Database Schema

### `media_analyses` Table
```sql
- id: integer (primary key)
- media_file_id: integer (foreign key to media)
- iteration: integer (1, 2, 3...)
- user_context: text (optional artist notes)
- llm_response: jsonb (full analysis JSON)
- model_used: string ("claude-via-tidewave")
- inserted_at: timestamp
- updated_at: timestamp
```

### `media` Table Updates
```sql
- asset_type: string (from classification)
- asset_role: string (from classification)
- alt_text: text (from classification)
- tags: string[] (from classification)
- metadata: jsonb (merged with interpretation, contexts, etc.)
```

## JSON Response Structure

Claude returns analysis in this format:

```json
{
  "interpretation": "2-3 paragraph analysis...",
  "contexts": [
    {
      "name": "Portfolio Display",
      "reasoning": "Why this fits...",
      "emphasis": "What to highlight...",
      "confidence": 0.85
    }
  ],
  "artistic_connections": ["Impressionism", "Cy Twombly"],
  "provocations": [
    "What if this negative space is the true subject?"
  ],
  "classification": {
    "asset_type": "artwork",
    "asset_role": "artwork_primary",
    "tags": ["oil_painting", "abstract", "gestural"],
    "alt_text": "Expressive oil painting...",
    "confidence": 0.9
  },
  "technical_details": {
    "medium": "Oil on canvas",
    "style": "Abstract Expressionism",
    "colour_palette": ["cerulean", "ochre", "crimson"],
    "composition": "Diagonal thrust with focal point upper-right"
  }
}
```

## British English

All analysis uses British spellings:
- colour (not color)
- analyse (not analyze)
- emphasise (not emphasize)
- centre (not center)
- organisation (not organization)

## Tips for Artist Context

Good context examples:
- "This was painted during a difficult emotional period"
- "I'm exploring the relationship between memory and place"
- "Does this work as a series opener?"
- "I'm unsure about the title - suggestions?"
- "How does this compare to my earlier work in the Blue series?"

Bad context examples:
- "Analyze this" (too vague)
- "What colours do you see?" (too literal - Claude can see)
- "Is this good?" (subjective, not productive)

## Troubleshooting

### Prompt doesn't generate
- Check that media ID exists in database
- Ensure `Olivia.PromptBase.MediaAnalysisPrompt` module is loaded
- Look for errors in Phoenix logs

### Can't copy to clipboard
- Check browser console for JavaScript errors
- Try manual select-all and copy
- Ensure hooks are registered in `app.js`

### Analysis doesn't save
- Check Tidewave has database access
- Verify SQL syntax in the save step
- Look for constraint violations (unique iteration, etc.)

### Image not found
- Verify file exists at path in prompt
- Check permissions on `priv/static/uploads/`
- Ensure URL in database matches file location

## Future Enhancements

Potential improvements:
- Auto-refresh UI after analysis (PubSub event)
- Analysis history viewer in modal
- Batch analysis for multiple images
- Export analyses to PDF/markdown
- Compare analyses across iterations
- Suggest next analysis questions based on previous responses

## Support

If something breaks:
1. Check Phoenix logs: `tail -f log/dev.log`
2. Check database: `mix ecto.query "SELECT * FROM media_analyses ORDER BY inserted_at DESC LIMIT 5"`
3. Test prompt generation: `Olivia.PromptBase.MediaAnalysisPrompt.generate(media_id)`
4. Verify media exists: `Olivia.Media.get_media!(media_id)`

Happy analyzing! 🎨✨
