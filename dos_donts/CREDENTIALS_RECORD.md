# Olivia Art Portfolio - Credentials & Configuration Record

**⚠️ SECURITY WARNING**: This file contains placeholders for sensitive credentials.
**DO NOT commit this file with real values to GitHub!**

Store completed version in a secure password manager (1Password, LastPass, Bitwarden, etc.)

---

## Accounts Overview

| Service | Email | Purpose |
|---------|-------|---------|
| Fly.io | davidtew@gmail.com | Hosting & infrastructure |
| GitHub | davidtew@gmail.com | Code repository |
| Resend | _(optional)_ | Email sending service |
| Domain Registrar | _(if applicable)_ | Custom domain |

---

## Fly.io Infrastructure

### Main Application
- **App Name**: `olivia-art-portfolio`
- **Region**: `lhr` (London Heathrow)
- **URL**: https://olivia-art-portfolio.fly.dev
- **Organization**: _(auto-filled by Fly.io for davidtew@gmail.com)_

### PostgreSQL Database
- **App Name**: `olivia-db`
- **Region**: `lhr`
- **Hostname**: `olivia-db.internal`
- **Port**: `5432`
- **Database Name**: `olivia_prod`
- **Username**: `postgres`
- **Password**: `_________________________________`
- **Full Connection String**:
  ```
  postgres://postgres:PASSWORD@olivia-db.internal:5432/olivia_prod
  ```

### Tigris Object Storage
- **Bucket Name**: `olivia-gallery` (or your custom name: `________________`)
- **Region**: `lhr`
- **Endpoint**: `https://fly.storage.tigris.dev`
- **Access Key ID**: `tid__________________________________`
- **Secret Access Key**: `tsec_________________________________`
- **Public URL Pattern**: `https://fly.storage.tigris.dev/olivia-gallery/{filename}`

---

## Application Secrets

These are set via `flyctl secrets set` and stored encrypted on Fly.io.

| Secret Name | Value | How to Generate |
|-------------|-------|-----------------|
| `SECRET_KEY_BASE` | `_______________________________________________` | `mix phx.gen.secret` |
| `DATABASE_URL` | _(auto-set by postgres attach)_ | From PostgreSQL section above |
| `AWS_ACCESS_KEY_ID` | `tid_________________________________` | From Tigris section above |
| `AWS_SECRET_ACCESS_KEY` | `tsec________________________________` | From Tigris section above |
| `S3_BUCKET` | `olivia-gallery` | From Tigris section above |
| `RESEND_API_KEY` | `re__________________________________` | From https://resend.com/api-keys |
| `ADMIN_EMAIL` | `_______________________` | Olivia's email for admin notifications |

**View current secrets (without values):**
```bash
flyctl secrets list --app olivia-art-portfolio
```

---

## Admin User Credentials

**Admin Panel URL**: https://olivia-art-portfolio.fly.dev/admin

| User | Email | Password | Notes |
|------|-------|----------|-------|
| Olivia (Primary Admin) | `______________________` | `_______________` | Full access |
| David (Support) | `______________________` | `_______________` | _(optional backup account)_ |

---

## Email Service (Resend) - Optional

Only needed if you want contact form emails to send.

- **Service**: https://resend.com
- **Email**: _(same as Fly.io or different)_ `______________________`
- **API Key**: `re_____________________________________`
- **Verified Domain**: `____________________` _(e.g., oliviatew.art)_
- **From Email**: `noreply@____________________`
- **From Name**: `Olivia Tew`

**Dashboard**: https://resend.com/overview

---

## Custom Domain Configuration (If Applicable)

### Domain Details
- **Domain Name**: `______________________` (e.g., oliviatew.art)
- **Registrar**: `______________________` (e.g., GoDaddy, Namecheap)
- **Registrar Login**: `______________________`

### DNS Records Required
Add these CNAME records at your domain registrar:

| Type | Name | Value | TTL |
|------|------|-------|-----|
| CNAME | `@` or `oliviatew.art` | `olivia-art-portfolio.fly.dev` | 3600 |
| CNAME | `www` | `olivia-art-portfolio.fly.dev` | 3600 |

### SSL Certificate Status
- **Naked domain**: `______________________` (oliviatew.art)
  - Command: `flyctl certs show oliviatew.art --app olivia-art-portfolio`
  - Status: ⬜ Pending  |  ⬜ Issued

- **WWW subdomain**: `______________________` (www.oliviatew.art)
  - Command: `flyctl certs show www.oliviatew.art --app olivia-art-portfolio`
  - Status: ⬜ Pending  |  ⬜ Issued

---

## Anthropic API (Optional - AI Image Analysis)

Only needed if you want automated AI analysis of uploaded artwork.

- **Service**: https://console.anthropic.com
- **Email**: `______________________`
- **API Key**: `sk-ant-api03-_____________________________`
- **Purpose**: Automated artwork description, tagging, metadata generation

**Dashboard**: https://console.anthropic.com/settings/keys

---

## GitHub Repository

