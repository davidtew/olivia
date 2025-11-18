# Olivia Deployment Checklist - Step-by-Step

Use this checklist to track your deployment progress. Check off each item as you complete it.

---

## Pre-Deployment Setup

### System Requirements
- [ ] Git installed (`git --version`)
- [ ] Elixir 1.15+ installed (`elixir --version`)
- [ ] Docker Desktop installed and running
- [ ] Internet connection available
- [ ] Terminal/command line access

### Install Fly.io CLI
- [ ] Install flyctl: `brew install flyctl`
- [ ] Verify installation: `flyctl version`
- [ ] Create/login to Fly.io account: `flyctl auth signup` OR `flyctl auth login`
- [ ] Verify auth: `flyctl auth whoami` (should show davidtew@gmail.com)

---

## Database Setup

### Create PostgreSQL Cluster
- [ ] Run: `flyctl postgres create`
- [ ] Choose app name: `olivia-db`
- [ ] Select region: `lhr` (London)
- [ ] Select "Development" tier (free)
- [ ] **SAVE PASSWORD** from output: `___________________________`
- [ ] **SAVE CONNECTION STRING**: `postgres://postgres:PASSWORD@olivia-db.internal:5432`

### Create Database
- [ ] Connect: `flyctl postgres connect -a olivia-db`
- [ ] Run: `CREATE DATABASE olivia_prod;`
- [ ] Exit: `\q`
- [ ] **RECORD DATABASE_URL**: `postgres://postgres:PASSWORD@olivia-db.internal:5432/olivia_prod`

---

## Tigris Storage Setup

### Create Storage Bucket
- [ ] Run: `flyctl storage create`
- [ ] Choose bucket name: `olivia-gallery` (or `olivia-gallery-davidtew` if taken)
- [ ] Select region: `lhr`
- [ ] **SAVE Access Key ID**: `tid_____________________________`
- [ ] **SAVE Secret Access Key**: `tsec____________________________`
- [ ] **SAVE Endpoint**: `https://fly.storage.tigris.dev`

---

## Application Configuration

### Generate Secrets
- [ ] Generate secret: `mix phx.gen.secret`
- [ ] **SAVE SECRET_KEY_BASE**: `___________________________________________`

### Create Fly App
- [ ] Navigate to project: `cd /Users/tewm3/olivia`
- [ ] Run: `flyctl launch --no-deploy`
- [ ] Choose app name: `olivia-art-portfolio`
- [ ] Select region: `lhr`
- [ ] Skip PostgreSQL setup (we created manually): **NO**
- [ ] Skip Redis: **NO**
- [ ] Deploy now?: **NO**

### Attach Database
- [ ] Run: `flyctl postgres attach olivia-db --app olivia-art-portfolio`
- [ ] Verify DATABASE_URL is set automatically

### Set Secrets
- [ ] Set SECRET_KEY_BASE:
  ```bash
  flyctl secrets set SECRET_KEY_BASE="YOUR_SECRET" --app olivia-art-portfolio
  ```

- [ ] Set Tigris credentials:
  ```bash
  flyctl secrets set AWS_ACCESS_KEY_ID="tid_..." --app olivia-art-portfolio
  flyctl secrets set AWS_SECRET_ACCESS_KEY="tsec_..." --app olivia-art-portfolio
  flyctl secrets set S3_BUCKET="olivia-gallery" --app olivia-art-portfolio
  ```

- [ ] Verify all secrets: `flyctl secrets list --app olivia-art-portfolio`

**Expected secrets:**
- DATABASE_URL ✓
- SECRET_KEY_BASE ✓
- AWS_ACCESS_KEY_ID ✓
- AWS_SECRET_ACCESS_KEY ✓
- S3_BUCKET ✓

---

## First Deployment

### Verify Configuration Files
- [ ] Check `fly.toml` exists with correct app name
- [ ] Check `Dockerfile` exists
- [ ] Check `.dockerignore` exists
- [ ] Check `rel/overlays/bin/migrate` exists and is executable
- [ ] Check `rel/overlays/bin/server` exists and is executable
- [ ] Check `lib/olivia/release.ex` exists

### Deploy
- [ ] Run: `flyctl deploy --app olivia-art-portfolio`
- [ ] Wait for build (5-10 minutes first time)
- [ ] Watch for successful deployment message
- [ ] Check status: `flyctl status --app olivia-art-portfolio`
- [ ] Should show: `Status: running`

