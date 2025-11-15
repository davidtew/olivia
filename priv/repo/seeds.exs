# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Olivia.Repo.insert!(%Olivia.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Olivia.Repo
alias Olivia.Accounts.User
alias Olivia.Content.{Series, Artwork}
alias Olivia.Media.Image
alias Olivia.Exhibitions.Exhibition
alias Olivia.Press.PressFeature
alias Olivia.Projects.ClientProject
alias Olivia.CMS.{Page, PageSection}
alias Olivia.Communications.Subscriber

# Clear existing data (for development)
IO.puts("Clearing existing data...")
Repo.delete_all(PageSection)
Repo.delete_all(Page)
Repo.delete_all(Image)
Repo.delete_all(Artwork)
Repo.delete_all(Series)
Repo.delete_all(Exhibition)
Repo.delete_all(PressFeature)
Repo.delete_all(ClientProject)
Repo.delete_all(Subscriber)

IO.puts("Creating admin user...")
# Create admin user (magic link auth - no password needed)
admin =
  Repo.insert!(%User{
    email: "admin@olivia.art",
    confirmed_at: DateTime.utc_now(:second)
  })

IO.puts("Admin user created: #{admin.email}")

# Create Series
IO.puts("\nCreating series...")

quiet_rituals =
  Repo.insert!(%Series{
    title: "Quiet Rituals",
    slug: "quiet-rituals",
    summary: "Intimate moments of daily life, captured in soft light and gentle brushwork.",
    body_md: """
    # Quiet Rituals

    This series explores the tender, often overlooked moments that make up our daily lives.
    Morning coffee, an unmade bed, light streaming through curtains—these are the rituals
    we rarely frame, yet they shape our experience of home and belonging.

    Working in oils, I've focused on the interplay of natural light and domestic spaces,
    seeking to capture not just what these moments look like, but how they *feel*.
    """,
    position: 1,
    published: true
  })

interior_landscapes =
  Repo.insert!(%Series{
    title: "Interior Landscapes",
    slug: "interior-landscapes",
    summary: "Exploring the emotional geography of private spaces.",
    body_md: """
    # Interior Landscapes

    These paintings examine the way our interior spaces reflect our interior lives.
    Empty rooms become portraits, furniture tells stories, and the quality of light
    suggests time passing and emotions held.

    Each piece in this series considers the relationship between solitude and space,
    asking how the places we inhabit shape us, and how we, in turn, shape them.
    """,
    position: 2,
    published: true
  })

hospitality_works =
  Repo.insert!(%Series{
    title: "Hospitality Collection",
    slug: "hospitality-collection",
    summary: "Large-scale works designed for hotel and spa environments.",
    body_md: """
    # Hospitality Collection

    This series was developed specifically for hospitality environments—hotels, spas,
    and wellness spaces where a sense of calm and quiet luxury is essential.

    The works are larger in scale and designed to create atmosphere, using muted palettes
    and abstract compositions that complement rather than compete with their surroundings.
    """,
    position: 3,
    published: true
  })

# Create Artworks
IO.puts("Creating artworks...")

# Quiet Rituals artworks
Repo.insert!(%Artwork{
  title: "Morning Light",
  slug: "morning-light",
  series_id: quiet_rituals.id,
  year: 2024,
  medium: "Oil on canvas",
  dimensions: "80 × 60 cm",
  status: "available",
  price_cents: 185_000,
  currency: "GBP",
  location: "Studio, London",
  description_md: """
  Early morning light filtering through linen curtains. This piece captures that particular
  quality of pre-dawn illumination—soft, cool, and full of possibility.
  """,
  position: 1,
  featured: true,
  published: true
})

Repo.insert!(%Artwork{
  title: "Unmade",
  slug: "unmade",
  series_id: quiet_rituals.id,
  year: 2024,
  medium: "Oil on linen",
  dimensions: "70 × 90 cm",
  status: "sold",
  location: "Private collection, Switzerland",
  description_md: """
  An unmade bed in afternoon light. The rumpled sheets and pillows hold the memory
  of rest, of bodies that have left their impression.
  """,
  position: 2,
  published: true
})

Repo.insert!(%Artwork{
  title: "Coffee and Silence",
  slug: "coffee-and-silence",
  series_id: quiet_rituals.id,
  year: 2024,
  medium: "Oil on canvas",
  dimensions: "50 × 50 cm",
  status: "available",
  price_cents: 125_000,
  currency: "GBP",
  location: "Studio, London",
  description_md: """
  A single cup on a table, steam rising into the morning air. The ritual of first coffee,
  that moment before the day truly begins.
  """,
  position: 3,
  published: true
})

