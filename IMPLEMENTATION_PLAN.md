# Olivia Artist Portfolio - V1 Implementation Plan

## Overview
This document outlines the complete implementation plan for the Olivia artist portfolio site, a Phoenix LiveView application showcasing a UK-based figurative artist's work with admin capabilities for content management.

**Namespace:** All new code will be organized under appropriate Phoenix conventions:
- Business logic contexts: `lib/olivia/`
- Web layer: `lib/olivia_web/`
- Database migrations: `priv/repo/migrations/`

## Phase 1: Foundation & Authentication

### 1.1 User Authentication System
- [ ] Run `mix phx.gen.auth Accounts User users`
- [ ] Verify auth tables and modules created
- [ ] Create seed script for initial admin user
- [ ] Test login/logout flow
- [ ] Add admin protection plug for `/admin` routes

### 1.2 Database Schema Setup - Core Content
- [ ] Create `Series` schema and migration
  - Fields: id, title, slug, summary, body_md, position, published, timestamps
  - Add slug generation on changeset
  - Add position ordering
- [ ] Create `Artwork` schema and migration
  - Fields: id, title, slug, year, medium, dimensions, status (enum), price_cents, currency, location, description_md, position, featured, published, series_id, timestamps
  - Add belongs_to :series association
  - Add slug generation
  - Add status enum validation (:available, :sold, :reserved)
- [ ] Create `Media.Image` schema and migration
  - Fields: id, artwork_id, role, original_url, large_url, medium_url, thumb_url, alt_text, position, timestamps
  - Add belongs_to :artwork association
  - Add role validation (main, detail, in_situ)

### 1.3 Database Schema Setup - Supporting Content
- [ ] Create `Exhibition` schema and migration
  - Fields: id, title, venue, city, country, start_date, end_date, description_md, position, published, timestamps
- [ ] Create `PressFeature` schema and migration
  - Fields: id, title, publication, issue, date, url, excerpt_md, position, published, timestamps
- [ ] Create `ClientProject` schema and migration
  - Fields: id, name, client_name, location, status, description_md, position, published, timestamps

### 1.4 Database Schema Setup - CMS & User Interactions
- [ ] Create `Page` schema and migration
  - Fields: id, slug (unique), title, timestamps
- [ ] Create `PageSection` schema and migration
  - Fields: id, page_id, key, content_md, position, timestamps
  - Add belongs_to :page association
- [ ] Create `Subscriber` schema and migration
  - Fields: id, email (unique), source, timestamps
- [ ] Create `Enquiry` schema and migration (optional but recommended)
  - Fields: id, type, artwork_id, name, email, message, meta (map), timestamps

## Phase 2: Media Storage & Processing

### 2.1 S3/Tigris Integration
- [ ] Add dependencies to mix.exs:
  - `ex_aws`
  - `ex_aws_s3`
  - `sweet_xml` (for AWS XML parsing)
  - `image` or `mogrify` (for image processing)
- [ ] Run `mix deps.get`
- [ ] Add S3 configuration to config/runtime.exs
  - Bucket name from env
  - Access key/secret from env
  - Region configuration for Tigris
- [ ] Create `Olivia.Media` context module
- [ ] Implement `process_and_upload_image/2` function
  - Accept file path and original filename
  - Generate UUID-based key
  - Create resized versions (large: 1200px, medium: 600px, thumb: 200px)
  - Upload all versions to S3
  - Return map with all URLs
- [ ] Add helper functions for image deletion
- [ ] Test upload/download flow

## Phase 3: Business Logic Contexts

### 3.1 Content Context
- [ ] Create `Olivia.Content` context module
- [ ] Implement Series functions:
  - `list_series/1` (with published filter)
  - `get_series!/1`
  - `get_series_by_slug!/1`
  - `create_series/1`
  - `update_series/2`
  - `delete_series/1`
  - `change_series/1`
- [ ] Implement Artwork functions:
  - `list_artworks/1` (with filters: series, status, featured, published)
  - `get_artwork!/1`
  - `get_artwork_by_slug!/1`
  - `create_artwork/1`
  - `update_artwork/2`
  - `delete_artwork/1`
  - `change_artwork/1`
  - `list_artworks_for_series/1`
  - `list_featured_artworks/0`
  - `list_available_artworks/0`