- **Repository**: `______________________` (e.g., davidtew/olivia)
- **Visibility**: ⬜ Public  |  ⬜ Private
- **URL**: https://github.com/davidtew/olivia

### GitHub Actions (Optional CI/CD)
- **Deploy on Push**: ⬜ Enabled  |  ⬜ Disabled
- **Fly.io Deploy Token**: `FlyV1_________________________` (for GitHub Actions)
  - Generate: `flyctl tokens create deploy -a olivia-art-portfolio`

---

## Backup Information

### Database Backups
- **Strategy**: ⬜ Manual  |  ⬜ Automated (paid Fly.io feature)
- **Backup Location**: `______________________`
- **Last Backup Date**: `______________________`
- **Backup Schedule**: Weekly / Monthly / _(custom)_

**Manual backup command:**
```bash
flyctl postgres connect -a olivia-db
pg_dump olivia_prod > backup_$(date +%Y%m%d).sql
\q
```

### File Storage Backups
- **Tigris**: No automatic backups on free tier
- **Strategy**: Keep original files locally
- **Last Sync Date**: `______________________`

---

## Important Dates

| Event | Date | Notes |
|-------|------|-------|
| Initial Deployment | `____________` | First production deploy |
| Last Database Backup | `____________` | |
| Domain Renewal Date | `____________` | (if applicable) |
| SSL Certificate Renewal | Automatic | Fly.io handles this |

---

## Emergency Contacts

