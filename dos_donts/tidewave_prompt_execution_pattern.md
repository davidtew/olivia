# Tidewave Prompt Execution Pattern: Understanding Action vs. Discussion

## The Core Problem

When Claude receives a prompt in a Tidewave chat interface, it must determine:
1. **Should I execute these instructions?** (Action mode)
2. **Should I discuss/analyse these instructions?** (Discussion mode)

Without clear signals, Claude defaults to discussion mode, treating prompts as documentation to comment on rather than tasks to execute.

## Why This Matters

In the Olivia media analysis workflow, we generate prompts that contain:
- SQL queries to run
- Image files to read
- Analyses to perform
- Database updates to execute

When the user pastes these prompts into Tidewave, Claude MUST execute them, not discuss them.

## The Solution: Clear Action Signals

### ✅ DO: Make prompts unambiguously executable

```markdown
# EXECUTE: Media Analysis for ID 4

**ACTION REQUIRED**: Please execute this entire workflow immediately.
This is not documentation - these are executable instructions.

## Step 1: Fetch and display media information

Execute this SQL query using the Tidewave MCP tool:
Query the media table for ID 4 to get: filename, url...

## Step 2: Read the image file

The media URL from step 1 will be something like `/uploads/media/filename.jpg`.
Construct the full path: `/Users/tewm3/olivia/priv/static` + the URL
Use the Read tool to read this image file.
```

**Key characteristics:**
- Header includes "EXECUTE:" - signals immediate action
- "ACTION REQUIRED" in bold at the top
- Imperative language: "Execute this", "Read this", "Provide your analysis"
- No code blocks (```elixir```) that look like examples
- Direct, instructional tone throughout

### ❌ DON'T: Use documentation-style formatting

```markdown
# Media Analysis Prompt

## Instructions for Claude

Please execute the following:

```elixir
# Example code
media_query = """
SELECT * FROM media WHERE id = 4
"""
```

You should then...
```

**Why this fails:**
- Code blocks look like examples/documentation
- Passive language: "You should", "Please execute"
- No urgency signal
- Reads like a tutorial, not a task

## The Tidewave Context

### What is Tidewave?

Tidewave is an MCP (Model Context Protocol) integration that gives Claude:
1. **Direct file system access** - Can read images from `/Users/tewm3/olivia/priv/static/`
2. **Direct database access** - Can query and update PostgreSQL via MCP tools
3. **No API keys required** - Works through MCP, not external API calls

### The Workflow in Olivia

The complete pipeline demonstrates this pattern:

#### 1. User uploads image → Quarantine status
**Location**: `/admin/media`
**File**: `lib/olivia_web/live/admin/media_live/workspace.ex`

#### 2. User clicks image → Details panel appears
**Trigger**: `phx-click="select_media"` (line 80)
**Handler**: `handle_event("select_media", ...)` (line 453)
**Result**: `@selected_media` is set, details panel renders (line 126)

#### 3. User clicks "Analyze" button → Modal opens
**Button**: Lines 176-183 (now shows for all media, not just quarantine)
**Trigger**: `phx-click="show_analysis_modal"`
**Handler**: `handle_event("show_analysis_modal", ...)` (line 443)
**Modal**: Lines 289-393

#### 4. User adds context → Clicks "Generate Prompt"
**Form**: Lines 353-386
**Trigger**: `phx-submit="generate_prompt"`
**Handler**: `handle_event("generate_prompt", ...)` (line 453)

#### 5. Prompt generation happens
**File**: `lib/olivia/prompt_base/media_analysis_prompt.ex`
**Function**: `generate(media_id, user_context)`
**Template**: `lib/olivia/prompt_base/prompts/analyze_media.md`
**Result**: Action-oriented prompt with:
- Media ID substituted: `{{MEDIA_ID}}` → `4`
- Iteration number: `{{NEXT_ITERATION}}` → `1`
- User context: `{{USER_CONTEXT}}` → `"Olivia: one of my favourite works..."`

#### 6. User clicks "Copy to Clipboard"
**Button**: Lines 311-318
**Hook**: `phx-hook="CopyToClipboard"` (JavaScript)
**File**: `assets/js/hooks/copy_to_clipboard.js`
**Result**: Entire prompt copied to clipboard

#### 7. User pastes into Tidewave chat
**THIS IS THE CRITICAL MOMENT**: Claude must recognize this as executable

#### 8. Claude executes the workflow
- Fetches media info via `mcp__Tidewave__execute_sql_query`
- Fetches previous analyses via SQL
- Fetches similar works via SQL
- Reads image via `Read` tool with full path
- Analyses the artwork (vision + context)
- Provides JSON response
- Saves to `media_analyses` table via SQL INSERT
- Updates `media` table via SQL UPDATE