- [ ] Implement Image functions:
  - `create_image/1`
  - `update_image/2`
  - `delete_image/1`
  - `reorder_images/2`

### 3.2 Exhibition & Press Context
- [ ] Create `Olivia.Exhibitions` context
  - CRUD functions for exhibitions
  - `list_published_exhibitions/0`
- [ ] Create `Olivia.Press` context
  - CRUD functions for press features
  - `list_published_press/0`

### 3.3 Projects Context
- [ ] Create `Olivia.Projects` context
  - CRUD functions for client projects
  - `list_published_projects/0`

### 3.4 CMS Context
- [ ] Create `Olivia.CMS` context
  - `get_page_by_slug!/1`
  - `get_page_section/2` (page_slug, section_key)
  - `update_page_section/3`
  - `list_sections_for_page/1`
- [ ] Create seed data for initial pages:
  - home (with sections: hero_title, hero_subtitle, intro, hotels_teaser, newsletter_blurb)
  - about (with sections: short_intro, main_story_md, bio_md)
  - collect (with sections: body, commissions)
  - hotels-designers (with sections: intro, what_we_offer)
  - press-projects (with sections: intro)

### 3.5 Communications Context
- [ ] Create `Olivia.Communications` context
- [ ] Implement Subscriber functions:
  - `subscribe/1`
  - `list_subscribers/0`
  - `export_subscribers_csv/0`
- [ ] Implement Enquiry functions:
  - `create_enquiry/1`
  - `list_enquiries/0`
  - Email notification on enquiry submission

## Phase 4: Email Configuration

### 4.1 Swoosh Setup
- [ ] Configure Swoosh adapter in config/runtime.exs
- [ ] Add SMTP settings (or chosen email provider)
- [ ] Create email templates module `Olivia.Emails`
- [ ] Implement enquiry notification email
- [ ] Implement artwork enquiry email
- [ ] Implement project enquiry email
- [ ] Test email delivery in dev environment

## Phase 5: Admin Interface

### 5.1 Admin Layout & Navigation
- [ ] Create admin layout template in `lib/olivia_web/components/layouts/admin.html.heex`
- [ ] Add admin navigation sidebar/header
- [ ] Create admin dashboard LiveView `/admin`
- [ ] Add route protection with auth plug

### 5.2 Series Admin
- [ ] Generate series admin: `mix phx.gen.live Content Series series title:string slug:string summary:text body_md:text position:integer published:boolean --web Admin --context-app olivia`
- [ ] Customize series form:
  - Add Markdown editor for body_md
  - Add position field
  - Add published toggle
- [ ] Customize series list:
  - Show artwork count
  - Add drag-and-drop reordering (future enhancement)
  - Quick publish/unpublish toggle

### 5.3 Artwork Admin
- [ ] Generate artwork admin: `mix phx.gen.live Content Artwork artworks title:string slug:string year:integer medium:string dimensions:string status:string price_cents:integer currency:string location:string description_md:text position:integer featured:boolean published:boolean series_id:references:series --web Admin`
- [ ] Customize artwork form:
  - Add series dropdown (preload series)
  - Add status enum select
  - Add Markdown editor for description
  - Implement image upload with `allow_upload`
  - Add image role selector for each upload
  - Display existing images with reorder/delete options
- [ ] Implement image upload handling:
  - Process uploaded entries on save
  - Call Media.process_and_upload_image/2
  - Create Image records
- [ ] Customize artwork list:
  - Show thumbnail
  - Show series name
  - Show status badge
  - Quick filters by status/series

### 5.4 Exhibitions Admin
- [ ] Generate exhibitions admin
- [ ] Customize form with date pickers
- [ ] Customize list with date display

### 5.5 Press Features Admin
- [ ] Generate press features admin
- [ ] Add URL validation
- [ ] Customize list with publication/date

### 5.6 Client Projects Admin
- [ ] Generate client projects admin
- [ ] Add status dropdown
- [ ] Customize list view

### 5.7 Page/Section Editor Admin
- [ ] Create pages list LiveView `/admin/pages`
- [ ] Create page sections editor LiveView `/admin/pages/:id`
- [ ] Display all sections for page with labeled textareas
- [ ] Add Markdown preview option
- [ ] Save all sections at once

