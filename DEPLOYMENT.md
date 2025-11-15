# Olivia Gallery - Production Deployment Guide

This guide covers deploying the Olivia artist portfolio application to production.

## Prerequisites

- Elixir 1.15+ and Erlang/OTP 26+
- PostgreSQL 14+
- Tigris S3-compatible storage (or AWS S3)
- Resend account for email sending
- Domain name with DNS access

## Environment Variables

Create a `.env` file or configure the following environment variables in your deployment platform:

### Required Variables

```bash
# Database
DATABASE_URL=postgresql://user:password@host:5432/olivia_prod

# Secret Key Base (generate with: mix phx.gen.secret)
SECRET_KEY_BASE=your_very_long_secret_key_base_here

# PHX_HOST - Your domain name
PHX_HOST=oliviagraham.com

# Tigris/S3 Storage
AWS_ACCESS_KEY_ID=your_tigris_access_key
AWS_SECRET_ACCESS_KEY=your_tigris_secret_key
AWS_REGION=auto
UPLOADS_BUCKET=olivia-gallery
UPLOADS_PUBLIC_URL=https://fly.storage.tigris.dev/olivia-gallery

# Email (Resend)
RESEND_API_KEY=re_xxxxxxxxxxxx
FROM_EMAIL=noreply@oliviagraham.com
FROM_NAME=Olivia Tew
ADMIN_EMAIL=olivia@oliviagraham.com
```

### Optional Variables

```bash
# Port (default: 4000)
PORT=4000

# Pool size for database connections
POOL_SIZE=10
```

## Deployment Steps

### 1. Prepare the Application

```bash
# Install dependencies
mix deps.get --only prod

# Compile assets
MIX_ENV=prod mix assets.deploy

# Compile application
MIX_ENV=prod mix compile
```

### 2. Database Setup

```bash
# Create database (first time only)
MIX_ENV=prod mix ecto.create

# Run migrations
MIX_ENV=prod mix ecto.migrate
```

### 3. Create Initial Admin User

```elixir
# Start an IEx session
MIX_ENV=prod iex -S mix

# Create admin user
Olivia.Accounts.register_user(%{
  email: "admin@oliviagraham.com",
  password: "secure_password_here"
})
```

### 4. Build Release

```bash
# Build production release
MIX_ENV=prod mix release

# The release will be in _build/prod/rel/olivia/
```

### 5. Run the Application

```bash
# Start the release
_build/prod/rel/olivia/bin/olivia start

# Or run in daemon mode
_build/prod/rel/olivia/bin/olivia daemon
```

## Deployment Platforms

### Fly.io (Recommended)

Fly.io is recommended for Phoenix applications with excellent Tigris integration.

#### 1. Install flyctl

```bash
curl -L https://fly.io/install.sh | sh
```

#### 2. Create fly.toml

```toml
app = "olivia-gallery"
primary_region = "lhr"  # London

[build]

[env]
  PHX_HOST = "oliviagraham.com"
  PORT = "8080"

[http_service]
  internal_port = 8080
  force_https = true
  auto_stop_machines = false
  auto_start_machines = true
  min_machines_running = 1
  processes = ["app"]

  [[http_service.checks]]
    interval = "10s"
    timeout = "2s"
    grace_period = "5s"
    method = "GET"
    path = "/"

[[vm]]
  memory = "1gb"
  cpu_kind = "shared"
  cpus = 1
```

#### 3. Set Secrets

```bash
fly secrets set SECRET_KEY_BASE=$(mix phx.gen.secret)
fly secrets set DATABASE_URL=your_postgres_url
fly secrets set AWS_ACCESS_KEY_ID=your_key
fly secrets set AWS_SECRET_ACCESS_KEY=your_secret
fly secrets set RESEND_API_KEY=your_resend_key
fly secrets set FROM_EMAIL=noreply@oliviagraham.com
fly secrets set ADMIN_EMAIL=olivia@oliviagraham.com
```

#### 4. Create Postgres Database

```bash
fly postgres create olivia-db
fly postgres attach olivia-db
```

#### 5. Create Tigris Storage

```bash
fly storage create
```

#### 6. Deploy

```bash
fly deploy
```

#### 7. Run Migrations

```bash
fly ssh console
_build/prod/rel/olivia/bin/olivia eval "Olivia.Release.migrate"
```

### Docker Deployment

#### Dockerfile

```dockerfile
FROM elixir:1.15-alpine AS build

# Install build dependencies
RUN apk add --no-cache build-base git nodejs npm

WORKDIR /app

# Install hex + rebar
RUN mix local.hex --force && mix local.rebar --force

# Set build ENV
ENV MIX_ENV=prod

# Install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mix deps.compile

# Copy application files
COPY config config
COPY lib lib
COPY priv priv
COPY assets assets

# Compile assets
RUN mix assets.deploy

# Compile application
RUN mix compile

# Build release
RUN mix release

# Start a new build stage for a smaller image
FROM alpine:3.18 AS app

RUN apk add --no-cache libstdc++ openssl ncurses-libs

WORKDIR /app

# Copy release from build stage
COPY --from=build /app/_build/prod/rel/olivia ./

# Set runtime ENV
ENV HOME=/app
ENV MIX_ENV=prod
ENV PORT=4000

# Expose port
EXPOSE 4000

# Start application
CMD ["bin/olivia", "start"]
```