#### 9. UI refreshes (automatic LiveView update)
**Location**: Analysis History section (lines 199-265)
**Data**: `@analyses` populated via `Media.list_analyses(media_id)`

## Key Implementation Files

### 1. Prompt Template
**File**: `lib/olivia/prompt_base/prompts/analyze_media.md`
**Purpose**: Action-oriented template with variable substitution
**Key feature**: No code blocks, imperative language, "EXECUTE:" header

### 2. Prompt Generator
**File**: `lib/olivia/prompt_base/media_analysis_prompt.ex`
**Functions**:
- `generate(media_id, user_context)` - Full analysis prompt
- `generate_quick(media_id, user_context)` - Simplified version
- `get_media_path(media_id)` - Path helper

**Variable substitution**:
```elixir
template
|> String.replace("{{MEDIA_ID}}", to_string(media_id))
|> String.replace("{{NEXT_ITERATION}}", to_string(next_iteration))
|> handle_user_context(user_context)
```

### 3. Workspace LiveView
**File**: `lib/olivia_web/live/admin/media_live/workspace.ex`
**Key sections**:
- Line 80: Click handler on media cards
- Lines 126-265: Details panel (shows when `@selected_media` is set)
- Lines 176-183: Analyze button (now always visible)
- Lines 289-393: Analysis modal with two states:
  - Input state: Context textarea + Generate Prompt button
  - Display state: Generated prompt + Copy to Clipboard button
- Line 453: `generate_prompt` event handler

### 4. Clipboard Hook
**File**: `assets/js/hooks/copy_to_clipboard.js`
**Purpose**: Copies text from `#generated-prompt` element
**Registered in**: `assets/js/app.js` (line 37)

### 5. Database Schema
**Tables**:
- `media` - Stores images with metadata
- `media_analyses` - Stores each analysis iteration
  - `media_file_id` - Links to media
  - `iteration` - 1, 2, 3... (allows iterative refinement)
  - `user_context` - Artist's notes for this iteration
  - `llm_response` - Full JSON analysis
  - `model_used` - "claude-via-tidewave"

## Why the Action-Oriented Format Works

1. **Clear Intent**: "EXECUTE:" header removes ambiguity
2. **Immediate Urgency**: "ACTION REQUIRED" at the top
3. **No Code Blocks**: Without ```blocks```, nothing looks like "example code"
4. **Imperative Verbs**: "Execute", "Read", "Provide", "Save"
5. **Concrete Steps**: Numbered, specific actions
6. **Context Included**: Artist's notes embedded, not separate

## Testing the Pattern

When you receive a prompt:
- ✅ Starts with "EXECUTE:" → Perform the actions
- ✅ Contains "ACTION REQUIRED" → This is a task, not documentation
- ✅ Steps are numbered with imperative verbs → Follow them sequentially
- ❌ Contains code blocks with examples → You're discussing, not executing
- ❌ Uses passive language like "should" or "could" → This is advisory

## Common Pitfalls

### Pitfall 1: Claude discusses instead of executing
**Cause**: Prompt looked like documentation
**Solution**: Stronger action signals at the top

### Pitfall 2: Claude executes partially
**Cause**: Some steps looked optional
**Solution**: Every step is imperative, none are conditional

### Pitfall 3: User confused about what to paste
**Cause**: Unclear that the generated prompt goes into Tidewave chat
**Solution**: Modal explains: "Copy this prompt and paste it into the Tidewave chat interface."

## Future Enhancements

Potential improvements to consider:
1. **Auto-paste to Tidewave**: Could we directly send prompts to this chat interface?
2. **Progress tracking**: Show which steps are being executed
3. **Batch analysis**: Generate prompts for multiple images
4. **Analysis comparison**: Side-by-side view of iterations
5. **Suggested next questions**: Based on previous analysis, suggest context for next iteration

## Related Documentation

- `lib/olivia/prompt_base/prompts/README.md` - User-facing guide to the system
- `SNAPSHOT_POLICY.md` - How the project manages snapshots (separate concern)

## Summary

The key insight: **Claude in Tidewave needs explicit action signals to distinguish between "discuss this prompt" and "execute this prompt"**. The solution is a template format that uses:
- Clear headers ("EXECUTE:")
- Urgent language ("ACTION REQUIRED")
- Imperative verbs throughout
- No code blocks that look like examples
- Numbered steps that feel like a checklist to complete

This pattern enables the iterative media analysis workflow where Olivia (the artist) can have a dialogue with Claude about her artwork, with each analysis building on previous iterations.
