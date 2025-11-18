# Olivia Art Portfolio - Complete Deployment Guide

## Overview
This guide will walk you through deploying your Phoenix app to Fly.io from scratch on a new laptop.

**Your Setup:**
- **Fly.io Account**: davidtew@gmail.com (personal, not work account)
- **GitHub Account**: davidtew@gmail.com (same as other projects)
- **Tigris Storage**: S3-compatible object storage for artwork images
- **Database**: PostgreSQL on Fly.io
- **Region**: London (lhr) - best for UK users

---

## Prerequisites Checklist

Before starting, ensure you have:

- [ ] Git installed (`git --version`)
- [ ] Elixir installed (`elixir --version` - should be ~1.15+)
- [ ] Phoenix installed (`mix phx.new --version` - should be ~1.8+)
- [ ] Docker Desktop installed and running (required for Fly.io deployments)
- [ ] This Phoenix app cloned/present on your new laptop
- [ ] Internet connection

---

## Part 1: Install and Authenticate Fly.io CLI

### Step 1.1: Install flyctl

**macOS (using Homebrew):**
```bash
brew install flyctl
```

**Alternative (using install script):**
```bash
curl -L https://fly.io/install.sh | sh
```

**Verify installation:**
```bash
flyctl version
```

You should see output like: `flyctl v0.x.xxx ...`

### Step 1.2: Create Fly.io Account

**IMPORTANT**: Use **davidtew@gmail.com** (NOT your work email)

```bash
flyctl auth signup
```

This will:
1. Open your browser
2. Ask you to sign up with davidtew@gmail.com
3. Require email verification
4. Ask for credit card (required even for free tier, but you won't be charged for small projects)

**OR** if account already exists:

```bash
flyctl auth login
```

### Step 1.3: Verify Authentication

```bash
flyctl auth whoami
```

Should show: `Email: davidtew@gmail.com`

---

## Part 2: Create Fly.io PostgreSQL Database

### Step 2.1: Create PostgreSQL Cluster

```bash
flyctl postgres create
```

**Answer the prompts:**
- **App name**: `olivia-db` (or let it auto-generate)
- **Organization**: Select your personal organization (davidtew@gmail.com)
- **Region**: `lhr` (London Heathrow - closest to UK)
- **VM resources**: Choose **"Development - Single node, 1x shared CPU, 256MB RAM, 1GB disk"**
  - This is the **FREE tier option**
  - Perfect for personal projects
  - Can upgrade later if needed

**Important Output** - Save this information:
```
Postgres cluster olivia-db created
  Username:    postgres
  Password:    SAVE_THIS_PASSWORD
  Hostname:    olivia-db.internal
  Flycast:     fdaa:x:xxx:x:x:x:x:x
  Proxy port:  5432
  Postgres port: 5433
  Connection string: postgres://postgres:PASSWORD@olivia-db.internal:5432/olivia_db?sslmode=disable
```

**COPY THE CONNECTION STRING** - you'll need it in Part 4.

### Step 2.2: Create Database

The cluster is created, but you need to create the actual database:

```bash
flyctl postgres connect -a olivia-db
```

Once connected to PostgreSQL prompt:
```sql
CREATE DATABASE olivia_prod;
\q
```

### Step 2.3: Get Full Connection String

Your `DATABASE_URL` will be:
```
postgres://postgres:YOUR_PASSWORD@olivia-db.internal:5432/olivia_prod
```

Replace `YOUR_PASSWORD` with the password from Step 2.1.

---

## Part 3: Set Up Tigris Object Storage

Tigris provides S3-compatible storage for your artwork images.

### Step 3.1: Create Tigris Bucket

```bash
flyctl storage create
```

**Answer the prompts:**
- **Bucket name**: `olivia-gallery` (must be globally unique, try `olivia-gallery-davidtew` if taken)
- **Organization**: Your personal org
- **Region**: `lhr` (London)

**Important Output** - Save this:
```
Your Tigris project (olivia-gallery) is ready!

Access Key ID: tid_XXXXXXXXXXXX
Secret Access Key: tsec_YYYYYYYYYYYYYYYYYYYY
Endpoint URL: https://fly.storage.tigris.dev
```

### Step 3.2: Record Tigris Credentials

You now have:
- **AWS_ACCESS_KEY_ID**: `tid_...` from above
- **AWS_SECRET_ACCESS_KEY**: `tsec_...` from above
- **S3_BUCKET**: `olivia-gallery` (or your custom name)
- **S3_HOST**: `fly.storage.tigris.dev`
- **AWS_REGION**: `auto`

---

## Part 4: Configure Secrets

### Step 4.1: Generate SECRET_KEY_BASE

```bash
cd /path/to/olivia
mix phx.gen.secret
```

Copy the output (64-character string).

### Step 4.2: Set Fly.io Secrets

Navigate to your app directory:
```bash
cd /Users/tewm3/olivia
```

**First, let's create the Fly.io app** (we'll set secrets after):

