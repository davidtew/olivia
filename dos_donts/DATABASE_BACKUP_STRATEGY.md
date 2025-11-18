# Database Backup Strategy for Olivia Art Portfolio

**Context**: This is a personal art portfolio site using Fly.io's **free-tier unmanaged PostgreSQL**. This guide provides a pragmatic backup strategy appropriate for the site's scale and risk profile.

---

## 🎯 Risk Assessment Summary

### Your Current Database Profile
- **Size**: ~1.2 MB (very small)
- **Content**: 7 artworks, 4 media files, 5 CMS pages, 1 enquiry, 2 subscribers
- **Growth Rate**: Slow (personal portfolio, not high-traffic e-commerce)
- **Update Frequency**: Occasional (new artwork, CMS updates)
- **Traffic**: Low (personal portfolio)

### Risk Level: **LOW** ✅

**Why it's acceptable to use unmanaged PostgreSQL**:
1. Small dataset (easily recreatable in ~30 minutes if disaster strikes)
2. Low traffic (downtime won't affect many users)
3. Not business-critical yet (personal portfolio, not e-commerce)
4. Free tier is appropriate for current scale
5. Can upgrade to managed/automated backups later when needed

### When to Upgrade to Managed PostgreSQL
Consider upgrading (£15-30/month) when:
- Site becomes primary source of client enquiries/income
- Subscriber list exceeds 50 people
- Adding e-commerce/payment functionality
- Artwork collection exceeds 100 pieces
- Daily traffic exceeds 1,000 visitors
- Peace of mind is worth the cost

---

## 📋 Recommended Backup Strategy

### Tier 1: Weekly Manual Backups ⭐ **START HERE**

**Frequency**: Every Sunday at 10 AM (or your chosen time)
**Effort**: 5 minutes
**Cost**: £0

**Process**:

```bash
# 1. Connect to your database
flyctl postgres connect -a olivia-db

# 2. Create backup (from within psql)
\! pg_dump olivia_prod > /tmp/backup_$(date +%Y%m%d).sql

# 3. Exit psql
\q

# 4. Download backup to local machine (from your terminal)
flyctl ssh console -a olivia-db -C "cat /tmp/backup_$(date +%Y%m%d).sql" > ~/Backups/olivia_db_$(date +%Y%m%d).sql

# 5. Verify backup file exists and has content
ls -lh ~/Backups/olivia_db_*.sql
```

**Store backups**:
- Local: `~/Backups/` directory
- Cloud: Upload to Google Drive, Dropbox, or iCloud
- Keep last 4 weeks (4 files)
- Optional: Keep monthly snapshots for 6 months

### Tier 2: Automated Weekly Backups (Recommended)

**Frequency**: Automatic every Sunday at 2 AM
**Effort**: 30 minutes one-time setup
**Cost**: £0 (uses your Mac as backup server)

**Setup with macOS LaunchAgent**:

1. Create backup script:

```bash
#!/bin/bash
# ~/scripts/backup_olivia_db.sh

DATE=$(date +%Y%m%d)
BACKUP_DIR="$HOME/Backups/olivia"
BACKUP_FILE="$BACKUP_DIR/olivia_db_$DATE.sql"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Run backup via flyctl
flyctl ssh console -a olivia-db -C "pg_dump olivia_prod" > "$BACKUP_FILE"

# Check if backup succeeded
if [ $? -eq 0 ]; then
  echo "$(date): Backup successful - $BACKUP_FILE" >> "$BACKUP_DIR/backup.log"

  # Upload to cloud (optional - requires rclone)
  # rclone copy "$BACKUP_FILE" gdrive:Backups/olivia/
else
  echo "$(date): Backup FAILED" >> "$BACKUP_DIR/backup.log"
fi

# Delete backups older than 30 days
find "$BACKUP_DIR" -name "olivia_db_*.sql" -mtime +30 -delete

# Keep monthly snapshots
if [ $(date +%d) -eq 01 ]; then
  cp "$BACKUP_FILE" "$BACKUP_DIR/monthly/olivia_db_$(date +%Y%m).sql"
fi
```

2. Make script executable:

```bash
chmod +x ~/scripts/backup_olivia_db.sh
```

3. Create LaunchAgent plist:

```bash
# ~/Library/LaunchAgents/com.olivia.backup.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.olivia.backup</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>/Users/tewm3/scripts/backup_olivia_db.sh</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Weekday</key>
        <integer>0</integer> <!-- 0 = Sunday -->
        <key>Hour</key>
        <integer>2</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
    <key>StandardOutPath</key>
    <string>/Users/tewm3/Backups/olivia/backup_stdout.log</string>
    <key>StandardErrorPath</key>
    <string>/Users/tewm3/Backups/olivia/backup_stderr.log</string>
</dict>
</plist>
```

4. Load LaunchAgent:

```bash
launchctl load ~/Library/LaunchAgents/com.olivia.backup.plist
```

5. Verify it's loaded:

```bash
launchctl list | grep olivia
```

**Benefits**:
- ✅ Automatic backups while you sleep
- ✅ No manual intervention needed
- ✅ Free (uses your Mac)
- ✅ Keeps 30 days of history + monthly snapshots

**Limitations**:
- ❌ Only runs when your Mac is on and connected to internet
- ❌ No backup if you're traveling without your laptop

### Tier 3: Cloud-Based Automated Backups (Optional)

**Frequency**: Daily at 3 AM
**Effort**: 1 hour setup (using GitHub Actions or similar)
**Cost**: £0 (GitHub free tier)

**Setup with GitHub Actions**:

1. Create GitHub repository for backups (private repo)

2. Create workflow file `.github/workflows/backup.yml`:

```yaml
name: Daily Database Backup

on:
  schedule:
    - cron: '0 3 * * *'  # Daily at 3 AM UTC
  workflow_dispatch:  # Allow manual trigger

jobs:
  backup:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Install flyctl
        uses: superfly/flyctl-actions/setup-flyctl@master

      - name: Backup Database
        env:
          FLY_API_TOKEN: ${{ secrets.FLY_API_TOKEN }}
        run: |
          DATE=$(date +%Y%m%d)
          flyctl ssh console -a olivia-db -C "pg_dump olivia_prod" > backup_$DATE.sql

      - name: Upload Backup to Google Drive
        # Use a GitHub Action for Google Drive upload
        # Or commit backup to repo (not recommended for large files)
        run: |
          # Implementation depends on chosen storage
          echo "Backup complete"

      - name: Cleanup Old Backups
        run: |
          # Delete backups older than 30 days
          find . -name "backup_*.sql" -mtime +30 -delete
```

3. Add `FLY_API_TOKEN` to GitHub secrets:

```bash
# Generate Fly.io token
flyctl auth token

# Add to GitHub: Settings → Secrets → Actions → New repository secret
# Name: FLY_API_TOKEN
# Value: <your token>
```

**Benefits**:
- ✅ Runs daily regardless of your Mac status
- ✅ Cloud-based (survives local disasters)
- ✅ Version controlled
- ✅ Free on GitHub

---

## 🔄 Restoration Procedures

### Restore from Backup

**If you need to restore the database**:

```bash
# 1. Connect to database
flyctl postgres connect -a olivia-db

# 2. Drop existing database (⚠️ CAREFUL - this deletes everything!)
DROP DATABASE olivia_prod;

# 3. Recreate database
CREATE DATABASE olivia_prod;

# 4. Exit psql
\q

# 5. Restore from backup file
flyctl ssh console -a olivia-db

# From inside the Fly.io machine:
psql olivia_prod < /path/to/backup_YYYYMMDD.sql
```

**Alternative: Restore from local machine**:

```bash
# Upload backup to Fly.io machine
flyctl ssh console -a olivia-db

# From local machine, pipe backup:
cat ~/Backups/olivia_db_20250117.sql | flyctl ssh console -a olivia-db -C "psql olivia_prod"
```

### Test Restoration (Do This Once!)

**Verify your backups actually work**:

1. Create a test database:

```bash
flyctl postgres connect -a olivia-db
CREATE DATABASE olivia_test;
\q
```

2. Restore backup to test database:

```bash
cat ~/Backups/olivia_db_latest.sql | flyctl ssh console -a olivia-db -C "psql olivia_test"
```

3. Verify data:

```bash
flyctl postgres connect -a olivia-db
\c olivia_test
SELECT COUNT(*) FROM artworks;  -- Should show 7
SELECT COUNT(*) FROM media;     -- Should show 4
\q
```

4. Clean up:

```bash
flyctl postgres connect -a olivia-db
DROP DATABASE olivia_test;
\q
```

---

## 📊 What to Back Up

### Critical Data (MUST back up)
- ✅ **artworks** table - Artwork metadata, descriptions, pricing
- ✅ **media** table - Image metadata, AI analysis, tags
- ✅ **enquiries** table - Customer contact requests
- ✅ **subscribers** table - Newsletter email list
- ✅ **users** table - Admin login credentials
- ✅ **pages** & **page_sections** - CMS content (About, Collect, etc.)

### Less Critical (nice to have)
- ⚠️ **series** table - Can be recreated
- ⚠️ **users_tokens** table - Regenerated on login

### Not Needed in Backups
- ❌ **schema_migrations** table - Regenerated from migration files
- ❌ Media file binaries - Stored in Tigris (separate backup strategy)

---

## 💾 Tigris File Backup Strategy

**Important**: PostgreSQL backups only save metadata about images, not the actual image files. Image files are stored in Tigris.

### Tigris Backup Options

**Option 1: Keep Original Files Locally** ⭐ **RECOMMENDED**
- Keep original artwork photos on your Mac
- Consider them the "source of truth"
- Re-upload if Tigris bucket lost

**Option 2: Download from Tigris Periodically**
```bash
# Using AWS CLI (install with: brew install awscli)
aws configure --profile tigris
# Enter Tigris credentials when prompted

# Download all files
aws s3 sync s3://olivia-gallery ~/Backups/tigris/ --profile tigris --endpoint-url https://fly.storage.tigris.dev
```

**Option 3: Use rclone (more powerful)**
```bash
# Install rclone
brew install rclone

# Configure Tigris remote
rclone config

# Sync Tigris to local
rclone sync tigris:olivia-gallery ~/Backups/tigris/

# Or sync to Google Drive
rclone sync tigris:olivia-gallery gdrive:Backups/olivia/
```

---

## 📅 Backup Schedule Recommendation

### Minimal (Low Risk Tolerance)
- **Database**: Weekly manual backups (Sunday mornings)
- **Files**: Keep originals on local machine
- **Effort**: 5 min/week
- **Cost**: £0

### Recommended (Balanced)
- **Database**: Automated weekly backups (LaunchAgent)
- **Files**: Keep originals + monthly Tigris sync
- **Effort**: 30 min one-time setup + 10 min/month
- **Cost**: £0

### Comprehensive (High Risk Aversion)
- **Database**: Daily automated backups (GitHub Actions)
- **Files**: Weekly Tigris sync to cloud storage
- **Monitoring**: Email alerts on backup failures
- **Effort**: 2 hours one-time setup
- **Cost**: £0-5/month (cloud storage)

### Enterprise (When Business-Critical)
- **Database**: Fly.io managed PostgreSQL with automated backups
- **Files**: Tigris + mirror to second S3 provider
- **Monitoring**: Full observability stack
- **Effort**: Minimal (fully managed)
- **Cost**: £30-50/month

---

## ⏰ Backup Checklist

### One-Time Setup
- [ ] Create `~/Backups/olivia/` directory
- [ ] Create backup script (`~/scripts/backup_olivia_db.sh`)
- [ ] Set up LaunchAgent (optional but recommended)
- [ ] Test backup script manually
- [ ] Test restoration procedure
- [ ] Document procedure in `CREDENTIALS_RECORD.md`

### Weekly Maintenance (if manual)
- [ ] Run backup script
- [ ] Verify backup file created successfully
- [ ] Upload to cloud storage
- [ ] Delete backups older than 30 days

### Monthly Review
- [ ] Verify backups are running (check `backup.log`)
- [ ] Test restoration from latest backup
- [ ] Review disk space usage
- [ ] Update this document if process changed

---

## 🚨 Disaster Recovery Plan

### Scenario 1: Database Corruption Detected
1. **Immediate**: Stop accepting new data (set site to maintenance mode)
2. **Assess**: Determine scope of corruption
3. **Restore**: From most recent backup
4. **Verify**: Check critical tables (artworks, enquiries, subscribers)
5. **Resume**: Take site out of maintenance mode
6. **Post-mortem**: Document what happened and how to prevent

### Scenario 2: Entire Database Lost
1. **Stay calm**: You have backups (right? 😅)
2. **Restore**: From most recent backup
3. **Verify**: All critical data present
4. **Investigate**: Why did database fail?
5. **Consider**: Upgrading to managed PostgreSQL

### Scenario 3: Tigris Bucket Lost
1. **Re-create bucket**: `flyctl storage create`
2. **Re-upload files**: From local originals or backup
3. **Update URLs**: May need to update media table if URLs changed
4. **Verify**: Test image display on site

---

## 📈 Monitoring Your Backups

### Simple Monitoring (No Tools)
- Keep a Google Sheet with backup dates
- Set calendar reminder every Sunday
- Review backup logs monthly

### Automated Monitoring (Optional)
- Use macOS Notifications from backup script
- Email yourself on backup success/failure
- Use monitoring service (Healthchecks.io - free tier)

**Example: Healthchecks.io Integration**

```bash
# Add to backup script
HEALTHCHECK_URL="https://hc-ping.com/your-uuid-here"

# After successful backup
curl -fsS --retry 3 "$HEALTHCHECK_URL" > /dev/null

# If this doesn't ping within 24 hours, you get an email alert
```

---

## 💡 Pro Tips

1. **Test your backups!** - A backup you haven't tested is not a backup
2. **Automate early** - Don't rely on remembering to run manual backups
3. **Keep multiple generations** - Don't overwrite your only backup
4. **Store off-site** - Local backups won't help if your laptop is stolen/destroyed
5. **Document the process** - Future you will thank present you
6. **Start simple** - Begin with weekly manual, upgrade as needed
7. **Set calendar reminders** - Until automation is in place

---

## 📝 Backup Log Template

Keep a simple log of your backups:

```
# ~/Backups/olivia/backup_log.txt

2025-01-17: Manual backup, 7 artworks, 4 media, verified OK
2025-01-24: Automated backup, 8 artworks, 5 media, verified OK
2025-01-31: Automated backup, 8 artworks, 5 media, verified OK
2025-02-07: Automated backup, 9 artworks, 6 media, verified OK
```

---

## 🎯 Summary: Your Action Plan

**This Week**:
1. Create backup directory: `mkdir -p ~/Backups/olivia`
2. Run first manual backup (see Tier 1 above)
3. Test restoration procedure
4. Document backup location in `CREDENTIALS_RECORD.md`

**This Month**:
1. Set up automated weekly backups (Tier 2)
2. Test automated backup runs successfully
3. Set up cloud sync (Google Drive, Dropbox, etc.)

**Within 3 Months**:
1. Review backup strategy effectiveness
2. Consider upgrading to daily backups if traffic grows
3. Consider managed PostgreSQL if site becomes business-critical

---

**Remember**: The best backup strategy is one you actually implement and maintain. Start simple (weekly manual), then automate when you have time. The perfect backup system you never set up is worse than a simple system that runs reliably.

Good luck! 🍀