#### docker-compose.yml (for local testing)

```yaml
version: '3.8'

services:
  db:
    image: postgres:14
    environment:
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: olivia_dev
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  web:
    build: .
    ports:
      - "4000:4000"
    environment:
      DATABASE_URL: postgresql://postgres:postgres@db:5432/olivia_prod
      SECRET_KEY_BASE: ${SECRET_KEY_BASE}
      PHX_HOST: localhost
    depends_on:
      - db

volumes:
  postgres_data:
```

## Post-Deployment Checklist

### 1. Verify Application

- [ ] Application is accessible at your domain
- [ ] SSL certificate is active
- [ ] Admin login works
- [ ] File uploads to Tigris work
- [ ] Email sending works (test contact form)
- [ ] Newsletter subscription works

### 2. Configure DNS

Add these DNS records:

```
A     @               your_server_ip
AAAA  @               your_server_ipv6
CNAME www             yourdomain.com
TXT   @               "v=spf1 include:resend.com ~all"
```

### 3. Set Up Monitoring

Consider setting up:
- Application monitoring (e.g., AppSignal, Sentry)
- Uptime monitoring (e.g., UptimeRobot)
- Error tracking
- Performance monitoring

### 4. Backups

Set up automated backups for:
- PostgreSQL database (daily)
- Tigris storage (if needed)
- Environment variables/secrets

### 5. Security

- [ ] Enable firewall (only ports 80, 443, 22)
- [ ] Set up fail2ban for SSH
- [ ] Keep dependencies updated
- [ ] Regular security audits with `mix audit`
- [ ] Review and rotate secrets periodically

## Maintenance

### Database Migrations

```bash
# On Fly.io
fly ssh console
_build/prod/rel/olivia/bin/olivia eval "Olivia.Release.migrate"

# Or via remote console
_build/prod/rel/olivia/bin/olivia remote
Olivia.Release.migrate()
```

### Viewing Logs

```bash
# On Fly.io
fly logs

# Docker
docker logs -f container_name

# Release logs
tail -f /var/log/olivia/*.log
```

### Updating the Application

```bash
# Pull latest code
git pull origin main

# Install dependencies
mix deps.get --only prod

# Run migrations
MIX_ENV=prod mix ecto.migrate

# Rebuild assets
MIX_ENV=prod mix assets.deploy

# Build new release
MIX_ENV=prod mix release --overwrite

# Restart application
_build/prod/rel/olivia/bin/olivia restart
```

## Performance Optimization

### 1. Database Connection Pooling

In `config/runtime.exs`, adjust pool size based on your needs:

```elixir
config :olivia, Olivia.Repo,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")
```

### 2. CDN for Static Assets

Consider using a CDN like Cloudflare or Fastly for:
- CSS/JS assets
- Images from Tigris storage

### 3. Caching

Add HTTP caching headers for static content in `router.ex`:

```elixir
plug Plug.Static,
  at: "/",
  from: :olivia,
  gzip: true,
  cache_control_for_etags: "public, max-age=86400"
```

### 4. Image Optimization

For production, consider:
- Using imgproxy or similar for on-the-fly image resizing
- Generating thumbnails at upload time
- Using WebP format with JPEG fallbacks
- Implementing lazy loading (already done!)

## Troubleshooting

### Application Won't Start

```bash
# Check logs
fly logs  # or your platform's log command

# Verify environment variables are set
fly secrets list

# Check database connectivity
fly ssh console
_build/prod/rel/olivia/bin/olivia remote
Ecto.Adapters.SQL.query(Olivia.Repo, "SELECT 1", [])
```

### Email Not Sending

- Verify RESEND_API_KEY is set correctly
- Check FROM_EMAIL domain is verified in Resend
- Review logs for error messages
- Test in development with Swoosh mailbox preview

### File Uploads Failing

- Verify Tigris credentials (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)
- Check bucket name and region
- Ensure bucket has public read permissions
- Test S3 connectivity from application

### Database Migration Issues

```bash
# Check migration status
_build/prod/rel/olivia/bin/olivia eval "Ecto.Migrator.with_repo(Olivia.Repo, fn repo -> Ecto.Migrator.run(repo, :up, all: true) end)"

# Rollback last migration
_build/prod/rel/olivia/bin/olivia eval "Ecto.Migrator.with_repo(Olivia.Repo, fn repo -> Ecto.Migrator.run(repo, :down, step: 1) end)"
```

## Support

For issues:
1. Check application logs
2. Review this deployment guide
3. Consult Phoenix deployment docs: https://hexdocs.pm/phoenix/deployment.html
4. Check Fly.io docs (if using): https://fly.io/docs/elixir/

---

Last updated: November 2025