```bash
flyctl launch --no-deploy
```

**Answer the prompts:**
- **App name**: `olivia-art-portfolio` (or choose your own)
- **Organization**: Your personal org
- **Region**: `lhr` (London)
- **Set up PostgreSQL?**: **NO** (we already created it manually)
- **Set up Redis?**: **NO**
- **Would you like to deploy now?**: **NO**

This creates a `fly.toml` file (we already have one, it may ask to overwrite - say YES).

### Step 4.3: Attach PostgreSQL to App

```bash
flyctl postgres attach olivia-db --app olivia-art-portfolio
```

This automatically sets `DATABASE_URL` secret for you!

### Step 4.4: Set All Other Secrets

Now set the remaining secrets:

```bash
# Secret key for Phoenix
flyctl secrets set SECRET_KEY_BASE="YOUR_64_CHAR_SECRET_FROM_STEP_4_1" --app olivia-art-portfolio

# Tigris S3 credentials
flyctl secrets set AWS_ACCESS_KEY_ID="tid_YOUR_TIGRIS_KEY" --app olivia-art-portfolio
flyctl secrets set AWS_SECRET_ACCESS_KEY="tsec_YOUR_TIGRIS_SECRET" --app olivia-art-portfolio
flyctl secrets set S3_BUCKET="olivia-gallery" --app olivia-art-portfolio

# Optional: Email configuration (skip for now, add later)
# flyctl secrets set RESEND_API_KEY="re_YOUR_KEY" --app olivia-art-portfolio
# flyctl secrets set ADMIN_EMAIL="olivia@example.com" --app olivia-art-portfolio
```

**Verify secrets are set:**
```bash
flyctl secrets list --app olivia-art-portfolio
```

You should see:
- DATABASE_URL
- SECRET_KEY_BASE
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- S3_BUCKET

---

## Part 5: Deploy the Application

### Step 5.1: Verify fly.toml Configuration

Check that `/Users/tewm3/olivia/fly.toml` exists and has correct app name:

```toml
app = 'olivia-art-portfolio'  # Must match your app name
primary_region = 'lhr'
```

### Step 5.2: Deploy!

```bash
flyctl deploy --app olivia-art-portfolio
```

This will:
1. Build Docker image (takes 5-10 minutes first time)
2. Push to Fly.io
3. Run migrations via `/app/bin/migrate`
4. Start the app

**Watch the build process**. If it fails, read the error messages carefully.

### Step 5.3: Check Deployment Status

```bash
flyctl status --app olivia-art-portfolio
```

Should show status: `running`

### Step 5.4: View Logs

```bash
flyctl logs --app olivia-art-portfolio
```

Look for:
```
[info] Running OliviaWeb.Endpoint with Bandit 1.x.x at :::8080 (http)
[info] Access OliviaWeb.Endpoint at https://olivia-art-portfolio.fly.dev
```

---

## Part 6: Run Database Migrations & Seeds

### Step 6.1: Verify Migrations Ran

Migrations should have run automatically during deployment via `release_command`.

Check logs:
```bash
flyctl logs --app olivia-art-portfolio | grep migrate
```

### Step 6.2: Run Seeds (If Needed)

If you have seed data in `priv/repo/seeds.exs`:

```bash
flyctl ssh console --app olivia-art-portfolio -C "/app/bin/olivia eval 'Olivia.Release.migrate()'"
```

For more complex seeding, you can SSH in:
```bash
flyctl ssh console --app olivia-art-portfolio
/app/bin/olivia remote
```

Then run Elixir commands:
```elixir
Olivia.Repo.all(Olivia.Accounts.User)  # Check what exists
# Run your seed logic
```

---

## Part 7: Access Your Application

### Step 7.1: Open the App

```bash
flyctl open --app olivia-art-portfolio
```

This opens: `https://olivia-art-portfolio.fly.dev`

### Step 7.2: Test Critical Functions

- [ ] Homepage loads
- [ ] Can navigate to different pages
- [ ] Theme switcher works
- [ ] Can log in to `/admin` (if user exists)
- [ ] Can upload artwork image (tests Tigris integration)

---

## Part 8: Set Up Custom Domain (Optional)

### Step 8.1: Add Certificate

If you have a custom domain (e.g., `oliviatew.art`):

```bash
flyctl certs add oliviatew.art --app olivia-art-portfolio
flyctl certs add www.oliviatew.art --app olivia-art-portfolio
```

### Step 8.2: Update DNS

Fly.io will show you DNS records to add:

```
CNAME oliviatew.art -> olivia-art-portfolio.fly.dev
CNAME www.oliviatew.art -> olivia-art-portfolio.fly.dev
```

Add these at your domain registrar (GoDaddy, Namecheap, etc.).

### Step 8.3: Wait for DNS Propagation

Check status:
```bash
flyctl certs show oliviatew.art --app olivia-art-portfolio
```

Wait until it says `Issued: true`.