### 5.8 Subscribers Admin
- [ ] Create subscribers list LiveView `/admin/subscribers`
- [ ] Display table with email, source, date
- [ ] Add CSV export button/function
- [ ] Implement CSV generation

### 5.9 Enquiries Admin (Optional)
- [ ] Create enquiries list LiveView `/admin/enquiries`
- [ ] Display with type, name, email, date
- [ ] Add detail view/modal
- [ ] Add mark-as-read functionality (optional)

## Phase 6: Public-Facing LiveViews

### 6.1 Home Page
- [ ] Create `OliviaWeb.HomeLive` module
- [ ] Add route: `live "/", HomeLive`
- [ ] Implement mount/3:
  - Load page sections for "home"
  - Load featured series (2 max, ordered by position)
  - Load featured artwork for hero image
- [ ] Create template layout:
  - Hero section with image and titles
  - Intro text section
  - Featured series grid
  - Hotels teaser section
  - Email subscription form
  - About teaser with link
- [ ] Implement email subscription form handling
- [ ] Add success/error flash messages

### 6.2 Series Show Page
- [ ] Create `OliviaWeb.SeriesShowLive` module
- [ ] Add route: `live "/series/:slug", SeriesShowLive`
- [ ] Implement mount/3:
  - Load series by slug (published only)
  - Preload published artworks with main images
- [ ] Create template:
  - Series header (title, body markdown)
  - Artwork grid with cards
  - Status badges
  - Links to artwork pages

### 6.3 Artwork Show Page
- [ ] Create `OliviaWeb.ArtworkShowLive` module
- [ ] Add route: `live "/artworks/:slug", ArtworkShowLive`
- [ ] Implement mount/3:
  - Load artwork by slug (published only)
  - Preload images and series
- [ ] Create template:
  - Main image display (large)
  - Additional images gallery
  - Metadata panel (title, year, medium, dimensions, status, location, price)
  - Description markdown
  - Series link if applicable
  - Enquiry form
- [ ] Implement enquiry form handling:
  - Validate input
  - Create enquiry record
  - Send email notification
  - Show success message

### 6.4 About Page
- [ ] Create `OliviaWeb.AboutLive` module
- [ ] Add route: `live "/about", AboutLive`
- [ ] Implement mount/3:
  - Load page sections for "about"
  - Load published exhibitions
  - Load published press features
- [ ] Create template:
  - Main story section
  - Bio section
  - Exhibitions list
  - Press features list
  - Optional: studio images

### 6.5 Collect Page
- [ ] Create `OliviaWeb.CollectLive` module
- [ ] Add route: `live "/collect", CollectLive`
- [ ] Implement mount/3:
  - Load page sections for "collect"
  - Load available artworks (status: available, published)
- [ ] Create template:
  - Intro copy
  - Available originals grid
  - "How collecting works" section
  - Commissions section
  - General contact form
- [ ] Implement general contact form handling

### 6.6 Hotels & Designers Page
- [ ] Create `OliviaWeb.HotelsDesignersLive` module
- [ ] Add route: `live "/hotels-and-designers", HotelsDesignersLive`
- [ ] Implement mount/3:
  - Load page sections
  - Load featured artworks suitable for hospitality
  - Load published client projects
- [ ] Create template:
  - Intro copy
  - "What I can offer" section
  - Selected artworks showcase
  - Client projects list
  - Project enquiry form
- [ ] Implement project enquiry form:
  - Project type dropdown
  - Location, scope, budget fields
  - Send email + create enquiry

### 6.7 Press & Projects Page
- [ ] Create `OliviaWeb.PressProjectsLive` module
- [ ] Add route: `live "/press-projects", PressProjectsLive`
- [ ] Implement mount/3:
  - Load page sections
  - Load published press features
  - Load published client projects
- [ ] Create template:
  - Intro
  - Press features list
  - Print collaboration highlight
  - Hospitality projects section

## Phase 7: Shared Components & Styling

### 7.1 Reusable Components
- [ ] Create artwork card component
  - Thumbnail image
  - Title, status badge
  - Optional: price, dimensions
- [ ] Create series card component
- [ ] Create status badge component
- [ ] Create markdown renderer component
- [ ] Create image gallery component
- [ ] Create form components:
  - Email input with validation
  - Textarea with character count
  - Select dropdowns with styling

### 7.2 Layout & Navigation
- [ ] Create public site header component
  - Logo/site name
  - Main navigation menu
  - Mobile hamburger menu