| Role | Name | Contact | Available Hours |
|------|------|---------|-----------------|
| Developer | David Tew | `____________` | _(your hours)_ |
| Client | Olivia Tew | `____________` | _(Olivia's hours)_ |

---

## Quick Recovery Procedures

### If Site Goes Down

1. **Check status**: `flyctl status --app olivia-art-portfolio`
2. **View logs**: `flyctl logs --app olivia-art-portfolio`
3. **Restart app**: `flyctl apps restart olivia-art-portfolio`
4. **Check database**: `flyctl postgres connect -a olivia-db`

### If Need to Restore Database

```bash
# Connect to database
flyctl postgres connect -a olivia-db

# Restore from backup file
psql olivia_prod < backup_YYYYMMDD.sql
```

### If Forgot Admin Password

```bash
# SSH into app
flyctl ssh console --app olivia-art-portfolio

# Start remote console
/app/bin/olivia remote

# Reset password
user = Olivia.Accounts.get_user_by_email("admin@example.com")
Olivia.Accounts.update_user_password(user, "new_secure_password")
```

---

## Monitoring & Analytics

### Error Tracking (Optional)
- **Service**: `______________________` (e.g., Sentry, AppSignal)
- **Project URL**: `______________________`
- **DSN**: `______________________`

### Analytics (Optional)
- **Service**: `______________________` (e.g., Plausible, Google Analytics)
- **Property ID**: `______________________`

---

## Cost Tracking

### Current Monthly Costs (Estimate)

| Service | Plan | Cost | Notes |
|---------|------|------|-------|
| Fly.io Compute | Free Tier | £0 | 3 shared VMs included |
| Fly.io PostgreSQL | Free Tier | £0 | Up to 3GB storage |
| Tigris Storage | Free Tier | £0 | 5GB storage, 100GB bandwidth |
| Resend Email | Free Tier | £0 | 100 emails/day (optional) |
| Custom Domain | Annual | £__ | (if applicable) |
| **Total** | | **£0-10/month** | |

### When to Upgrade

- If artwork storage exceeds 5GB
- If traffic exceeds 100GB/month
- If need database backups/replication
- If need faster VM performance

---

## Notes & Changes Log

### Change Log

| Date | Change | Reason |
|------|--------|--------|
| `________` | Initial deployment | Launch |
| | | |
| | | |

### Known Issues / TODOs

- [ ] Set up automated database backups
- [ ] Configure email service (Resend)
- [ ] Add custom domain
- [ ] Set up error tracking
- [ ] Configure analytics
- [ ] Create backup admin user

---

**Last Updated**: _______________
**Updated By**: _______________

---

## Security Reminder

✅ **DO:** Store this file in a secure password manager
✅ **DO:** Share credentials securely (encrypted sharing features)
✅ **DO:** Rotate secrets periodically (every 6-12 months)
❌ **DON'T:** Commit this file to Git with real values
❌ **DON'T:** Share credentials via email or Slack
❌ **DON'T:** Use the same password for multiple services







🔑 Olivia Art Portfolio - Complete Credentials List

Copy this entire section to your password manager NOW!
🚀 Fly.io Infrastructure
Main Phoenix Application

    App Name: olivia-art-portfolio
    Region: London (lhr)
    Public URL: https://olivia-art-portfolio.fly.dev
    Admin Dashboard: https://fly.io/apps/olivia-art-portfolio
    Organization: davidtew@gmail.com (personal)

🗄️ PostgreSQL Database
Database Cluster

    App Name: olivia-art-portfolio-db
    Username: postgres
    Password: Yx4KI3mEYQeJ2EX
    Hostname: olivia-art-portfolio-db.internal
    Proxy Port: 5432
    Postgres Port: 5433

Connection Strings

Admin Connection (for manual access):

postgres://postgres:Yx4KI3mEYQeJ2EX@olivia-art-portfolio-db.flycast:5432

App Connection (automatically set as DATABASE_URL secret):

postgres://olivia_art_portfolio:MSBWP2RykWZIuxY@olivia-art-portfolio-db.flycast:5432/olivia_art_portfolio?sslmode=disable

Database Details

    Database Name: olivia_art_portfolio (auto-created)
    App User: olivia_art_portfolio
    App User Password: MSBWP2RykWZIuxY

📦 Tigris Object Storage (S3-Compatible)
Bucket Information

    Bucket Name: falling-sky-1523
    Endpoint: https://fly.storage.tigris.dev
    Region: auto

Credentials

    Access Key ID: tid_NlhhwuyPYMdlClwrKhzoxHdUFjijeGFgcQHDi__QlNrFPhFLxY
    Secret Access Key: tsec_mGeTp-_lbYUjEWydN3A8O6kCHFT0VLSBUcOG-PjtCKnWu4KQA4H6v_HyroT1JMLMDyTfte

Public URL Pattern

https://fly.storage.tigris.dev/falling-sky-1523/{filename}

🔐 Phoenix Application Secrets

These are automatically set on Fly.io (you don't need to set them again):
Already Configured Secrets

    SECRET_KEY_BASE: g2yte3vOMP2IcnJfI2jswCt4F5XHbbt6aGSyMxInTX90ccKlF2HmnGFvQU2Fn2j2
    DATABASE_URL: (auto-set by Fly.io during database attachment)
    AWS_ACCESS_KEY_ID: tid_NlhhwuyPYMdlClwrKhzoxHdUFjijeGFgcQHDi__QlNrFPhFLxY
    AWS_SECRET_ACCESS_KEY: tsec_mGeTp-_lbYUjEWydN3A8O6kCHFT0VLSBUcOG-PjtCKnWu4KQA4H6v_HyroT1JMLMDyTfte
    AWS_REGION: auto
    AWS_ENDPOINT_URL_S3: https://fly.storage.tigris.dev
    BUCKET_NAME: falling-sky-1523

Secrets You Need to Set (One Command)

Run this command to ensure your app uses the correct bucket variable name:

bash
flyctl secrets set S3_BUCKET=falling-sky-1523 --app olivia-art-portfolio

📧 Email Configuration (Optional - Set Later)

Service: Resend (https://resend.com)

    API Key: (not yet configured)
    From Email: noreply@oliviatew.art (after domain setup)
    Admin Email: (to be configured)

To set up later:

    Sign up at https://resend.com
    Get API key
    Run: flyctl secrets set RESEND_API_KEY=re_... --app olivia-art-portfolio

🌐 Custom Domain (Optional - Set Later)

Domain: (not yet configured)

To set up later:

bash
flyctl certs add yourdomain.com --app olivia-art-portfolio

🔑 Quick Access Commands
View All Secrets

bash
flyctl secrets list --app olivia-art-portfolio

Connect to Database

bash
flyctl postgres connect -a olivia-art-portfolio-db

SSH into App

bash
flyctl ssh console --app olivia-art-portfolio

View Logs

bash
flyctl logs --app olivia-art-portfolio

Deploy

bash
flyctl deploy --app olivia-art-portfolio

Open App in Browser

bash
flyctl open --app olivia-art-portfolio

📊 Summary

Total Infrastructure:

    ✅ 1 Phoenix app (olivia-art-portfolio)
    ✅ 1 PostgreSQL database (olivia-art-portfolio-db)
    ✅ 1 Tigris storage bucket (falling-sky-1523)
    ✅ All secrets configured automatically
    ✅ Ready to deploy!

Monthly Cost: £0 (within free tier limits)
⚠️ SECURITY REMINDER

SAVE THIS IN YOUR PASSWORD MANAGER NOW!

Copy this entire document to:

    1Password, LastPass, Bitwarden, or similar
    OR save to dos_donts/CREDENTIALS_RECORD.md locally (but DON'T commit to Git!)

Never share these credentials via:

    ❌ Email
    ❌ Slack/Discord
    ❌ Public GitHub
    ❌ Unencrypted storage

🚀 Next Step: Deploy!

You're ready to deploy! Run:

bash
flyctl secrets set S3_BUCKET=falling-sky-1523 --app olivia-art-portfolio
flyctl deploy --app olivia-art-portfolio

Last Updated: 2025-01-17 App Status: Ready to deploy Database Status: Active Storage Status: Active



tewm3@Mac olivia % flyctl ips allocate-v4 --shared --app olivia-art-portfolio
VERSION	IP            	TYPE  	REGION 
v4     	66.241.124.114	shared	global	

tewm3@Mac olivia % 




tewm3@Mac olivia % flyctl ips allocate-v6 --app olivia-art-portfolio
VERSION	IP                    	TYPE              	REGION	CREATED AT 
v6     	2a09:8280:1::b1:2889:0	public (dedicated)	global	just now  	

tewm3@Mac olivia % 