---

## Part 9: Create Admin User

### Step 9.1: SSH into App

```bash
flyctl ssh console --app olivia-art-portfolio
```

### Step 9.2: Start Remote Console

```bash
/app/bin/olivia remote
```

### Step 9.3: Create User

```elixir
# Create admin user
{:ok, user} = Olivia.Accounts.register_user(%{
  email: "olivia@example.com",
  password: "CHOOSE_SECURE_PASSWORD_HERE"
})

# Verify
Olivia.Accounts.get_user_by_email("olivia@example.com")
```

Exit with `Ctrl+C` twice.

---

## Part 10: Monitoring & Maintenance

### Check App Health
```bash
flyctl status --app olivia-art-portfolio
```

### View Logs
```bash
flyctl logs --app olivia-art-portfolio
```

### View Metrics
```bash
flyctl dashboard --app olivia-art-portfolio
```

### Scale if Needed

**Scale to zero when idle** (save costs):
```bash
flyctl scale count 0 --app olivia-art-portfolio
```

App will auto-start on first request (takes ~10 seconds).

**Keep always running**:
```bash
flyctl scale count 1 --app olivia-art-portfolio
```

---

## Troubleshooting

### Issue: Build Fails with "mix not found"

**Solution**: Ensure Dockerfile copies `mix.exs` and `mix.lock` before running `mix deps.get`.

### Issue: App Crashes on Start

**Check logs**:
```bash
flyctl logs --app olivia-art-portfolio
```

Common causes:
- Missing `SECRET_KEY_BASE` secret
- Database connection failure (check `DATABASE_URL`)
- Migrations didn't run

**Fix migrations**:
```bash
flyctl ssh console --app olivia-art-portfolio -C "/app/bin/migrate"
```

### Issue: File Uploads Don't Work

**Check Tigris credentials**:
```bash
flyctl secrets list --app olivia-art-portfolio
```

Ensure `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and `S3_BUCKET` are set.

**Test from remote console**:
```elixir
ExAws.S3.list_buckets() |> ExAws.request()
```

Should return `{:ok, %{body: ...}}`.

### Issue: Can't Access Admin Panel

**Create admin user** (see Part 9).

---

## Cost Breakdown (Free Tier Limits)

**Fly.io Free Tier (Hobby Plan):**
- ✅ 3 shared-cpu-1x VMs with 256MB RAM (you're using 1)
- ✅ 3GB persistent volume storage (PostgreSQL)
- ✅ 160GB outbound data transfer/month
- ✅ Tigris: 5GB storage + 100GB bandwidth/month

**Your Usage:**
- 1 VM for Phoenix app (free)
- 1 PostgreSQL instance (free tier)
- Tigris bucket (free tier)

**Estimated Monthly Cost: £0** as long as you stay within free limits.

**When You'll Need to Pay:**
- Artwork uploads exceed 5GB total
- Traffic exceeds 100GB/month
- Want faster/more powerful VMs
- Need database backups/replication

---

## Backup Strategy

### Database Backups

**Manual backup**:
```bash
flyctl postgres connect -a olivia-db
pg_dump olivia_prod > backup_$(date +%Y%m%d).sql
```

**Automated backups** (paid feature):
```bash
flyctl postgres backup schedule --app olivia-db
```

### Tigris Files

Tigris doesn't have built-in backups on free tier. Consider:
1. Keeping original files locally
2. Periodic download of all files
3. Using `rclone` to sync Tigris → another S3/backup service

---

## Next Steps

1. **Set up Email** (Resend): Get API key from https://resend.com
2. **Configure DNS**: Point custom domain to Fly.io
3. **Add Content**: Upload artwork, create CMS pages
4. **Set up CI/CD**: GitHub Actions for auto-deploy on push
5. **Monitoring**: Set up error tracking (Sentry, AppSignal)

---

## Quick Reference Commands

```bash
# Deploy changes
flyctl deploy --app olivia-art-portfolio

# View logs
flyctl logs --app olivia-art-portfolio

# SSH into app
flyctl ssh console --app olivia-art-portfolio

# Remote Elixir console
flyctl ssh console --app olivia-art-portfolio -C "/app/bin/olivia remote"

# Scale up/down
flyctl scale count 1 --app olivia-art-portfolio

# Set secret
flyctl secrets set KEY=VALUE --app olivia-art-portfolio

# View secrets
flyctl secrets list --app olivia-art-portfolio

# Database connection
flyctl postgres connect -a olivia-db

# Open app in browser
flyctl open --app olivia-art-portfolio
```

---

## Support & Documentation

- **Fly.io Docs**: https://fly.io/docs
- **Phoenix Deployment**: https://hexdocs.pm/phoenix/deployment.html
- **Tigris Docs**: https://www.tigrisdata.com/docs/
- **Fly.io Community**: https://community.fly.io

---

**You're all set!** 🚀

If you encounter any issues, check logs first, then consult the troubleshooting section above.