# Interior Landscapes artworks
Repo.insert!(%Artwork{
  title: "Empty Room #1",
  slug: "empty-room-1",
  series_id: interior_landscapes.id,
  year: 2023,
  medium: "Oil on canvas",
  dimensions: "100 × 120 cm",
  status: "reserved",
  location: "Gallery representation",
  description_md: """
  A vacant room at dusk, all pale walls and long shadows. The space itself becomes
  the subject, pregnant with absence and possibility.
  """,
  position: 1,
  published: true
})

Repo.insert!(%Artwork{
  title: "Between Seasons",
  slug: "between-seasons",
  series_id: interior_landscapes.id,
  year: 2023,
  medium: "Oil on linen",
  dimensions: "80 × 100 cm",
  status: "available",
  price_cents: 220_000,
  currency: "GBP",
  location: "Studio, London",
  description_md: """
  A corner of a room where spring light meets winter furniture. The turning of seasons
  felt through interior space.
  """,
  position: 2,
  featured: true,
  published: true
})

# Hospitality Collection artworks
Repo.insert!(%Artwork{
  title: "Tranquil #1",
  slug: "tranquil-1",
  series_id: hospitality_works.id,
  year: 2024,
  medium: "Oil on canvas",
  dimensions: "150 × 200 cm",
  status: "available",
  location: "Studio, London",
  description_md: """
  Large-scale abstract work in soft greys and creams. Designed to create a sense
  of calm and spaciousness in hospitality environments.
  """,
  position: 1,
  published: true
})

# Create Exhibitions
IO.puts("Creating exhibitions...")

Repo.insert!(%Exhibition{
  title: "Winter Group Show",
  venue: "Gallery 27",
  city: "London",
  country: "UK",
  start_date: ~D[2024-12-01],
  end_date: ~D[2024-12-31],
  description_md: """
  Group exhibition featuring new works from the Quiet Rituals series alongside
  works by contemporary painters.
  """,
  position: 1,
  published: true
})

Repo.insert!(%Exhibition{
  title: "Interior States",
  venue: "The White Space Gallery",
  city: "Bristol",
  country: "UK",
  start_date: ~D[2023-09-15],
  end_date: ~D[2023-10-30],
  description_md: """
  Solo exhibition of the Interior Landscapes series.
  """,
  position: 2,
  published: true
})

# Create Press Features
IO.puts("Creating press features...")

Repo.insert!(%PressFeature{
  title: "House & Garden Christmas Issue",
  publication: "Condé Nast House & Garden",
  issue: "Christmas 2024",
  date: ~D[2024-11-01],
  url: "https://example.com/house-and-garden",
  excerpt_md: """
  "Olivia's paintings capture something essential about the way we inhabit space—
  the unguarded moments, the quality of light, the texture of everyday life."
  """,
  position: 1,
  published: true
})

Repo.insert!(%PressFeature{
  title: "Emerging Artists to Watch",
  publication: "Art Review",
  issue: "Autumn 2023",
  date: ~D[2023-09-01],
  excerpt_md: """
  "A painter who finds the extraordinary in the ordinary, capturing domestic life
  with remarkable sensitivity and technical skill."
  """,
  position: 2,
  published: true
})

# Create Client Projects
IO.puts("Creating client projects...")

Repo.insert!(%ClientProject{
  name: "Swiss Luxury Hotel Collection",
  client_name: "Alpine Hospitality Group",
  location: "Switzerland",
  status: "completed",
  description_md: """
  Commissioned series of 12 large-scale works for a boutique hotel group in Switzerland.
  The 1,000-print run was produced for rooms across their properties, bringing a sense
  of calm and artistic refinement to guest spaces.
  """,
  position: 1,
  published: true
})

Repo.insert!(%ClientProject{
  name: "London Spa Interior",
  client_name: "Sanctuary Spa",
  location: "London, UK",
  status: "in progress",
  description_md: """
  Currently developing a suite of paintings for treatment rooms in a high-end London spa.
  Focus on creating atmosphere that promotes relaxation and wellbeing.
  """,
  position: 2,
  published: true
})

# Create CMS Pages and Sections
IO.puts("Creating CMS pages...")

home_page =
  Repo.insert!(%Page{
    slug: "home",
    title: "Home"
  })

Repo.insert!(%PageSection{
  page_id: home_page.id,
  key: "hero_title",
  content_md: "Olivia Tew",
  position: 1
})

Repo.insert!(%PageSection{
  page_id: home_page.id,
  key: "hero_subtitle",
  content_md: "Contemporary Painter, London",
  position: 2
})

Repo.insert!(%PageSection{
  page_id: home_page.id,
  key: "intro",
  content_md: """
  I paint the moments you don't usually frame—morning light through curtains,
  an unmade bed, the particular quality of solitude in a quiet room.

  My work explores the tender, overlooked rituals that make up our daily lives,
  seeking to capture not just what these moments look like, but how they feel.
  """,
  position: 3
})

