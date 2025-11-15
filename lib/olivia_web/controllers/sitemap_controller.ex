defmodule OliviaWeb.SitemapController do
  use OliviaWeb, :controller

  alias Olivia.Content

  def index(conn, _params) do
    base_url = "https://oliviagraham.com"

    static_pages = [
      %{loc: "#{base_url}/", changefreq: "weekly", priority: "1.0"},
      %{loc: "#{base_url}/series", changefreq: "weekly", priority: "0.9"},
      %{loc: "#{base_url}/about", changefreq: "monthly", priority: "0.8"},
      %{loc: "#{base_url}/collect", changefreq: "monthly", priority: "0.8"},
      %{loc: "#{base_url}/hotels-designers", changefreq: "monthly", priority: "0.7"},
      %{loc: "#{base_url}/press-projects", changefreq: "monthly", priority: "0.7"},
      %{loc: "#{base_url}/contact", changefreq: "monthly", priority: "0.9"}
    ]

    series_pages =
      Content.list_series(published: true)
      |> Enum.map(fn series ->
        %{
          loc: "#{base_url}/series/#{series.slug}",
          changefreq: "weekly",
          priority: "0.8",
          lastmod: series.updated_at
        }
      end)

    artworks_pages =
      Content.list_artworks(published: true)
      |> Enum.map(fn artwork ->
        %{
          loc: "#{base_url}/artworks/#{artwork.slug}",
          changefreq: "monthly",
          priority: "0.7",
          lastmod: artwork.updated_at
        }
      end)

    all_pages = static_pages ++ series_pages ++ artworks_pages

    xml = OliviaWeb.SitemapHTML.index(%{pages: all_pages})

    conn
    |> put_resp_content_type("text/xml")
    |> send_resp(200, xml)
  end
end
