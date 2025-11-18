# Olivia Art Portfolio - Documentation & Guides

This directory contains comprehensive guides and documentation for developing, theming, and deploying the Olivia art portfolio Phoenix application.

---

## 📚 Documentation Index

### 🎨 Theme Development Guides
1. **[THEME_IMPLEMENTATION_GUIDE.md](THEME_IMPLEMENTATION_GUIDE.md)** - Complete guide for implementing multi-theme system
   - Three-theme architecture (Original, Gallery, Cottage)
   - The `cond` pattern for theme switching
   - Step-by-step theme implementation process
   - Markdown styling, forms, and layout customization
   - Best practices and common mistakes

2. **[COTTAGE_THEME_CONCEPT.md](COTTAGE_THEME_CONCEPT.md)** - Design specification for Cottage theme
   - Color palette and typography
   - Visual design language
   - Component styling guidelines

---

### 🚀 Deployment Guides
3. **[DEPLOYMENT_README.md](DEPLOYMENT_README.md)** - **START HERE** for deployment
   - Quick overview of all deployment files
   - Prerequisites and time estimates
   - File hierarchy and security notes
   - Quick reference for common tasks

4. **[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)** - Comprehensive step-by-step deployment tutorial
   - Complete Fly.io setup from scratch
   - PostgreSQL database creation
   - Tigris object storage configuration
   - Secrets management
   - Custom domain setup
   - Troubleshooting guide
   - ~10,000 words, covers everything in detail

5. **[DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md)** - Interactive deployment checklist
   - Tick-box format for tracking progress
   - All deployment steps organized sequentially
   - Quick commands reference
   - Verification steps

6. **[CREDENTIALS_RECORD.md](CREDENTIALS_RECORD.md)** - Template for recording credentials
   - All accounts and credentials in one place
   - Database connection strings
   - API keys and secrets
   - Emergency recovery procedures
   - **⚠️ SECURITY**: Fill out and store in password manager, DO NOT commit with real values

7. **[DATABASE_BACKUP_STRATEGY.md](DATABASE_BACKUP_STRATEGY.md)** - PostgreSQL backup & disaster recovery
   - Risk assessment for unmanaged PostgreSQL
   - Three-tier backup strategy (manual → automated → cloud)
   - Restoration procedures with examples
   - Tigris file backup options
   - Disaster recovery scenarios
   - Monitoring and maintenance schedules

---

## 🎯 How to Use These Guides

### If You're Adding a New Theme:
1. Read: **THEME_IMPLEMENTATION_GUIDE.md** (Section: "Systematic Three-Theme Implementation Process")
2. Reference: **COTTAGE_THEME_CONCEPT.md** as an example of theme design documentation
3. Follow the step-by-step methodology in the guide

### If You're Deploying for the First Time:
1. Start: **DEPLOYMENT_README.md** (5-minute overview)
2. Read: **DEPLOYMENT_GUIDE.md** (comprehensive 30-minute read)
3. Use: **DEPLOYMENT_CHECKLIST.md** (interactive, tick boxes as you deploy)
4. Record: **CREDENTIALS_RECORD.md** (fill out as you create accounts/credentials)

### If You've Already Deployed and Need to Update:
```bash
# Quick deployment
flyctl deploy --app olivia-art-portfolio

# View logs
flyctl logs --app olivia-art-portfolio
```

---

## 📂 Project Structure Context

These guides reference the following key files and directories:

