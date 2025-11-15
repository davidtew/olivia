# Olivia Gallery

A modern artist portfolio and gallery management system built with Phoenix LiveView.

## Features

### Content Management
- **Series Management**: Organize artworks into thematic collections
- **Artwork Management**: Full CRUD for individual artworks with image uploads
- **Exhibitions & Projects**: Showcase past exhibitions and collaborative projects
- **Press Coverage**: Manage media appearances and publications
- **CMS Pages**: Customizable pages (About, Collect, Hotels & Designers, etc.)

### Communications
- **Newsletter System**: Manage subscribers and send newsletters with Markdown support
- **Contact Forms**: Enquiry system with email notifications via Resend
- **Subscriber Management**: Track and manage email subscribers

### Media & Storage
- **Tigris S3 Integration**: Cloud storage for artwork images
- **Image Optimization**: Lazy loading, responsive sizing, optimized delivery
- **File Upload**: Direct uploads through admin interface

### User Experience
- **Public Gallery**: Beautiful, responsive gallery views
- **Admin Dashboard**: Statistics and quick access to all management tools
- **SEO Optimized**: Meta tags, Open Graph, Twitter Cards, sitemap.xml, robots.txt
- **Mobile Responsive**: Works seamlessly on all devices
- **Accessibility**: ARIA labels, semantic HTML, keyboard navigation

## Tech Stack

- **Phoenix 1.8.1** - Web framework
- **Phoenix LiveView 1.1.0** - Real-time, reactive UI
- **PostgreSQL** - Primary database
- **Tigris/S3** - Object storage for images
- **Resend** - Transactional email delivery
- **TailwindCSS** - Styling and design system
- **Earmark** - Markdown processing

## Getting Started

### Prerequisites

- Elixir 1.15+ and Erlang/OTP 26+
- PostgreSQL 14+
- Node.js 18+ (for asset compilation)

### Installation

1. Clone the repository and install dependencies:

```bash
mix setup
```

2. Configure your environment variables in `config/dev.exs` or create a `.env` file:

```bash
# Tigris/S3 Storage
export AWS_ACCESS_KEY_ID=your_tigris_access_key
export AWS_SECRET_ACCESS_KEY=your_tigris_secret_key

# Email (Resend)
export RESEND_API_KEY=your_resend_api_key
export FROM_EMAIL=noreply@example.com
export ADMIN_EMAIL=admin@example.com
```

3. Create and migrate the database:

```bash
mix ecto.setup
```

4. Start the Phoenix server:

```bash
mix phx.server
```

Now visit [`localhost:4000`](http://localhost:4000) from your browser.

### Creating an Admin User

```elixir
# Start IEx
iex -S mix phx.server

# Create admin user
Olivia.Accounts.register_user(%{
  email: "admin@example.com",
  password: "securepassword123"
})
```

Then visit [`localhost:4000/olivia_web/users/log-in`](http://localhost:4000/olivia_web/users/log-in) to access the admin area at [`localhost:4000/admin`](http://localhost:4000/admin).

## Documentation

- **[DEPLOYMENT.md](DEPLOYMENT.md)** - Complete production deployment guide
- **[IMAGE_OPTIMIZATION.md](IMAGE_OPTIMIZATION.md)** - Image optimization best practices and tools

## Project Structure

```
lib/
├── olivia/               # Business logic
│   ├── accounts/         # User authentication
│   ├── cms/              # Content Management System
│   ├── communications/   # Newsletters, enquiries, subscribers
│   ├── content/          # Artworks, series, exhibitions
│   ├── emails/           # Email templates
│   └── uploads.ex        # S3/Tigris integration
├── olivia_web/           # Web interface
│   ├── components/       # Reusable UI components
│   ├── controllers/      # HTTP controllers (sitemap, etc.)
│   ├── live/             # LiveView modules
│   │   ├── admin/        # Admin interface
│   │   ├── artwork_live/ # Public artwork pages
│   │   ├── series_live/  # Public series pages
│   │   ├── contact_live.ex
│   │   └── home_live.ex
│   └── router.ex         # Route definitions
test/
├── olivia/               # Context tests
├── olivia_web/           # LiveView tests
└── support/              # Test helpers and fixtures
priv/
├── repo/migrations/      # Database migrations
└── static/               # Static files (robots.txt, etc.)
```

## Development

### Running Tests

```bash
mix test
```

### Code Quality

```bash
# Format code
mix format

# Run linter
mix credo

# Check for security issues
mix deps.audit
```

### Database

```bash
# Create new migration
mix ecto.gen.migration migration_name

# Run migrations
mix ecto.migrate

# Rollback
mix ecto.rollback

# Reset database
mix ecto.reset
```

## Deployment

See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed production deployment instructions.

Quick deploy to Fly.io:

```bash
fly launch
fly secrets set SECRET_KEY_BASE=$(mix phx.gen.secret)
fly deploy
```

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `DATABASE_URL` | PostgreSQL connection string | Yes |
| `SECRET_KEY_BASE` | Phoenix secret key | Yes |
| `PHX_HOST` | Domain name | Yes (prod) |
| `AWS_ACCESS_KEY_ID` | Tigris/S3 access key | Yes |
| `AWS_SECRET_ACCESS_KEY` | Tigris/S3 secret key | Yes |
| `RESEND_API_KEY` | Resend API key for emails | Yes |
| `FROM_EMAIL` | From address for emails | Yes |
| `ADMIN_EMAIL` | Admin notification email | Yes |
| `UPLOADS_BUCKET` | S3 bucket name | No (default: olivia-gallery) |
| `UPLOADS_PUBLIC_URL` | S3 public URL | No |

## Contributing

This is a personal portfolio project, but suggestions and feedback are welcome!

## License

Copyright © 2025 Olivia Tew. All rights reserved.

## Phoenix Resources

* Official website: https://www.phoenixframework.org/
* Guides: https://hexdocs.pm/phoenix/overview.html
* Docs: https://hexdocs.pm/phoenix
* Forum: https://elixirforum.com/c/phoenix-forum
* Source: https://github.com/phoenixframework/phoenix