- [ ] Create footer component
  - Artist info
  - Navigation links
  - Social links (Instagram)
  - Optional: email capture
- [ ] Update root layout to use header/footer

### 7.3 Styling with Tailwind
- [ ] Define color palette in tailwind.config.js
  - Neutral tones for gallery aesthetic
  - Accent colors for CTAs
- [ ] Create typography classes
  - Headings hierarchy
  - Body text
  - Captions
- [ ] Style all public pages:
  - Mobile-first responsive approach
  - Image aspect ratios
  - Grid layouts for artwork/series
  - Form styling
- [ ] Style admin interface:
  - Simple, functional design
  - Clear hierarchy
  - Form layouts
  - Table styling

### 7.4 Accessibility
- [ ] Add semantic HTML throughout
- [ ] Ensure proper heading hierarchy
- [ ] Add alt text to all images (from Media.Image)
- [ ] Add ARIA labels where needed
- [ ] Test keyboard navigation
- [ ] Ensure sufficient color contrast

## Phase 8: Data Seeding & Testing

### 8.1 Seed Data
- [ ] Create comprehensive seed script `priv/repo/seeds.exs`:
  - Create admin user
  - Create initial pages with sections
  - Create sample series (2-3)
  - Create sample artworks (8-10)
  - Create sample exhibitions (3-4)
  - Create sample press features (2-3)
  - Create sample client project
- [ ] Run seeds and verify data

### 8.2 Manual Testing Checklist
- [ ] Test admin login flow
- [ ] Test creating/editing series
- [ ] Test creating artwork with image uploads
- [ ] Test editing page sections
- [ ] Test email subscription
- [ ] Test artwork enquiry
- [ ] Test project enquiry
- [ ] Test all public pages render correctly
- [ ] Test mobile responsive layouts
- [ ] Test 404/error pages

### 8.3 Automated Tests (Time Permitting)
- [ ] Context tests for major functions
- [ ] LiveView tests for critical flows
- [ ] Email delivery tests

## Phase 9: Deployment Preparation

### 9.1 Environment Configuration
- [ ] Document required environment variables:
  - Database URL
  - Secret key base
  - S3/Tigris credentials (bucket, region, access key, secret)
  - Email/SMTP settings
  - Admin user seed credentials
- [ ] Update config/runtime.exs with all configs
- [ ] Create .env.example file

### 9.2 Fly.io Deployment
- [ ] Initialize Fly.io app: `fly launch`
- [ ] Configure Dockerfile (should be generated)
- [ ] Set secrets: `fly secrets set KEY=value`
- [ ] Create Postgres database
- [ ] Deploy: `fly deploy`
- [ ] Run migrations: `fly ssh console -C "/app/bin/migrate"`
- [ ] Run seeds remotely or create admin via IEx
- [ ] Test production site

### 9.3 Production Checklist
- [ ] Verify S3 uploads work
- [ ] Verify emails send
- [ ] Verify admin login
- [ ] Verify all public pages
- [ ] Check performance/load times
- [ ] Set up error monitoring (optional)

## Phase 10: Documentation & Handoff

### 10.1 Documentation
- [ ] Update README.md:
  - Project overview
  - Setup instructions
  - Environment variables
  - Running locally
  - Deployment steps
- [ ] Create ADMIN_GUIDE.md:
  - How to log in
  - How to create/edit series
  - How to upload artwork
  - How to edit page content
  - How to export subscribers
- [ ] Document any custom code/decisions

### 10.2 Final Review
- [ ] Code cleanup pass
- [ ] Remove debug code/comments
- [ ] Run `mix format`
- [ ] Run `mix credo` and address issues
- [ ] Final visual QA on all pages

## Out of Scope (Future V2+)
- Presence features
- Live comments/reactions
- E-commerce/payment integration
- Multi-language support
- Blogging platform
- Advanced SEO tooling
- Multi-role admin system
- External mailing service integration (Mailchimp)
- Advanced analytics

## Notes
- All code in appropriate Phoenix contexts (not a monolithic namespace)
- Prefer LiveView generators then customize
- Keep admin functional, not fancy
- Mobile-responsive but not pixel-perfect
- Focus on core functionality over polish for v1
- Use Markdown for rich text editing (simple, no WYSIWYG needed)
