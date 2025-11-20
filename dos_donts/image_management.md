# Image Management: Upload, Storage, and Display

## Context: The Problem We Solved

This document captures hard-won lessons from debugging image display failures in production. The core issue was **403 Access Denied errors** for images stored in Tigris S3-compatible storage on Fly.io. What seemed like a simple "images not showing" bug revealed fundamental architectural decisions that need to be followed consistently.

---

## DON'Ts - Patterns That Caused Failures

### 1. DON'T Use Path-Style S3 URLs for Public Access

**The Problem**: Tigris (and many S3-compatible services) require **subdomain-style URLs** for public bucket access.

```
# WRONG - Returns 403 Access Denied
https://fly.storage.tigris.dev/falling-sky-1523/uploads/media/image.jpg

# CORRECT - Returns 200 OK
https://falling-sky-1523.fly.storage.tigris.dev/uploads/media/image.jpg
```

**Why This Happened**: The default S3 public URL format in runtime.exs used path-style. This works for authenticated API calls but fails for public browser access.

### 2. DON'T Hardcode Image URLs Without `resolve_asset_url/1`

**The Problem**: Multiple LiveView files had hardcoded image paths that worked in development but failed in production.

```elixir
# WRONG - Works locally, fails in production
src="/uploads/media/1763542139_3020310155b8abcf.jpg"

# CORRECT - Resolves to S3 URL in production
src={resolve_asset_url("/uploads/media/1763542139_3020310155b8abcf.jpg")}
```

**Why This Happened**: Initial development used local file paths. When moving to S3, these weren't updated to use the URL resolver.

### 3. DON'T Assume Database Records Have Images

**The Problem**: Templates checked for `series.cover_image_url` but the database records had `nil` values. Fallback logic existed but couldn't work because the associated artworks also had no `image_url`.

```elixir
# This shows "No image" when cover_image_url is nil AND artworks have no images
<div :if={series.cover_image_url}>...</div>
```

**Why This Happened**:
- Series were created without cover images
- Artworks were created without image URLs assigned
- The data model assumed images would be populated but the workflow didn't enforce it

### 4. DON'T Mix Static and Dynamic Content Approaches

**The Problem**: Some pages used hardcoded images (work_live.ex, process_live.ex, series_live/index.ex default theme) while others pulled from database (series_live/show.ex, cottage/gallery themes). This created inconsistent behavior.

**Why This Happened**: Different development phases used different approaches without a unified strategy.

### 5. DON'T Rely on ACL Settings Alone

**The Problem**: Even with `--acl public-read` on objects, the wrong URL format still returned 403.

**Why This Happened**: ACL controls *permission* but URL format controls *routing*. Both must be correct.

---

## DOs - Patterns That Work

### 1. DO Configure S3_PUBLIC_URL with Subdomain-Style Format

In `fly secrets`:
```bash
fly secrets set S3_PUBLIC_URL="https://<bucket-name>.fly.storage.tigris.dev" -a <app-name>
```

Example:
```bash
fly secrets set S3_PUBLIC_URL="https://falling-sky-1523.fly.storage.tigris.dev" -a olivia-art-portfolio
```

**Verify with**:
```bash
curl -I "https://<bucket-name>.fly.storage.tigris.dev/uploads/media/<filename>"
# Should return HTTP/2 200
```

### 2. DO Always Use `resolve_asset_url/1` for Image Sources

Every image URL in templates must use the helper:

```elixir
# In your LiveView module
import OliviaWeb.AssetHelpers, only: [resolve_asset_url: 1]

# In template
<img src={resolve_asset_url("/uploads/media/filename.jpg")} />
```

The helper (`lib/olivia_web/helpers/asset_helpers.ex`) automatically:
- Returns path as-is in development
- Prepends S3 URL in production (when `PHX_HOST` is set)

### 3. DO Populate Image URLs When Creating Records

**For Artworks**: Always set `image_url` when creating/updating:
```elixir
%Artwork{
  title: "Morning Light",
  image_url: "/uploads/media/1763542139_abc123.jpg",
  ...
}
```

