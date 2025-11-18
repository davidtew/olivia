# 🚀 Olivia Art Portfolio - Deployment Files

This directory contains all the files you need to deploy your Phoenix application to Fly.io.

---

## 📁 Deployment Files Overview

| File | Purpose | When to Use |
|------|---------|-------------|
| **DEPLOYMENT_GUIDE.md** | Complete step-by-step deployment guide | Read this FIRST - comprehensive tutorial |
| **DEPLOYMENT_CHECKLIST.md** | Interactive checklist to track progress | Use while deploying - tick off tasks |
| **CREDENTIALS_RECORD.md** | Template to record all credentials | Fill out and save in password manager |
| **.env.example** | Environment variables template | Copy to `.env` for local testing only |
| **fly.toml** | Fly.io app configuration | Auto-used during deployment |
| **Dockerfile** | Docker build instructions | Auto-used during deployment |
| **.dockerignore** | Files to exclude from Docker build | Auto-used during deployment |
| **rel/overlays/bin/migrate** | Database migration script | Runs automatically on deploy |
| **rel/overlays/bin/server** | App server startup script | Runs automatically on deploy |
| **lib/olivia/release.ex** | Release task module | Used by migration script |

---

## 🎯 Quick Start

### If This Is Your First Time Deploying:

1. **Read**: `DEPLOYMENT_GUIDE.md` (comprehensive, ~30 min read)
2. **Follow**: `DEPLOYMENT_CHECKLIST.md` (interactive, tick boxes as you go)
3. **Record**: Fill out `CREDENTIALS_RECORD.md` as you create accounts/credentials
4. **Save**: Store completed `CREDENTIALS_RECORD.md` in password manager
5. **Deploy**: Follow the guide step-by-step

### If You've Already Deployed and Need to Update:

```bash
# 1. Make your code changes
# 2. Test locally
# 3. Deploy
flyctl deploy --app olivia-art-portfolio

# 4. Verify
flyctl open --app olivia-art-portfolio
```

---

## 📚 Document Hierarchy

```
START HERE
    ↓
DEPLOYMENT_GUIDE.md ← Comprehensive tutorial with all details
    ↓
DEPLOYMENT_CHECKLIST.md ← Track your progress with checkboxes
    ↓
CREDENTIALS_RECORD.md ← Record credentials as you create them
    ↓
DEPLOYED! 🎉
```

---

## 🔑 Important Security Notes

### Files That Are SAFE to Commit to Git:
✅ `DEPLOYMENT_GUIDE.md`
✅ `DEPLOYMENT_CHECKLIST.md`
✅ `CREDENTIALS_RECORD.md` (template with placeholders)
✅ `.env.example` (template with dummy values)
✅ `fly.toml`
✅ `Dockerfile`
✅ `.dockerignore`
✅ `rel/` directory
✅ `lib/olivia/release.ex`

### Files That MUST NOT Be Committed:
❌ `.env` (contains real secrets)
❌ `CREDENTIALS_RECORD.md` (if filled with real values)
❌ Any file with real passwords, API keys, or tokens

**The `.gitignore` file has been updated to protect you from accidentally committing secrets.**

---

## 🛠️ Prerequisites Before Deploying

Make sure you have:

- [ ] **Docker Desktop** installed and running
- [ ] **Elixir** installed (1.15+)
- [ ] **Git** installed
- [ ] **Internet connection**
- [ ] **Credit card** for Fly.io account (won't be charged for free tier)
- [ ] **Email access** for davidtew@gmail.com (to verify accounts)

---

## 💰 Cost Expectations

**Free Tier Limits:**
- ✅ 3 small VMs (you'll use 1)
- ✅ 3GB PostgreSQL storage
- ✅ 5GB Tigris file storage
- ✅ 100GB bandwidth/month

**Expected Cost: £0/month** for a personal portfolio site with moderate traffic.

**You'll need to pay if:**
- Artwork uploads exceed 5GB total
- Traffic exceeds 100GB/month
- You want automated backups
- You want faster/more powerful servers

---

## ⏱️ Time Estimates

| Task | Estimated Time |
|------|----------------|
| Reading DEPLOYMENT_GUIDE.md | 20-30 minutes |
| Installing prerequisites (if needed) | 10-30 minutes |
| Creating Fly.io account | 5 minutes |
| Setting up PostgreSQL | 5 minutes |
| Setting up Tigris storage | 5 minutes |
| First deployment | 10-15 minutes |
| Testing and verification | 10 minutes |
| **Total (first time)** | **1-2 hours** |
| **Subsequent deploys** | **5 minutes** |

---

## 🆘 Getting Help

### If Something Goes Wrong:

1. **Check logs first**:
   ```bash
   flyctl logs --app olivia-art-portfolio
   ```

2. **Consult troubleshooting section** in `DEPLOYMENT_GUIDE.md`

3. **Check Fly.io community forum**: https://community.fly.io

4. **Check Phoenix deployment docs**: https://hexdocs.pm/phoenix/deployment.html

### Common Issues & Quick Fixes:

| Issue | Solution |
|-------|----------|
| Build fails | Check Docker is running |
| Database connection fails | Verify `DATABASE_URL` secret is set |
| File uploads don't work | Verify Tigris credentials in secrets |
| Can't access admin panel | Create admin user (see guide Part 9) |
| App crashes on start | Check logs for missing secrets |

---

## 🔄 Deployment Workflow

### For Development:

```bash
# Work locally with development database
mix phx.server

# Make changes
# Test locally
# Commit to git
```

### For Production Deployment:

```bash
# Ensure all changes are committed
git status

# Deploy to Fly.io
flyctl deploy --app olivia-art-portfolio

# Watch deployment
flyctl logs --app olivia-art-portfolio

# Open in browser
flyctl open --app olivia-art-portfolio

# Verify everything works
```

---

## 📝 After Successful Deployment

Once deployed, you should:

1. **Save all credentials** in password manager
2. **Test all features** (admin panel, file uploads, forms)
3. **Set up backups** (weekly database dumps recommended)
4. **Optional**: Configure custom domain
5. **Optional**: Set up email service (Resend)
6. **Optional**: Add error tracking (Sentry)

---

## 🎓 Learning Resources

- **Fly.io Documentation**: https://fly.io/docs
- **Phoenix Deployment Guide**: https://hexdocs.pm/phoenix/deployment.html
- **Tigris Documentation**: https://www.tigrisdata.com/docs/
- **Docker Documentation**: https://docs.docker.com/get-started/

---

## 🚦 Deployment Status

**App Name**: olivia-art-portfolio
**Primary Region**: lhr (London)
**URL**: https://olivia-art-portfolio.fly.dev

**Status**: ⬜ Not Yet Deployed  |  ⬜ In Progress  |  ⬜ Successfully Deployed

**Deployment Date**: _______________
**Deployed By**: _______________

---

## 📞 Support Contacts

- **Fly.io Support**: support@fly.io
- **Fly.io Community**: https://community.fly.io
- **Phoenix Forum**: https://elixirforum.com/c/phoenix-forum

---

**Next Steps**: Open `DEPLOYMENT_GUIDE.md` and start following the steps! 🚀

Good luck with your deployment! You've got this! 💪