Repo.insert!(%PageSection{
  page_id: home_page.id,
  key: "hotels_teaser",
  content_md: """
  Working with hotels, spas, and designers to create bespoke artwork that transforms spaces
  into experiences of calm and beauty.
  """,
  position: 4
})

Repo.insert!(%PageSection{
  page_id: home_page.id,
  key: "newsletter_blurb",
  content_md: "Join my mailing list for news of new work, exhibitions, and available pieces.",
  position: 5
})

about_page =
  Repo.insert!(%Page{
    slug: "about",
    title: "About"
  })

Repo.insert!(%PageSection{
  page_id: about_page.id,
  key: "short_intro",
  content_md: """
  Olivia Tew is a contemporary painter based in London, working primarily in oils
  to explore themes of domesticity, solitude, and the poetry of everyday life.
  """,
  position: 1
})

Repo.insert!(%PageSection{
  page_id: about_page.id,
  key: "main_story_md",
  content_md: """
  # About the Work

  I paint the moments you don't usually frame. Morning light through curtains.
  An unmade bed. The particular quality of solitude in a quiet room.

  My work has been featured in Condé Nast House & Garden and exhibited across the UK.
  Recently, I completed a commission for a Swiss hotel group—a 1,000-print run that now
  graces rooms across their properties.

  I work with collectors, interior designers, and hospitality clients who understand that
  art isn't decoration—it's atmosphere, memory, a way of seeing the world slowed down and
  reconsidered.
  """,
  position: 2
})

Repo.insert!(%PageSection{
  page_id: about_page.id,
  key: "bio_md",
  content_md: """
  **Olivia Tew** is a London-based painter exploring themes of domesticity and solitude.
  Her work has been featured in Condé Nast House & Garden and exhibited in galleries across
  the UK. Recent projects include a 1,000-print commission for a Swiss luxury hotel group.
  """,
  position: 3
})

collect_page =
  Repo.insert!(%Page{
    slug: "collect",
    title: "Collect"
  })

Repo.insert!(%PageSection{
  page_id: collect_page.id,
  key: "body",
  content_md: """
  # Collecting Original Work

  Original paintings are available for purchase directly. Each piece is sold with a
  certificate of authenticity and detailed care instructions.

  Prices range from £1,250 for smaller works to £2,500+ for larger pieces.
  Payment plans are available for collectors.

  All originals are carefully packaged and shipped with full insurance.
  """,
  position: 1
})

Repo.insert!(%PageSection{
  page_id: collect_page.id,
  key: "commissions",
  content_md: """
  ## Commissions

  I accept a limited number of private commissions each year. These can range from
  intimate domestic scenes to larger abstract works for specific spaces.

  Lead time is typically 8-12 weeks, depending on size and complexity.
  """,
  position: 2
})

hotels_page =
  Repo.insert!(%Page{
    slug: "hotels-designers",
    title: "Hotels & Designers"
  })

Repo.insert!(%PageSection{
  page_id: hotels_page.id,
  key: "intro",
  content_md: """
  # For Hotels, Spas & Interior Designers

  I work with hospitality and design professionals to create artwork that transforms
  spaces into experiences of calm and beauty.

  Whether you need original pieces, commissioned work, or high-quality reproductions,
  I can help you find the right solution for your project.
  """,
  position: 1
})

Repo.insert!(%PageSection{
  page_id: hotels_page.id,
  key: "what_we_offer",
  content_md: """
  ## What I Offer

  - **Original artwork** for statement spaces and private areas
  - **Commissioned pieces** tailored to your brand and aesthetic
  - **Print editions** for multiple rooms or spaces
  - **Curation support** to ensure cohesive visual storytelling

  Recent projects include a 1,000-print run for a Swiss luxury hotel group and bespoke
  originals for London spa treatment rooms.
  """,
  position: 2
})

press_page =
  Repo.insert!(%Page{
    slug: "press-projects",
    title: "Press & Projects"
  })

Repo.insert!(%PageSection{
  page_id: press_page.id,
  key: "intro",
  content_md: """
  Selected press features, exhibitions, and major projects.
  """,
  position: 1
})

# Create sample subscribers
IO.puts("Creating sample subscribers...")

Repo.insert!(%Subscriber{
  email: "collector@example.com",
  source: "website_form"
})

Repo.insert!(%Subscriber{
  email: "designer@example.com",
  source: "website_form"
})

IO.puts("\n✅ Seed data created successfully!")
IO.puts("\nAdmin login: admin@olivia.art")
IO.puts("(Use magic link - check /dev/mailbox after requesting login)")
IO.puts("\nCreated:")
IO.puts("  - 1 admin user")
IO.puts("  - 3 series")
IO.puts("  - 6 artworks")
IO.puts("  - 2 exhibitions")
IO.puts("  - 2 press features")
IO.puts("  - 2 client projects")
IO.puts("  - 5 pages with sections")
IO.puts("  - 2 subscribers")