```
olivia/
├── lib/
│   ├── olivia_web/
│   │   ├── components/
│   │   │   ├── layouts.ex               # Original theme navigation
│   │   │   └── layouts/
│   │   │       ├── root.html.heex       # Gallery & Cottage themes
│   │   │       └── gallery.html.heex
│   │   ├── live/
│   │   │   ├── home_live.ex             # Homepage (all themes)
│   │   │   ├── page_live.ex             # Static pages (all themes)
│   │   │   ├── contact_live.ex          # Contact form (all themes)
│   │   │   ├── series_live/
│   │   │   │   ├── index.ex             # Series listing
│   │   │   │   └── show.ex              # Series detail
│   │   │   └── artwork_live/
│   │   │       └── show.ex              # Artwork detail
│   │   ├── controllers/
│   │   │   └── theme_controller.ex      # Theme switching
│   │   └── plugs/
│   │       └── theme_plug.ex            # Theme cookie management
│   ├── olivia/
│   │   └── release.ex                   # Deployment release tasks
│   └── ...
├── config/
│   ├── runtime.exs                      # Production configuration
│   ├── prod.exs                         # Production compile-time config
│   └── dev.exs                          # Development config
├── rel/
│   └── overlays/
│       └── bin/
│           ├── migrate                  # Database migration script
│           └── server                   # Server startup script
├── dos_donts/                           # ← YOU ARE HERE
│   ├── README.md                        # This file
│   ├── THEME_IMPLEMENTATION_GUIDE.md
│   ├── COTTAGE_THEME_CONCEPT.md
│   ├── DEPLOYMENT_README.md
│   ├── DEPLOYMENT_GUIDE.md
│   ├── DEPLOYMENT_CHECKLIST.md
│   └── CREDENTIALS_RECORD.md
├── .env.example                         # Environment variables template
├── fly.toml                             # Fly.io app configuration
├── Dockerfile                           # Docker build instructions
└── .dockerignore                        # Docker build exclusions
```

---

## 🔑 Key Concepts

### Theme System Architecture
- **Three themes**: Original (Tailwind), Gallery (inline styles), Cottage (CSS variables)
- **Conditional rendering**: Uses `cond do` pattern in LiveViews
- **Root layout switching**: Different HTML structures per theme in `root.html.heex`
- **Cookie-based persistence**: Theme choice stored in browser cookie
- **State propagation flow**: Cookie → ThemePlug → Session → Socket → Assigns

### Deployment Architecture
- **Hosting**: Fly.io (London region)
- **Database**: PostgreSQL on Fly.io (free tier: 3GB)
- **File Storage**: Tigris S3-compatible (free tier: 5GB)
- **Secrets Management**: Fly.io encrypted secrets
- **Build Process**: Docker multi-stage build
- **Migrations**: Automatic on deploy via `release_command`

---

## 🛡️ Security Best Practices

### DO:
✅ Use `.env.example` as a template (safe to commit)
✅ Store real secrets in Fly.io secrets (`flyctl secrets set`)
✅ Fill out `CREDENTIALS_RECORD.md` and save in password manager
✅ Keep `.env` in `.gitignore` (already configured)
✅ Use unique `SECRET_KEY_BASE` per environment
✅ Generate secrets with `mix phx.gen.secret`

### DON'T:
❌ Commit `.env` with real values to Git
❌ Commit `CREDENTIALS_RECORD.md` with real credentials
❌ Share secrets via email or unencrypted channels
❌ Use the same password across multiple services
❌ Hard-code secrets in source code

---

## 📖 Reading Order by Use Case

### New Developer Onboarding
1. This README (5 min)
2. THEME_IMPLEMENTATION_GUIDE.md (30 min)
3. Explore codebase with guide as reference

### Preparing for Deployment
1. DEPLOYMENT_README.md (5 min)
2. DEPLOYMENT_GUIDE.md (30 min)
3. DEPLOYMENT_CHECKLIST.md (use during deployment)
4. CREDENTIALS_RECORD.md (fill out as you go)

### Adding a Fourth Theme
1. THEME_IMPLEMENTATION_GUIDE.md → "Systematic Three-Theme Implementation Process"
2. Create new theme design doc (like COTTAGE_THEME_CONCEPT.md)
3. Follow the step-by-step process in the guide

### Troubleshooting Deployment
1. DEPLOYMENT_GUIDE.md → "Troubleshooting" section
2. Check Fly.io logs: `flyctl logs`
3. Verify secrets: `flyctl secrets list`

---

## 🆘 Quick Help

### Theme Issues
**Problem**: Theme doesn't switch properly
**Solution**:
1. Check cookie is set: Browser DevTools → Application → Cookies
2. Verify ThemePlug is in router pipeline (router.ex)
3. Check ThemeHook is attached (layouts.ex)

**Problem**: New theme shows Original theme instead
**Solution**:
1. Verify `cond` pattern in LiveView render function
2. Check theme name spelling (exact match required)
3. Ensure root.html.heex has branch for new theme