**For Series**: Either set `cover_image_url` directly OR ensure at least one artwork has an `image_url`:
```elixir
# Option 1: Direct cover image
%Series{cover_image_url: "/uploads/media/cover.jpg", ...}

# Option 2: Fallback to first artwork (requires artworks to have images)
# The resolved_cover_image_url/1 function handles this automatically
```

### 4. DO Verify Images After Upload

After uploading to S3, verify accessibility:

```bash
# Test with curl
curl -I "https://<bucket>.fly.storage.tigris.dev/uploads/media/<filename>"

# Check in browser
# Open the URL directly - should display image
```

### 5. DO Use Consistent URL Patterns

All uploaded images should follow:
```
/uploads/media/<timestamp>_<hash>.<extension>
```

Examples:
- `/uploads/media/1763542139_3020310155b8abcf.jpg`
- `/uploads/media/1763483281_a84d8a1756abb807.JPG`

### 6. DO Check Production HTML Output

After deployment, verify the generated HTML has correct URLs:

```bash
curl -s "https://oliviatew.co.uk/series" | grep -o 'src="[^"]*\.jpg[^"]*"' | head -5
```

Expected output should show subdomain-style URLs:
```
src="https://falling-sky-1523.fly.storage.tigris.dev/uploads/media/..."
```

---

## Image Upload Workflow

### Step 1: Upload to S3

```bash
# Sync local uploads to S3
aws s3 sync priv/static/uploads s3://<bucket>/uploads \
  --endpoint-url https://fly.storage.tigris.dev \
  --acl public-read
```

### Step 2: Verify Accessibility

```bash
# Test a specific image
curl -I "https://<bucket>.fly.storage.tigris.dev/uploads/media/<filename>"
```

### Step 3: Update Database Records

Ensure artworks/series have correct `image_url` values pointing to the uploaded files.

### Step 4: Deploy and Verify

```bash
fly deploy -a <app-name>

# Then check the live site
curl -s "https://your-domain.com/work" | grep -o 'src="https://[^"]*"' | head -10
```

---

## Debugging Checklist

When images don't display:

1. **Check URL format in HTML**
   ```bash
   curl -s "https://your-site.com/page" | grep 'src="'
   ```
   - If path-style URL (`fly.storage.tigris.dev/<bucket>/...`) -> Fix S3_PUBLIC_URL secret
   - If local path (`/uploads/...`) -> Add `resolve_asset_url/1` wrapper

2. **Test image URL directly**
   ```bash
   curl -I "<image-url>"
   ```
   - 403 Forbidden -> Check URL format (subdomain vs path style)
   - 404 Not Found -> File doesn't exist in S3
   - 200 OK -> URL is correct, check template rendering

3. **Check database records**
   ```sql
   SELECT id, title, image_url FROM artworks WHERE series_id = X;
   ```
   - If `image_url` is NULL -> Populate the field

4. **Verify S3_PUBLIC_URL secret**
   ```bash
   fly secrets list -a <app-name> | grep S3_PUBLIC_URL
   ```

---

## Key Files

- **URL Resolution**: `lib/olivia_web/helpers/asset_helpers.ex`
- **S3 Configuration**: `config/runtime.exs` (lines 10-23)
- **Series Cover Logic**: `lib/olivia/content/series.ex` (`resolved_cover_image_url/1`)
- **Artwork Image Logic**: `lib/olivia/content/artwork.ex` (`resolved_image_url/1`)

---

## Future Improvements

1. **Validation on upload**: Ensure images are accessible before saving URL to database
2. **Admin UI feedback**: Show actual image preview using resolved URL
3. **Migration**: Update all hardcoded URLs to use `resolve_asset_url/1`
4. **Consistency**: Decide whether to use database-driven or hardcoded approach per page and document it

---

## Summary

The critical insight: **S3-compatible storage URL format matters as much as permissions**. Use subdomain-style URLs, always wrap paths with `resolve_asset_url/1`, and ensure database records have image URLs populated before expecting them to display.
