# Incremental Deployment Strategy

## Overview

This document defines the **official methodology** for deploying new content (series, artworks, media) to production **without destroying the existing database**. This is the standard approach going forward.

**Key Principle**: Never use the destructive `deploy_to_fly.sh` script unless you explicitly want to rebuild the entire database from scratch. Instead, use incremental deployment to add content piece by piece.

---

## Why Incremental Deployment?

### Problems with Full Database Rebuild
- ❌ Destroys all production data (user accounts, enquiries, analytics)
- ❌ Requires downtime
- ❌ Risk of data loss if seed files are incomplete
- ❌ Overwrites any production-only content
- ❌ Time-consuming and disruptive

### Benefits of Incremental Deployment
- ✅ Zero downtime
- ✅ Preserves existing production data
- ✅ Granular control over what gets deployed
- ✅ Easy to rollback individual changes
- ✅ Can be automated with scripts
- ✅ Production and local can diverge safely

---

## Standard Incremental Deployment Process

This is the **canonical workflow** for deploying new content to production.

### Prerequisites

1. Content exists and works locally (`localhost:4000`)
2. Code changes are committed to git
3. Code is deployed to Fly.io (`fly deploy -a olivia-art-portfolio`)
4. You have:
   - Database records (series, artworks, media) created locally
   - Media files uploaded locally to `priv/static/uploads/media/`

### Step 1: Deploy Code

First, deploy any code changes (new LiveView pages, components, etc.):

```bash
fly deploy -a olivia-art-portfolio
```

Wait for deployment to complete and verify the app is running:

```bash
fly status -a olivia-art-portfolio
fly logs -a olivia-art-portfolio
```

### Step 2: Export Database Records

Create SQL scripts that insert/update the required database records:

```sql
-- Insert series record
INSERT INTO series (id, title, slug, summary, body_md, position, published, inserted_at, updated_at)
VALUES (4, 'Embodiment: Studies in Gesture and Form', 'embodiment', '...', '...', 4, true, NOW(), NOW())
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  summary = EXCLUDED.summary,
  body_md = EXCLUDED.body_md,
  updated_at = NOW();

-- Insert media records (without linking to files yet)
INSERT INTO media (id, filename, url, content_type, file_size, status, asset_type, inserted_at, updated_at)
VALUES
  (30, 'IN MOTION IV.jpg', '/uploads/media/1763722108_d70e2e2341d3cccd.jpg', 'image/jpeg', 557338, 'quarantine', 'artwork', NOW(), NOW()),
  (32, 'Copy of IN MOTION III.jpg', '/uploads/media/1763722109_e4982724359e6940.jpg', 'image/jpeg', 626053, 'quarantine', 'artwork', NOW(), NOW())
ON CONFLICT (id) DO UPDATE SET
  filename = EXCLUDED.filename,
  url = EXCLUDED.url,
  updated_at = NOW();

-- Insert artwork records
INSERT INTO artworks (title, slug, year, medium, description_md, position, published, series_id, inserted_at, updated_at, status, currency)
VALUES
  ('IN MOTION III', 'in-motion-iii', 2024, 'Oil on prepared ochre ground', '...', 1, true, 4, NOW(), NOW(), 'available', 'GBP'),
  ('IN MOTION IV', 'in-motion-iv', 2024, 'Oil on canvas', '...', 2, true, 4, NOW(), NOW(), 'available', 'GBP')
ON CONFLICT (slug) DO UPDATE SET
  series_id = EXCLUDED.series_id,
  position = EXCLUDED.position,
  updated_at = NOW();

-- Link artworks to media files
UPDATE artworks SET media_file_id = 32 WHERE slug = 'in-motion-iii';
UPDATE artworks SET media_file_id = 30 WHERE slug = 'in-motion-iv';

-- Verify the data
SELECT a.id, a.title, a.slug, a.media_file_id, m.filename
FROM artworks a
LEFT JOIN media m ON a.media_file_id = m.id
WHERE a.series_id = 4
ORDER BY a.position;
```

**Save this to a file**, e.g., `/tmp/insert_embodiment.sql`

**Key Points**:
- Use `ON CONFLICT` clauses for idempotency (safe to run multiple times)
- Use `NOW()` for timestamps
- Include verification queries at the end
- Link artworks to media files AFTER both are created