### Verify Deployment
- [ ] View logs: `flyctl logs --app olivia-art-portfolio`
- [ ] Look for: `Running OliviaWeb.Endpoint with Bandit`
- [ ] Look for: No errors or crashes
- [ ] Check migrations ran successfully

---

## Post-Deployment Setup

### Access Application
- [ ] Open app: `flyctl open --app olivia-art-portfolio`
- [ ] Verify homepage loads: `https://olivia-art-portfolio.fly.dev`
- [ ] Test navigation between pages
- [ ] Test theme switcher (Original/Gallery/Cottage)

### Create Admin User
- [ ] SSH into app: `flyctl ssh console --app olivia-art-portfolio`
- [ ] Start remote console: `/app/bin/olivia remote`
- [ ] Create user:
  ```elixir
  {:ok, user} = Olivia.Accounts.register_user(%{
    email: "YOUR_EMAIL",
    password: "YOUR_SECURE_PASSWORD"
  })
  ```
- [ ] Exit console (Ctrl+C twice)
- [ ] Test login at `/admin`

### Test Critical Features
- [ ] Can log in to admin panel
- [ ] Can create/edit CMS pages
- [ ] Can upload artwork images (tests Tigris)
- [ ] Uploaded images display correctly
- [ ] Contact form works (if email configured)
- [ ] Newsletter signup works

---

## Optional: Custom Domain

### Add Domain (Skip if using .fly.dev)
- [ ] Add certificate: `flyctl certs add yourdomain.com --app olivia-art-portfolio`
- [ ] Add www certificate: `flyctl certs add www.yourdomain.com --app olivia-art-portfolio`
- [ ] Get DNS instructions: `flyctl certs show yourdomain.com --app olivia-art-portfolio`
- [ ] Add CNAME records at domain registrar
- [ ] Wait for DNS propagation (check status periodically)
- [ ] Verify certificate issued: Status should show `Issued: true`

---

## Optional: Email Setup (Resend)

### Configure Email Service
- [ ] Sign up at https://resend.com
- [ ] Verify sending domain
- [ ] Get API key
- [ ] Set secret: `flyctl secrets set RESEND_API_KEY="re_..." --app olivia-art-portfolio`
- [ ] Set admin email: `flyctl secrets set ADMIN_EMAIL="email@example.com" --app olivia-art-portfolio`
- [ ] Redeploy: `flyctl deploy --app olivia-art-portfolio`
- [ ] Test contact form submission

---

## Maintenance Tasks

### Initial Backup
- [ ] Document all credentials in secure location (password manager)
- [ ] Save DATABASE_URL
- [ ] Save Tigris credentials
- [ ] Save Resend API key (if used)
- [ ] Save admin login credentials

### Set Up Monitoring
- [ ] Set up health check notifications (optional)
- [ ] Set up error tracking (Sentry/AppSignal - optional)
- [ ] Schedule database backup reminder (weekly)

---

## Verification Complete

Once all checkboxes are ticked:

✅ **Application is live**: https://olivia-art-portfolio.fly.dev
✅ **Database is running** on Fly.io PostgreSQL
✅ **File storage is configured** with Tigris
✅ **Admin access works**
✅ **All features tested**

---

## Quick Commands Reference

**Deploy changes:**
```bash
flyctl deploy --app olivia-art-portfolio
```

**View logs:**
```bash
flyctl logs --app olivia-art-portfolio
```

**SSH into app:**
```bash
flyctl ssh console --app olivia-art-portfolio
```

**Remote console:**
```bash
flyctl ssh console --app olivia-art-portfolio -C "/app/bin/olivia remote"
```

**Database connection:**
```bash
flyctl postgres connect -a olivia-db
```

**View secrets:**
```bash
flyctl secrets list --app olivia-art-portfolio
```

---

## Troubleshooting

If deployment fails:

1. **Check logs**: `flyctl logs --app olivia-art-portfolio`
2. **Verify secrets are set**: `flyctl secrets list --app olivia-art-portfolio`
3. **Check database connection**: `flyctl postgres connect -a olivia-db`
4. **Rebuild and deploy**: `flyctl deploy --app olivia-art-portfolio`

For detailed troubleshooting, see `DEPLOYMENT_GUIDE.md`.

---

**Deployment Date**: _______________
**Deployed By**: _______________
**App URL**: https://olivia-art-portfolio.fly.dev
**Status**: ⬜ In Progress  |  ⬜ Complete  |  ⬜ Issues
