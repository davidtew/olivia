defmodule OliviaWeb.ArtworkLive.Show do
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
    <div style="padding: 4rem 1rem;">
      <div style="max-width: 1000px; margin: 0 auto; display: grid; grid-template-columns: 1fr 1fr; gap: 4rem; align-items: start;">
        <div>
          <div :if={@artwork.image_url} style="border: 1px solid var(--cottage-taupe); border-radius: 8px; overflow: hidden;">
            <.artwork_image
              src={@artwork.image_url}
              alt={@artwork.title}
              aspect="aspect-[4/5]"
              style="width: 100%; display: block;"
              sizes="(max-width: 768px) 100vw, 50vw"
              loading="eager"
            />
          </div>
          <div
            :if={!@artwork.image_url}
            style="aspect-ratio: 4/5; background: var(--cottage-beige); border: 1px solid var(--cottage-taupe); border-radius: 8px; display: flex; align-items: center; justify-content: center;"
          >
            <span class="cottage-body" style="font-size: 1rem; color: var(--cottage-text-light);">No image available</span>
          </div>
        </div>

        <div>
          <h1 class="cottage-heading" style="font-size: 2.5rem; margin-bottom: 1rem;">
            <%= @artwork.title %>
          </h1>

          <div style="margin-bottom: 2rem;">
            <p :if={@artwork.price_cents && @artwork.status == "available"} class="cottage-heading" style="font-size: 2rem; color: var(--cottage-wisteria); margin: 0;">
              <%= format_price(@artwork.price_cents, @artwork.currency) %>
            </p>
            <span
              :if={@artwork.status == "sold"}
              class="cottage-body"
              style="display: inline-block; font-size: 1rem; text-transform: uppercase; letter-spacing: 0.05em; color: var(--cottage-text-medium); padding: 0.5rem 1rem; border: 1px solid var(--cottage-taupe); border-radius: 4px;"
            >
              Sold
            </span>
            <span
              :if={@artwork.status == "reserved"}
              class="cottage-body"
              style="display: inline-block; font-size: 1rem; text-transform: uppercase; letter-spacing: 0.05em; color: var(--cottage-wisteria); padding: 0.5rem 1rem; border: 1px solid var(--cottage-wisteria); border-radius: 4px;"
            >
              Reserved
            </span>
          </div>

          <div class="cottage-body" style="margin-bottom: 2rem; font-size: 1.125rem; line-height: 1.75;">
            <%= raw(Earmark.as_html!(@artwork.description_md || "")) %>
          </div>

          <div style="border-top: 1px solid var(--cottage-taupe); padding-top: 1.5rem; margin-bottom: 2rem;">
            <dl style="display: grid; gap: 0.75rem;">
              <div style="display: flex; justify-content: space-between;">
                <dt class="cottage-body" style="font-size: 0.875rem; color: var(--cottage-text-light); text-transform: uppercase; letter-spacing: 0.05em;">Year</dt>
                <dd class="cottage-body" style="font-size: 0.875rem; color: var(--cottage-text-dark); font-weight: 500;"><%= @artwork.year %></dd>
              </div>
              <div style="display: flex; justify-content: space-between;">
                <dt class="cottage-body" style="font-size: 0.875rem; color: var(--cottage-text-light); text-transform: uppercase; letter-spacing: 0.05em;">Medium</dt>
                <dd class="cottage-body" style="font-size: 0.875rem; color: var(--cottage-text-dark); font-weight: 500;"><%= @artwork.medium %></dd>
              </div>
              <div :if={@artwork.dimensions} style="display: flex; justify-content: space-between;">
                <dt class="cottage-body" style="font-size: 0.875rem; color: var(--cottage-text-light); text-transform: uppercase; letter-spacing: 0.05em;">Dimensions</dt>
                <dd class="cottage-body" style="font-size: 0.875rem; color: var(--cottage-text-dark); font-weight: 500;"><%= @artwork.dimensions %></dd>
              </div>
              <div :if={@artwork.series} style="display: flex; justify-content: space-between;">
                <dt class="cottage-body" style="font-size: 0.875rem; color: var(--cottage-text-light); text-transform: uppercase; letter-spacing: 0.05em;">Collection</dt>
                <dd class="cottage-body" style="font-size: 0.875rem; color: var(--cottage-text-dark); font-weight: 500;">
                  <.link navigate={~p"/series/#{@artwork.series.slug}"} style="color: var(--cottage-wisteria); text-decoration: none; border-bottom: 1px solid var(--cottage-wisteria);">
                    <%= @artwork.series.title %>
                  </.link>
                </dd>
              </div>
            </dl>
          </div>

          <div :if={@artwork.status == "available"} style="margin-bottom: 2rem;">
            <.link
              navigate={~p"/contact"}
              class="cottage-button"
              style="display: inline-block; padding: 1rem 2rem; text-decoration: none;"
            >
              Enquire About This Work
            </.link>
          </div>

          <div style="border-top: 1px solid var(--cottage-taupe); padding-top: 1.5rem;">
            <.link
              navigate={@artwork.series && ~p"/series/#{@artwork.series.slug}" || ~p"/series"}
              class="cottage-body"
              style="font-size: 0.875rem; text-transform: uppercase; letter-spacing: 0.05em; color: var(--cottage-wisteria); text-decoration: none; border-bottom: 1px solid var(--cottage-wisteria); padding-bottom: 0.25rem;"
            >
              <%= if @artwork.series, do: "← Back to #{@artwork.series.title}", else: "← Back to all collections" %>
            </.link>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp render_gallery(assigns) do
    ~H"""
    <div style="padding: 4rem 1.5rem;">
      <div style="max-width: 72rem; margin: 0 auto; display: grid; grid-template-columns: 1fr; gap: 3rem; align-items: start;">
        <!-- Image -->
        <div style="max-width: 48rem; margin: 0 auto; width: 100%;">
          <div :if={@artwork.image_url} class="elegant-border" style="overflow: hidden;">
            <.artwork_image
              src={@artwork.image_url}
              alt={@artwork.title}
              aspect="aspect-[4/5]"
              style="width: 100%; display: block;"
              sizes="(max-width: 768px) 100vw, 48rem"
              loading="eager"
            />
          </div>
          <div
            :if={!@artwork.image_url}
            class="elegant-border"
            style="aspect-ratio: 4/5; background: #fafafa; display: flex; align-items: center; justify-content: center;"
          >
            <span style="font-size: 1rem; color: #999;">No image available</span>
          </div>
        </div>

        <!-- Artwork Details -->
        <div style="max-width: 42rem; margin: 0 auto; width: 100%;">
          <h1 class="gallery-heading" style="font-size: 2.5rem; color: #2c2416; margin-bottom: 1rem;">
            <%= @artwork.title %>
          </h1>

          <!-- Price/Status -->
          <div style="margin-bottom: 2rem;">
            <p :if={@artwork.price_cents && @artwork.status == "available"} class="gallery-heading" style="font-size: 2rem; color: #8b7355; margin: 0;">
              <%= format_price(@artwork.price_cents, @artwork.currency) %>
            </p>
            <span
              :if={@artwork.status == "sold"}
              style="display: inline-block; font-size: 1rem; text-transform: uppercase; letter-spacing: 0.05em; color: #8b4513; padding: 0.5rem 1rem; border: 1px solid #d2691e; border-radius: 4px;"
            >
              Sold
            </span>
            <span
              :if={@artwork.status == "reserved"}
              style="display: inline-block; font-size: 1rem; text-transform: uppercase; letter-spacing: 0.05em; color: #b8860b; padding: 0.5rem 1rem; border: 1px solid #daa520; border-radius: 4px;"
            >
              Reserved
            </span>
          </div>

          <!-- Description -->
          <div style="margin-bottom: 2rem; color: #4a4034; font-size: 1.125rem; line-height: 1.75;">
            <%= raw(Earmark.as_html!(@artwork.description_md || "")) %>
          </div>

          <!-- Details -->
          <div style="border-top: 1px solid #e8e6e3; padding-top: 1.5rem; margin-bottom: 2rem;">
            <dl style="display: grid; gap: 0.75rem;">
              <div style="display: flex; justify-content: space-between;">
                <dt style="font-size: 0.875rem; color: #9a8a7a; text-transform: uppercase; letter-spacing: 0.05em;">Year</dt>
                <dd style="font-size: 0.875rem; color: #2c2416; font-weight: 500;"><%= @artwork.year %></dd>
              </div>
              <div style="display: flex; justify-content: space-between;">
                <dt style="font-size: 0.875rem; color: #9a8a7a; text-transform: uppercase; letter-spacing: 0.05em;">Medium</dt>
                <dd style="font-size: 0.875rem; color: #2c2416; font-weight: 500;"><%= @artwork.medium %></dd>
              </div>
              <div :if={@artwork.dimensions} style="display: flex; justify-content: space-between;">
                <dt style="font-size: 0.875rem; color: #9a8a7a; text-transform: uppercase; letter-spacing: 0.05em;">Dimensions</dt>
                <dd style="font-size: 0.875rem; color: #2c2416; font-weight: 500;"><%= @artwork.dimensions %></dd>
              </div>
              <div :if={@artwork.location} style="display: flex; justify-content: space-between;">
                <dt style="font-size: 0.875rem; color: #9a8a7a; text-transform: uppercase; letter-spacing: 0.05em;">Location</dt>
                <dd style="font-size: 0.875rem; color: #2c2416; font-weight: 500;"><%= @artwork.location %></dd>
              </div>
              <div :if={@artwork.series} style="display: flex; justify-content: space-between; border-top: 1px solid #e8e6e3; padding-top: 0.75rem; margin-top: 0.75rem;">
                <dt style="font-size: 0.875rem; color: #9a8a7a; text-transform: uppercase; letter-spacing: 0.05em;">Collection</dt>
                <dd style="font-size: 0.875rem; color: #8b7355;">
                  <.link navigate={~p"/series/#{@artwork.series.slug}"} style="text-decoration: none; color: inherit; border-bottom: 1px solid #c4b5a0;">
                    <%= @artwork.series.title %>
                  </.link>
                </dd>
              </div>
            </dl>
          </div>

          <!-- CTA Button -->
          <div :if={@artwork.status == "available"} style="margin-bottom: 2rem;">
            <.link
              navigate={~p"/collect"}
              style="display: block; width: 100%; text-align: center; padding: 1rem 2rem; background: #6b5d54; color: #faf8f5; font-size: 0.875rem; text-transform: uppercase; letter-spacing: 0.05em; text-decoration: none; border: none; cursor: pointer; transition: background-color 0.2s;"
            >
              Enquire about this work
            </.link>
          </div>

          <!-- Back Link -->
          <div style="text-align: center;">
            <.link
              navigate={
                if @artwork.series,
                  do: ~p"/series/#{@artwork.series.slug}",
                  else: ~p"/series"
              }
              style="font-size: 0.875rem; text-transform: uppercase; letter-spacing: 0.05em; color: #8b7355; text-decoration: none; border-bottom: 1px solid #c4b5a0; padding-bottom: 0.25rem;"
            >
              ← Back to <%= if @artwork.series, do: @artwork.series.title, else: "collections" %>
            </.link>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp render_default(assigns) do
    ~H"""
    <div class="bg-white">
      <div class="mx-auto max-w-2xl px-4 py-16 sm:px-6 sm:py-24 lg:max-w-7xl lg:px-8">
        <div class="lg:grid lg:grid-cols-2 lg:items-start lg:gap-x-8">
          <!-- Image gallery -->
          <div class="flex flex-col-reverse">
            <div :if={@artwork.image_url}>
              <.artwork_image
                src={@artwork.image_url}
                alt={@artwork.title}
                aspect="aspect-[4/5]"
                class="rounded-lg shadow-lg"
                sizes="(max-width: 1024px) 100vw, 50vw"
                loading="eager"
              />
            </div>
            <div
              :if={!@artwork.image_url}
              class="aspect-[4/5] w-full overflow-hidden rounded-lg bg-gray-100 flex items-center justify-center"
            >
              <span class="text-lg text-gray-400">No image available</span>
            </div>
          </div>

          <!-- Artwork info -->
          <div class="mt-10 px-4 sm:mt-16 sm:px-0 lg:mt-0">
            <h1 class="text-3xl font-bold tracking-tight text-gray-900">
              <%= @artwork.title %>
            </h1>

            <div class="mt-3">
              <h2 class="sr-only">Artwork information</h2>
              <p :if={@artwork.price_cents && @artwork.status == "available"} class="text-3xl tracking-tight text-gray-900">
                <%= format_price(@artwork.price_cents, @artwork.currency) %>
              </p>
              <p :if={@artwork.status == "sold"} class="text-xl tracking-tight text-red-700">
                Sold
              </p>
              <p :if={@artwork.status == "reserved"} class="text-xl tracking-tight text-yellow-700">
                Reserved
              </p>
            </div>

            <div class="mt-6">
              <h3 class="sr-only">Description</h3>
              <div class="prose prose-gray">
                <%= raw(Earmark.as_html!(@artwork.description_md || "")) %>
              </div>
            </div>

            <div class="mt-6 space-y-2">
              <div class="flex justify-between text-sm">
                <dt class="text-gray-500">Year</dt>
                <dd class="font-medium text-gray-900"><%= @artwork.year %></dd>
              </div>
              <div class="flex justify-between text-sm">
                <dt class="text-gray-500">Medium</dt>
                <dd class="font-medium text-gray-900"><%= @artwork.medium %></dd>
              </div>
              <div :if={@artwork.dimensions} class="flex justify-between text-sm">
                <dt class="text-gray-500">Dimensions</dt>
                <dd class="font-medium text-gray-900"><%= @artwork.dimensions %></dd>
              </div>
              <div :if={@artwork.location} class="flex justify-between text-sm">
                <dt class="text-gray-500">Location</dt>
                <dd class="font-medium text-gray-900"><%= @artwork.location %></dd>
              </div>
              <div :if={@artwork.series} class="flex justify-between text-sm border-t pt-2 mt-4">
                <dt class="text-gray-500">Series</dt>
                <dd class="font-medium text-gray-900">
                  <.link navigate={~p"/series/#{@artwork.series.slug}"} class="hover:text-gray-600">
                    <%= @artwork.series.title %>
                  </.link>
                </dd>
              </div>
            </div>

            <div :if={@artwork.status == "available"} class="mt-10">
              <.link
                navigate={~p"/collect"}
                class="flex w-full items-center justify-center rounded-md border border-transparent bg-gray-900 px-8 py-3 text-base font-medium text-white hover:bg-gray-800 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2"
              >
                Enquire about this work
              </.link>
            </div>

            <div class="mt-6">
              <.link
                navigate={
                  if @artwork.series,
                    do: ~p"/series/#{@artwork.series.slug}",
                    else: ~p"/series"
                }
                class="text-sm font-semibold text-gray-900"
              >
                ← Back to <%= if @artwork.series, do: @artwork.series.title, else: "series" %>
              </.link>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(%{"slug" => slug}, _session, socket) do
    artwork = Content.get_artwork_by_slug!(slug, published: true, preload: [:series])

    {:ok,
     socket
     |> assign(:page_title, "#{artwork.title} - Olivia Tew")
     |> assign(:artwork, artwork)}
  end

  defp format_price(cents, currency) do
    amount = cents / 100
    symbol =
      case currency do
        "GBP" -> "£"
        "USD" -> "$"
        "EUR" -> "€"
        _ -> currency
      end

    formatted = :erlang.float_to_binary(amount, decimals: 0)
    "#{symbol}#{formatted}"
  end
end