### Step 3: Execute SQL on Production

Connect to the production database and execute the SQL:

```bash
fly postgres connect -a olivia-art-portfolio-db -d olivia_art_portfolio < /tmp/insert_embodiment.sql
```

**Watch for**:
- `INSERT 0 X` messages (success)
- `UPDATE X` messages (records updated)
- Verification query results showing linked records

**Common Errors**:
- Foreign key constraint violations (media_file_id doesn't exist yet)
- Unique constraint violations (slug/ID already exists with different data)

### Step 4: Upload Media Files to S3

Create a script to upload media files from local to production S3:

```bash
#!/bin/bash
# upload_media.sh

set -e

echo "Uploading media files to production S3..."

# Get S3 credentials from Fly production environment
AWS_ACCESS_KEY_ID=$(fly ssh console -a olivia-art-portfolio -C "printenv AWS_ACCESS_KEY_ID")
AWS_SECRET_ACCESS_KEY=$(fly ssh console -a olivia-art-portfolio -C "printenv AWS_SECRET_ACCESS_KEY")
AWS_ENDPOINT_URL=$(fly ssh console -a olivia-art-portfolio -C "printenv AWS_ENDPOINT_URL_S3")
BUCKET=$(fly ssh console -a olivia-art-portfolio -C "printenv S3_BUCKET")

# Export for aws CLI
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_ENDPOINT_URL_S3=$AWS_ENDPOINT_URL
export AWS_REGION=auto

# Upload files (customize paths as needed)
FILES=(
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

echo "✓ All media files uploaded successfully!"
```

**Make executable and run**:
```bash
chmod +x /tmp/upload_media.sh
/tmp/upload_media.sh
```

**What this does**:
1. Retrieves AWS credentials from production Fly app environment
2. Configures AWS CLI to use Tigris endpoint
3. Uploads each local file to the corresponding S3 path
4. Files are now accessible at production URLs

### Step 5: Verify Production

Visit the production URL and verify everything works:

```bash
# Check page loads
curl -I https://oliviatew.co.uk/series/embodiment

# Should return: HTTP/2 200
```

**Manual verification**:
1. Open `https://oliviatew.co.uk/series/embodiment` in browser
2. Verify all images load correctly
3. Check that text and metadata displays properly
4. Test any interactive features (annotations, etc.)

---

## Example: Embodiment Series Deployment

Here's the actual deployment we did for the Embodiment series as a reference:

### What We Deployed
- 1 Series: "Embodiment: Studies in Gesture and Form"
- 4 Artworks: IN MOTION III, IN MOTION IV, IN MOTION V, She Lays Down
- 4 Media files: High-resolution JPG images

### Step-by-Step

**1. Code was already deployed** (`lib/olivia_web/live/series_live/show.ex` with hardcoded Embodiment rendering)

**2. Created SQL script** (`/tmp/insert_embodiment_media.sql`):
```sql
-- Created series record (ID: 4)
-- Created 4 media records (IDs: 8, 29, 30, 32)
-- Created 4 artwork records linked to series
-- Linked artworks to media files
```

**3. Executed SQL**:
```bash
fly postgres connect -a olivia-art-portfolio-db -d olivia_art_portfolio < /tmp/insert_embodiment_media.sql
```

**Result**:
```
INSERT 0 1   (series)
INSERT 0 4   (media)
INSERT 0 4   (artworks)
UPDATE 4     (artwork-media links)
```

**4. Created and ran upload script** (`/tmp/upload_embodiment_images.sh`):
```bash
chmod +x /tmp/upload_embodiment_images.sh
/tmp/upload_embodiment_images.sh
```

**Result**:
```
✓ 1763722108_d70e2e2341d3cccd.jpg uploaded (544 KB)
✓ 1763722109_e4982724359e6940.jpg uploaded (611 KB)
✓ 1763483281_a84d8a1756abb807.JPG uploaded (4.6 MB)
✓ 1763722108_e75261efc20f18a5.jpg uploaded (530 KB)
```

**5. Verified**: https://oliviatew.co.uk/series/embodiment loaded successfully with all 4 images

**Total time**: ~10 minutes (including SQL script creation and S3 upload)

---

## Tools and Scripts

### Reusable Upload Script Template

Save this as `scripts/upload_media_to_production.sh`:

```bash
#!/bin/bash
# Generic media upload script for incremental deployments

set -e

if [ $# -eq 0 ]; then
  echo "Usage: $0 <file1> <file2> ..."
  echo "Example: $0 priv/static/uploads/media/image1.jpg priv/static/uploads/media/image2.jpg"
  exit 1
fi

echo "================================================"
echo "Uploading Media Files to Production S3"
echo "================================================"
echo ""

# Get credentials
echo "Step 1: Getting S3 credentials from Fly..."
AWS_ACCESS_KEY_ID=$(fly ssh console -a olivia-art-portfolio -C "printenv AWS_ACCESS_KEY_ID")
AWS_SECRET_ACCESS_KEY=$(fly ssh console -a olivia-art-portfolio -C "printenv AWS_SECRET_ACCESS_KEY")
AWS_ENDPOINT_URL=$(fly ssh console -a olivia-art-portfolio -C "printenv AWS_ENDPOINT_URL_S3")
BUCKET=$(fly ssh console -a olivia-art-portfolio -C "printenv S3_BUCKET")

echo "✓ Credentials retrieved"
echo "  Bucket: $BUCKET"
echo ""

export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_ENDPOINT_URL_S3=$AWS_ENDPOINT_URL
export AWS_REGION=auto

# Upload each file
echo "Step 2: Uploading files..."
for file_path in "$@"; do
  if [ ! -f "$file_path" ]; then
    echo "  ✗ File not found: $file_path"
    continue
  fi

  # Extract the path after priv/static/
  s3_key=$(echo "$file_path" | sed 's|priv/static/||')
  filename=$(basename "$file_path")

  echo "  Uploading $filename..."
  aws s3 cp "$file_path" "s3://$BUCKET/$s3_key"
  echo "  ✓ $filename uploaded"
done

echo ""
echo "================================================"
echo "✓ Upload complete!"
echo "================================================"
```

**Usage**:
```bash
./scripts/upload_media_to_production.sh \
  priv/static/uploads/media/image1.jpg \
  priv/static/uploads/media/image2.jpg
```

### SQL Script Generator Helper

You can use `mcp__Tidewave__execute_sql_query` to extract data from local DB:

```elixir
# Get series data for SQL generation
query = """
SELECT id, title, slug, summary, body_md, position, published
FROM series
WHERE slug = 'embodiment'
"""

# Get artwork data
query = """
SELECT id, title, slug, year, medium, description_md, position,
       published, series_id, status, currency, media_file_id
FROM artworks
WHERE series_id = 4
ORDER BY position
"""

# Get media data
query = """
SELECT id, filename, url, content_type, file_size, status, asset_type
FROM media
WHERE id IN (8, 29, 30, 32)
ORDER BY id
```

Use the results to generate INSERT statements.

---

## DOs and DON'Ts

### ✅ DO

- **DO** use `ON CONFLICT` clauses for idempotent SQL
- **DO** test SQL scripts on local database first
- **DO** verify data with SELECT queries after INSERT/UPDATE
- **DO** deploy code before deploying data
- **DO** keep media file names consistent between local and production
- **DO** use the upload script template for media files
- **DO** check Fly logs after deployment (`fly logs -a olivia-art-portfolio`)
- **DO** commit SQL scripts to git for version history (`/tmp/*.sql` → `scripts/migrations/`)
- **DO** use incremental deployment as the default approach

### ❌ DON'T

- **DON'T** use `scripts/deploy_to_fly.sh` unless you want to rebuild everything
- **DON'T** manually upload files via Tigris web console (use scripts for repeatability)
- **DON'T** forget to link artworks to media_file_id after creating both
- **DON'T** hardcode AWS credentials in scripts (always fetch from Fly environment)
- **DON'T** run SQL without ON CONFLICT clauses (makes re-runs fail)
- **DON'T** upload huge files without checking S3 free tier limits (5GB total)
- **DON'T** forget to verify production after deployment
- **DON'T** assume production database matches local (they can diverge)

---

## Troubleshooting

### Issue: Foreign Key Constraint Violation

**Error**: `insert or update on table "artworks" violates foreign key constraint "artworks_media_file_id_fkey"`

**Cause**: Trying to insert artwork with `media_file_id` that doesn't exist yet

**Solution**:
1. Insert media records first
2. Then insert artworks with `media_file_id = NULL`
3. Finally, UPDATE artworks to set `media_file_id`

**Or**: Remove `media_file_id` from initial INSERT and add it in a separate UPDATE.

### Issue: Images Don't Load on Production

**Error**: Broken image icons on production page

**Cause**: Media files not uploaded to S3, or wrong paths

**Solution**:
1. Check database has correct media records:
   ```sql
   SELECT id, filename, url FROM media WHERE id IN (8, 29, 30, 32);
   ```
2. Verify files exist in S3:
   ```bash
   export AWS_ACCESS_KEY_ID=$(fly ssh console -a olivia-art-portfolio -C "printenv AWS_ACCESS_KEY_ID")
   export AWS_SECRET_ACCESS_KEY=$(fly ssh console -a olivia-art-portfolio -C "printenv AWS_SECRET_ACCESS_KEY")
   export AWS_ENDPOINT_URL_S3=$(fly ssh console -a olivia-art-portfolio -C "printenv AWS_ENDPOINT_URL_S3")
   BUCKET=$(fly ssh console -a olivia-art-portfolio -C "printenv S3_BUCKET")

   aws s3 ls "s3://$BUCKET/uploads/media/"
   ```
3. Re-run upload script if files are missing

### Issue: SQL Script Fails Midway

**Error**: Script stops after first error

**Cause**: `set -e` in bash, or SQL transaction rollback

**Solution**:
1. Check which records were created:
   ```sql
   SELECT * FROM series WHERE slug = 'embodiment';
   SELECT * FROM artworks WHERE series_id = 4;
   ```
2. Fix the SQL error (likely constraint violation)
3. Re-run the script (ON CONFLICT makes it safe)

### Issue: AWS CLI Can't Find Credentials

**Error**: `fatal error: Unable to locate credentials`

**Cause**: AWS environment variables not exported

**Solution**:
Make sure you're exporting the credentials in the same shell session:
```bash
export AWS_ACCESS_KEY_ID=$(fly ssh console ...)
export AWS_SECRET_ACCESS_KEY=$(fly ssh console ...)
export AWS_ENDPOINT_URL_S3=$(fly ssh console ...)
```

---

## When to Use Full Database Rebuild vs. Incremental

### Use Incremental Deployment When:
- ✅ Adding new series, artworks, or media
- ✅ Updating existing content
- ✅ Production has data you want to preserve (user accounts, enquiries)
- ✅ Making small, targeted changes
- ✅ Production is live and serving traffic

### Use Full Rebuild When:
- ⚠️ Setting up production for the first time
- ⚠️ Database schema has changed significantly (new tables, major restructuring)
- ⚠️ You want production to exactly match local seed data
- ⚠️ Production database is corrupted or inconsistent
- ⚠️ You've explicitly decided to wipe and start fresh

**Default choice**: Incremental deployment ✅

---

## Future Improvements

Consider automating this workflow:

1. **Script to generate SQL from local database**
   ```bash
   ./scripts/export_series_sql.sh embodiment > /tmp/embodiment.sql
   ```

2. **Combined deploy script**
   ```bash
   ./scripts/incremental_deploy.sh embodiment
   ```
   Would:
   - Generate SQL from local DB
   - Execute SQL on production
   - Upload media files to S3
   - Verify deployment

3. **GitHub Actions workflow**
   - Trigger on push to `main`
   - Run incremental deployment automatically
   - Report results in PR comments

---

## Summary

**This is the standard deployment workflow going forward:**

1. Develop locally, verify everything works
2. Commit and deploy code changes (`fly deploy`)
3. Create SQL scripts for database records
4. Execute SQL on production database
5. Upload media files to S3 using script
6. Verify production works correctly

**Advantages**:
- Safe (preserves existing data)
- Fast (only deploy what changed)
- Repeatable (scripts can be re-run)
- Auditable (SQL scripts in version control)

**Never use the destructive rebuild script unless explicitly required.**