### Deployment Issues
**Problem**: Build fails
**Solution**:
1. Check Docker is running
2. Verify Dockerfile syntax
3. Check logs: `flyctl logs`

**Problem**: Database connection fails
**Solution**:
1. Verify DATABASE_URL secret is set
2. Check PostgreSQL is running: `flyctl status -a olivia-db`
3. Test connection: `flyctl postgres connect -a olivia-db`

**Problem**: File uploads don't work
**Solution**:
1. Verify Tigris credentials in secrets
2. Check bucket name matches
3. Test from console: `ExAws.S3.list_buckets() |> ExAws.request()`

---

## 📊 Documentation Stats

| Guide | Word Count | Reading Time | Purpose |
|-------|------------|--------------|---------|
| THEME_IMPLEMENTATION_GUIDE.md | ~15,000 | 60 min | Theme development reference |
| COTTAGE_THEME_CONCEPT.md | ~3,000 | 10 min | Theme design specification |
| DEPLOYMENT_GUIDE.md | ~10,000 | 30 min | Step-by-step deployment tutorial |
| DEPLOYMENT_CHECKLIST.md | ~3,000 | - | Interactive deployment tracker |
| CREDENTIALS_RECORD.md | ~3,000 | - | Credentials template |
| DEPLOYMENT_README.md | ~2,000 | 5 min | Deployment overview |

**Total Documentation**: ~36,000 words

---

## 🔄 Maintenance

### When to Update These Guides

**THEME_IMPLEMENTATION_GUIDE.md**:
- When adding a fourth theme (document the process)
- When changing theme architecture
- When discovering new best practices

**DEPLOYMENT_GUIDE.md**:
- When Fly.io changes their CLI or processes
- When adding new services (email, analytics, etc.)
- When finding new troubleshooting solutions

**CREDENTIALS_RECORD.md**:
- When adding new services requiring credentials
- When changing hosting providers
- When adding new team members who need access

---

## 📞 Support Resources

- **Fly.io Docs**: https://fly.io/docs
- **Fly.io Community**: https://community.fly.io
- **Phoenix Guides**: https://hexdocs.pm/phoenix
- **Phoenix Forum**: https://elixirforum.com/c/phoenix-forum
- **Tigris Docs**: https://www.tigrisdata.com/docs/

---

## 🎓 Learning Path

### Beginner (New to Phoenix or Fly.io)
1. Read DEPLOYMENT_README.md for overview
2. Work through DEPLOYMENT_GUIDE.md step-by-step
3. Use DEPLOYMENT_CHECKLIST.md to track progress
4. Skim THEME_IMPLEMENTATION_GUIDE.md for context

### Intermediate (Familiar with Phoenix)
1. Read THEME_IMPLEMENTATION_GUIDE.md to understand architecture
2. Reference guides as needed during development
3. Use DEPLOYMENT_CHECKLIST.md for quick deployment

### Advanced (Contributing to codebase)
1. Deep-dive into THEME_IMPLEMENTATION_GUIDE.md
2. Review existing code with guide as reference
3. Update guides when adding new patterns/features

---

## 📝 Contributing to Documentation

If you improve these guides:

1. **Keep formatting consistent**: Use markdown headers, code blocks, checklists
2. **Update this README**: If adding new guides, link them in the index
3. **Test your instructions**: Ensure steps work on a fresh system
4. **Include examples**: Code snippets, terminal output, screenshots
5. **Update table of contents**: Keep navigation easy

---

## ✅ Documentation Checklist

Before deploying to production, ensure:

- [ ] DEPLOYMENT_GUIDE.md read and understood
- [ ] DEPLOYMENT_CHECKLIST.md completed (all boxes ticked)
- [ ] CREDENTIALS_RECORD.md filled out and saved securely
- [ ] All secrets set in Fly.io (`flyctl secrets list` to verify)
- [ ] .env file NOT committed to Git
- [ ] fly.toml configured with correct app name and region
- [ ] Dockerfile tested locally (optional but recommended)
- [ ] Database migrations tested
- [ ] Tigris file upload tested

---

**Last Updated**: 2025-01-17
**Maintained By**: David Tew
**For**: Olivia Tew Art Portfolio

---

**Happy building and deploying!** 🚀🎨
