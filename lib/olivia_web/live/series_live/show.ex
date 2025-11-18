defmodule OliviaWeb.SeriesLive.Show do
  use OliviaWeb, :live_view

  alias Olivia.Content

  @impl true
  def render(assigns) do
    cond do
      assigns[:theme] == "cottage" -> render_cottage(assigns)
      assigns[:theme] == "gallery" -> render_gallery(assigns)
      true -> render_default(assigns)
    end
  end

  defp render_cottage(assigns) do
    ~H"""
    <div style="max-width: 1200px; margin: 0 auto; padding: 4rem 1rem;">
      <div style="text-align: center; margin-bottom: 4rem;">
        <h1 class="cottage-heading" style="font-size: 3rem; margin-bottom: 1rem;">
          <%= @series.title %>
        </h1>
        <p class="cottage-body" style="font-size: 1.25rem; color: var(--cottage-text-medium); max-width: 48rem; margin: 0 auto;">
          <%= @series.summary %>
        </p>
      </div>

      <div :if={@series.body_md} style="max-width: 48rem; margin: 0 auto; margin-bottom: 4rem;">
        <div class="cottage-body" style="font-size: 1.125rem; line-height: 1.75;">
          <%= raw(Earmark.as_html!(@series.body_md)) %>
        </div>
      </div>

      <div style="margin-top: 4rem;">
        <h2 class="cottage-heading" style="font-size: 2rem; text-align: center; margin-bottom: 3rem;">
          Works in this Collection
        </h2>
        <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 2rem;">
          <div :for={artwork <- @artworks} style="border: 1px solid var(--cottage-taupe); border-radius: 8px; overflow: hidden; background: white; box-shadow: 0 2px 8px rgba(200, 167, 216, 0.08);">
            <.link navigate={~p"/artworks/#{artwork.slug}"} style="display: block; text-decoration: none;">
              <div :if={artwork.image_url} style="aspect-ratio: 4/5; overflow: hidden;">
                <img
                  src={artwork.image_url}
                  alt={artwork.title}
                  style="width: 100%; height: 100%; object-fit: cover; display: block; transition: transform 0.3s ease;"
                />
              </div>
              <div
                :if={!artwork.image_url}
                style="aspect-ratio: 4/5; background: var(--cottage-beige); display: flex; align-items: center; justify-content: center;"
              >
                <span class="cottage-body" style="font-size: 0.875rem; color: var(--cottage-text-light);">No image</span>
              </div>
            </.link>
            <div style="padding: 1.5rem; text-align: center;">
              <h3 class="cottage-heading" style="font-size: 1.125rem; margin-bottom: 0.5rem;">
                <.link navigate={~p"/artworks/#{artwork.slug}"} style="text-decoration: none; color: inherit;">
                  <%= artwork.title %>
                </.link>
              </h3>
              <p class="cottage-body" style="font-size: 0.875rem; color: var(--cottage-text-medium); margin: 0;">
                <%= artwork.year %> · <%= artwork.medium %>
              </p>
              <p :if={artwork.dimensions} class="cottage-body" style="font-size: 0.875rem; color: var(--cottage-text-light); margin-top: 0.25rem;">
                <%= artwork.dimensions %>
              </p>
              <div style="margin-top: 0.75rem;">
                <span
                  :if={artwork.status == "available"}
                  class="cottage-body"
                  style="display: inline-block; font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.05em; color: var(--cottage-sage); padding: 0.25rem 0.75rem; border: 1px solid var(--cottage-sage); border-radius: 4px;"
                >
                  Available
                </span>
                <span
                  :if={artwork.status == "sold"}
                  class="cottage-body"
                  style="display: inline-block; font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.05em; color: var(--cottage-text-medium); padding: 0.25rem 0.75rem; border: 1px solid var(--cottage-taupe); border-radius: 4px;"
                >
                  Sold
                </span>
                <span
                  :if={artwork.status == "reserved"}
                  class="cottage-body"
                  style="display: inline-block; font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.05em; color: var(--cottage-wisteria); padding: 0.25rem 0.75rem; border: 1px solid var(--cottage-wisteria); border-radius: 4px;"
                >
                  Reserved
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div style="padding: 2rem 0; text-align: center; margin-top: 4rem; border-top: 1px solid var(--cottage-taupe);">
        <.link
          navigate={~p"/series"}
          class="cottage-body"
          style="font-size: 0.875rem; text-transform: uppercase; letter-spacing: 0.05em; color: var(--cottage-wisteria); text-decoration: none; border-bottom: 1px solid var(--cottage-wisteria); padding-bottom: 0.25rem;"
        >
          ← Back to all collections
        </.link>
      </div>
    </div>
    """
  end

  defp render_gallery(assigns) do
    ~H"""
    <!-- Gallery Hero -->
    <div style="text-align: center; padding: 4rem 1.5rem; border-bottom: 1px solid #e8e6e3;">
      <h1 class="gallery-heading" style="font-size: 3rem; color: #2c2416; margin-bottom: 1rem;">
        <%= @series.title %>
      </h1>
      <p class="gallery-script" style="font-size: 1.25rem; color: #6b5d54; max-width: 48rem; margin: 0 auto;">
        <%= @series.summary %>
      </p>
    </div>

    <!-- Description -->
    <div :if={@series.body_md} style="max-width: 48rem; margin: 0 auto; padding: 3rem 1.5rem;">
      <div style="color: #4a4034; font-size: 1.125rem; line-height: 1.75;">
        <%= raw(Earmark.as_html!(@series.body_md)) %>
      </div>
    </div>

    <!-- Artworks Grid -->
    <div style="padding: 4rem 1.5rem; border-top: 1px solid #e8e6e3;">
      <h2 class="gallery-heading" style="font-size: 2rem; color: #2c2416; text-align: center; margin-bottom: 3rem;">
        Works in this Collection
      </h2>
      <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 3rem; max-width: 80rem; margin: 0 auto;">
        <div :for={artwork <- @artworks} class="artwork-card">
          <.link navigate={~p"/artworks/#{artwork.slug}"} style="display: block; text-decoration: none;">
            <div :if={artwork.image_url} class="elegant-border" style="overflow: hidden; margin-bottom: 1rem; aspect-ratio: 4/5;">
              <img
                src={artwork.image_url}
                alt={artwork.title}
                style="width: 100%; height: 100%; object-fit: cover; display: block;"
              />
            </div>
            <div
              :if={!artwork.image_url}
              class="elegant-border"
              style="aspect-ratio: 4/5; background: #fafafa; display: flex; align-items: center; justify-content: center; margin-bottom: 1rem;"
            >
              <span style="font-size: 0.875rem; color: #999;">No image</span>
            </div>
          </.link>
          <div style="text-align: center;">
            <h3 class="gallery-heading" style="font-size: 1.125rem; color: #2c2416; margin-bottom: 0.5rem;">
              <.link navigate={~p"/artworks/#{artwork.slug}"} style="text-decoration: none; color: inherit;">
                <%= artwork.title %>
              </.link>
            </h3>
            <p style="font-size: 0.875rem; color: #6b5d54; margin: 0;">
              <%= artwork.year %> · <%= artwork.medium %>
            </p>
            <p :if={artwork.dimensions} style="font-size: 0.875rem; color: #9a8a7a; margin-top: 0.25rem;">
              <%= artwork.dimensions %>
            </p>
            <div style="margin-top: 0.5rem;">
              <span
                :if={artwork.status == "available"}
                style="display: inline-block; font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.05em; color: #6b8e23; padding: 0.25rem 0.5rem; border: 1px solid #9acd32; border-radius: 4px;"
              >
                Available
              </span>
              <span
                :if={artwork.status == "sold"}
                style="display: inline-block; font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.05em; color: #8b4513; padding: 0.25rem 0.5rem; border: 1px solid #d2691e; border-radius: 4px;"
              >
                Sold
              </span>
              <span
                :if={artwork.status == "reserved"}
                style="display: inline-block; font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.05em; color: #b8860b; padding: 0.25rem 0.5rem; border: 1px solid #daa520; border-radius: 4px;"
              >
                Reserved
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Back link -->
    <div style="padding: 2rem 1.5rem; text-align: center;">
      <.link navigate={~p"/series"} style="font-size: 0.875rem; text-transform: uppercase; letter-spacing: 0.05em; color: #8b7355; text-decoration: none; border-bottom: 1px solid #c4b5a0; padding-bottom: 0.25rem;">
        ← Back to all collections
      </.link>
    </div>
    """
  end

  defp render_default(assigns) do
    ~H"""
    <div class="bg-white">
      <!-- Header -->
      <div class="mx-auto max-w-7xl px-6 lg:px-8 py-24 sm:py-32">
        <div class="mx-auto max-w-2xl text-center">
          <h1 class="text-4xl font-bold tracking-tight text-gray-900 sm:text-5xl">
            <%= @series.title %>
          </h1>
          <p class="mt-6 text-lg leading-8 text-gray-600">
            <%= @series.summary %>
          </p>
        </div>
      </div>

      <!-- Description -->
      <div :if={@series.body_md} class="mx-auto max-w-7xl px-6 lg:px-8 pb-16">
        <div class="mx-auto max-w-2xl prose prose-lg prose-gray">
          <%= raw(Earmark.as_html!(@series.body_md)) %>
        </div>
      </div>

      <!-- Artworks Grid -->
      <div class="mx-auto max-w-7xl px-6 lg:px-8 pb-24">
        <h2 class="text-2xl font-bold tracking-tight text-gray-900 mb-12">
          Works in this Series
        </h2>
        <div class="grid grid-cols-1 gap-x-6 gap-y-10 sm:grid-cols-2 lg:grid-cols-3 xl:gap-x-8">
          <div :for={artwork <- @artworks} class="group relative">
            <.link navigate={~p"/artworks/#{artwork.slug}"}>
              <div class="aspect-[4/5] w-full overflow-hidden rounded-lg">
                <img
                  :if={artwork.image_url}
                  src={artwork.image_url}
                  alt={artwork.title}
                  class="h-full w-full object-cover group-hover:opacity-75 transition-opacity"
                />
                <div
                  :if={!artwork.image_url}
                  class="h-full w-full bg-gray-100 flex items-center justify-center"
                >
                  <span class="text-sm text-gray-400">No image</span>
                </div>
              </div>
            </.link>
            <div class="mt-4 flex justify-between">
              <div>
                <h3 class="text-sm font-medium text-gray-900">
                  <.link navigate={~p"/artworks/#{artwork.slug}"}>
                    <span aria-hidden="true" class="absolute inset-0"></span>
                    <%= artwork.title %>
                  </.link>
                </h3>
                <p class="mt-1 text-sm text-gray-500">
                  <%= artwork.year %> · <%= artwork.medium %>
                </p>
                <p :if={artwork.dimensions} class="mt-1 text-sm text-gray-500">
                  <%= artwork.dimensions %>
                </p>
              </div>
              <div>
                <span
                  :if={artwork.status == "available"}
                  class="inline-flex items-center rounded-md bg-green-50 px-2 py-1 text-xs font-medium text-green-700 ring-1 ring-inset ring-green-600/20"
                >
                  Available
                </span>
                <span
                  :if={artwork.status == "sold"}
                  class="inline-flex items-center rounded-md bg-red-50 px-2 py-1 text-xs font-medium text-red-700 ring-1 ring-inset ring-red-600/10"
                >
                  Sold
                </span>
                <span
                  :if={artwork.status == "reserved"}
                  class="inline-flex items-center rounded-md bg-yellow-50 px-2 py-1 text-xs font-medium text-yellow-800 ring-1 ring-inset ring-yellow-600/20"
                >
                  Reserved
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Back link -->
      <div class="mx-auto max-w-7xl px-6 lg:px-8 pb-24">
        <.link navigate={~p"/series"} class="text-sm font-semibold leading-6 text-gray-900">
          ← Back to all series
        </.link>
      </div>
    </div>
    """
  end

  @impl true
  def mount(%{"slug" => slug}, _session, socket) do
    series = Content.get_series_by_slug!(slug, published: true)
    artworks = Content.list_artworks(series_id: series.id, published: true)

    {:ok,
     socket
     |> assign(:page_title, "#{series.title} - Olivia Tew")
     |> assign(:series, series)
     |> assign(:artworks, artworks)}
  end
end
