defmodule OliviaWeb.ShopLive do
  @moduledoc """
  Shop page displaying products from Swell e-commerce.
  Supports multiple themes with different renderings.
  """
  use OliviaWeb, :live_view

  alias Olivia.Swell

  @impl true
  def render(assigns) do
    cond do
      assigns[:theme] == "atelier" -> render_atelier(assigns)
      assigns[:theme] == "curator" -> render_curator(assigns)
      assigns[:theme] == "cottage" -> render_cottage(assigns)
      assigns[:theme] == "gallery" -> render_gallery(assigns)
      true -> render_default(assigns)
    end
  end

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Shop")
      |> assign(:products, [])
      |> assign(:loading, true)
      |> assign(:error, nil)
      |> assign(:cart_open, false)
      |> assign(:cart, nil)
      |> assign(:cart_count, 0)

    if connected?(socket) do
      send(self(), :load_products)
    end

    {:ok, socket}
  end

  @impl true
  def handle_info(:load_products, socket) do
    case Swell.list_products(active: true, limit: 50, expand: ["images", "categories"]) do
      {:ok, %{"results" => products}} ->
        {:noreply, assign(socket, products: products, loading: false)}

      {:ok, products} when is_list(products) ->
        {:noreply, assign(socket, products: products, loading: false)}

      {:error, :not_configured} ->
        {:noreply, assign(socket, loading: false, error: :not_configured)}

      {:error, reason} ->
        {:noreply, assign(socket, loading: false, error: reason)}
    end
  end

  @impl true
  def handle_event("add_to_cart", %{"product_id" => product_id}, socket) do
    cart_id = socket.assigns[:cart]["id"]

    result =
      if cart_id do
        Swell.add_to_cart(cart_id, %{product_id: product_id, quantity: 1})
      else
        Swell.create_cart([%{product_id: product_id, quantity: 1}])
      end

    case result do
      {:ok, cart} ->
        # Re-fetch cart to get expanded product data with images
        cart = fetch_cart_with_products(cart["id"]) || cart
        cart_count = calculate_cart_count(cart)
        {:noreply, assign(socket, cart: cart, cart_count: cart_count, cart_open: true)}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Could not add to cart")}
    end
  end

  def handle_event("toggle_cart", _, socket) do
    {:noreply, assign(socket, cart_open: !socket.assigns.cart_open)}
  end

  def handle_event("close_cart", _, socket) do
    {:noreply, assign(socket, cart_open: false)}
  end

  def handle_event("update_quantity", %{"item_id" => item_id, "quantity" => quantity}, socket) do
    cart_id = socket.assigns.cart["id"]
    quantity = String.to_integer(quantity)

    result =
      if quantity > 0 do
        Swell.update_cart_item(cart_id, item_id, quantity)
      else
        Swell.remove_from_cart(cart_id, item_id)
      end

    case result do
      {:ok, cart} ->
        # Re-fetch cart to get expanded product data with images
        cart = fetch_cart_with_products(cart["id"]) || cart
        cart_count = calculate_cart_count(cart)
        {:noreply, assign(socket, cart: cart, cart_count: cart_count)}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Could not update cart")}
    end
  end

  def handle_event("remove_item", %{"item_id" => item_id}, socket) do
    cart_id = socket.assigns.cart["id"]

    case Swell.remove_from_cart(cart_id, item_id) do
      {:ok, cart} ->
        # Re-fetch cart to get expanded product data with images
        cart = fetch_cart_with_products(cart["id"]) || cart
        cart_count = calculate_cart_count(cart)
        {:noreply, assign(socket, cart: cart, cart_count: cart_count)}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Could not remove item")}
    end
  end

  defp fetch_cart_with_products(cart_id) do
    case Swell.get_cart(cart_id) do
      {:ok, cart} -> cart
      _ -> nil
    end
  end

  defp calculate_cart_count(nil), do: 0
  defp calculate_cart_count(%{"items" => items}) when is_list(items) do
    Enum.reduce(items, 0, fn item, acc -> acc + (item["quantity"] || 1) end)
  end
  defp calculate_cart_count(_), do: 0

  # -------------------------------------------------------------------------
  # Atelier Theme Rendering
  # -------------------------------------------------------------------------

  defp render_atelier(assigns) do
    ~H"""
    <div style="min-height: 100vh; padding: 6rem 2rem 4rem;">
      <div style="max-width: 1200px; margin: 0 auto;">
        <div style="text-align: center; margin-bottom: 4rem;">
          <p class="atelier-heading-accent" style="font-size: 1rem; margin-bottom: 0.5rem; letter-spacing: 0.1em;">
            Original Artworks
          </p>
          <h1 class="atelier-heading" style="font-size: 3rem; margin-bottom: 1rem; color: var(--atelier-text-light);">
            Shop
          </h1>
          <div class="atelier-divider"></div>
          <p class="atelier-body" style="color: var(--atelier-text-muted); max-width: 600px; margin: 2rem auto 0;">
            Acquire original paintings directly from the artist's studio. Each work is unique, created with oil paint on canvas or panel.
          </p>
        </div>

        <%= if @loading do %>
          <div style="text-align: center; padding: 4rem;">
            <div style="width: 40px; height: 40px; border: 2px solid var(--atelier-ochre); border-top-color: transparent; border-radius: 50%; margin: 0 auto; animation: spin 1s linear infinite;"></div>
            <p class="atelier-body" style="color: var(--atelier-text-muted); margin-top: 1rem;">Loading artworks...</p>
          </div>
        <% end %>

        <%= if @error == :not_configured do %>
          <div style="text-align: center; padding: 4rem;">
            <div class="atelier-card" style="max-width: 500px; margin: 0 auto; padding: 2rem;">
              <p class="atelier-body" style="color: var(--atelier-ochre); margin-bottom: 1rem;">
                Shop Coming Soon
              </p>
              <p class="atelier-body" style="color: var(--atelier-text-muted); font-size: 0.875rem;">
                The online shop is being prepared. In the meantime, please <a href="/contact" style="color: var(--atelier-ochre);">contact the studio</a> for enquiries about acquiring work.
              </p>
            </div>
          </div>
        <% end %>

        <%= if @error && @error != :not_configured do %>
          <div style="text-align: center; padding: 4rem;">
            <p class="atelier-body" style="color: var(--atelier-vermillion);">Unable to load products. Please try again later.</p>
          </div>
        <% end %>

        <%= if !@loading && !@error && @products != [] do %>
          <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 2.5rem;">
            <%= for product <- @products do %>
              <div class="atelier-card" style="padding: 0; border-radius: 8px; overflow: hidden;">
                <div class="atelier-artwork-frame" style="aspect-ratio: 4/5;">
                  <%= if first_image = get_first_image(product) do %>
                    <img
                      src={first_image}
                      alt={product["name"]}
                      style="width: 100%; height: 100%; object-fit: cover; display: block;"
                    />
                  <% else %>
                    <div style="width: 100%; height: 100%; background: var(--atelier-slate); display: flex; align-items: center; justify-content: center;">
                      <span style="color: var(--atelier-text-muted);">No image</span>
                    </div>
                  <% end %>
                </div>
                <div style="padding: 1.5rem 1.75rem;">
                  <h3 class="atelier-heading" style="font-size: 1.25rem; color: var(--atelier-text-light); margin-bottom: 0.5rem;">
                    <%= product["name"] %>
                  </h3>
                  <%= if product["description"] do %>
                    <p class="atelier-body" style="font-size: 0.875rem; color: var(--atelier-text-muted); margin-bottom: 1rem; line-height: 1.5;">
                      <%= truncate_description(product["description"], 120) %>
                    </p>
                  <% end %>
                  <div style="display: flex; justify-content: space-between; align-items: center;">
                    <span class="atelier-heading" style="font-size: 1.125rem; color: var(--atelier-ochre);">
                      <%= format_price(product["price"], product["currency"]) %>
                    </span>
                    <button
                      phx-click="add_to_cart"
                      phx-value-product_id={product["id"]}
                      class="atelier-button atelier-button-solid"
                      style="padding: 0.5rem 1.25rem; font-size: 0.75rem;"
                    >
                      Add to Cart
                    </button>
                  </div>
                </div>
              </div>
            <% end %>
          </div>
        <% end %>

        <%= if !@loading && !@error && @products == [] do %>
          <div style="text-align: center; padding: 4rem;">
            <p class="atelier-body" style="color: var(--atelier-text-muted);">
              No artworks currently available. Check back soon or <a href="/contact" style="color: var(--atelier-ochre);">enquire about commissions</a>.
            </p>
          </div>
        <% end %>
      </div>
    </div>

    <!-- Cart Button (Fixed) -->
    <button
      phx-click="toggle_cart"
      style={"position: fixed; bottom: 2rem; right: 2rem; width: 56px; height: 56px; border-radius: 50%; background: var(--atelier-ochre); color: var(--atelier-midnight); border: none; cursor: pointer; display: flex; align-items: center; justify-content: center; box-shadow: 0 4px 12px rgba(0,0,0,0.3); z-index: 100; #{if @cart_count > 0, do: "", else: "opacity: 0.7;"}"}
    >
      <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <circle cx="9" cy="21" r="1"/>
        <circle cx="20" cy="21" r="1"/>
        <path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"/>
      </svg>
      <%= if @cart_count > 0 do %>
        <span style="position: absolute; top: -4px; right: -4px; background: var(--atelier-vermillion); color: white; font-size: 0.75rem; width: 20px; height: 20px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 600;">
          <%= @cart_count %>
        </span>
      <% end %>
    </button>

    <!-- Cart Sidebar -->
    <%= if @cart_open do %>
      <div
        phx-click="close_cart"
        style="position: fixed; inset: 0; background: rgba(0,0,0,0.5); z-index: 200;"
      >
      </div>
      <div style="position: fixed; top: 0; right: 0; bottom: 0; width: 400px; max-width: 100vw; background: var(--atelier-deep); z-index: 201; display: flex; flex-direction: column; box-shadow: -4px 0 20px rgba(0,0,0,0.3);">
        <div style="padding: 1.5rem; border-bottom: 1px solid var(--atelier-slate); display: flex; justify-content: space-between; align-items: center;">
          <h2 class="atelier-heading" style="font-size: 1.25rem; color: var(--atelier-text-light); margin: 0;">
            Your Cart
          </h2>
          <button phx-click="close_cart" style="background: none; border: none; color: var(--atelier-text-muted); cursor: pointer; padding: 0.5rem;">
            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M18 6L6 18M6 6l12 12"/>
            </svg>
          </button>
        </div>

        <div style="flex: 1; overflow-y: auto; padding: 1.5rem;">
          <%= if @cart && @cart["items"] && length(@cart["items"]) > 0 do %>
            <div style="display: flex; flex-direction: column; gap: 1.5rem;">
              <%= for item <- @cart["items"] do %>
                <div style="display: flex; gap: 1rem; padding-bottom: 1.5rem; border-bottom: 1px solid var(--atelier-slate);">
                  <div style="width: 80px; height: 80px; background: var(--atelier-slate); border-radius: 4px; overflow: hidden; flex-shrink: 0;">
                    <%= if item_image = get_item_image(item) do %>
                      <img src={item_image} alt={item["product"]["name"]} style="width: 100%; height: 100%; object-fit: cover;" />
                    <% end %>
                  </div>
                  <div style="flex: 1; min-width: 0;">
                    <h4 class="atelier-body" style="color: var(--atelier-text-light); font-weight: 500; margin-bottom: 0.25rem; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                      <%= item["product_name"] || item["product"]["name"] || "Product" %>
                    </h4>
                    <p style="color: var(--atelier-ochre); font-size: 0.875rem; margin-bottom: 0.5rem;">
                      <%= format_price(item["price"], @cart["currency"]) %>
                    </p>
                    <p style="color: var(--atelier-text-muted); font-size: 0.75rem; margin-bottom: 0.5rem;">
                      Original artwork · Unique piece
                    </p>
                    <button
                      phx-click="remove_item"
                      phx-value-item_id={item["id"]}
                      style="background: none; border: none; color: var(--atelier-text-muted); cursor: pointer; padding: 0; font-size: 0.75rem; text-decoration: underline;"
                    >
                      Remove
                    </button>
                  </div>
                </div>
              <% end %>
            </div>
          <% else %>
            <div style="text-align: center; padding: 3rem 1rem;">
              <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="var(--atelier-text-dim)" stroke-width="1" style="margin-bottom: 1rem;">
                <circle cx="9" cy="21" r="1"/>
                <circle cx="20" cy="21" r="1"/>
                <path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"/>
              </svg>
              <p class="atelier-body" style="color: var(--atelier-text-muted);">
                Your cart is empty
              </p>
            </div>
          <% end %>
        </div>

        <%= if @cart && @cart["items"] && length(@cart["items"]) > 0 do %>
          <div style="padding: 1.5rem; border-top: 1px solid var(--atelier-slate); background: var(--atelier-midnight);">
            <div style="display: flex; justify-content: space-between; margin-bottom: 1rem;">
              <span class="atelier-body" style="color: var(--atelier-text-muted);">Subtotal</span>
              <span class="atelier-heading" style="color: var(--atelier-text-light);">
                <%= format_price(@cart["sub_total"], @cart["currency"]) %>
              </span>
            </div>
            <a
              href={checkout_url(@cart)}
              target="_blank"
              rel="noopener noreferrer"
              class="atelier-button atelier-button-solid"
              style="display: block; text-align: center; width: 100%; padding: 1rem;"
            >
              Proceed to Checkout
            </a>
            <p class="atelier-body" style="color: var(--atelier-text-dim); font-size: 0.75rem; text-align: center; margin-top: 0.75rem;">
              Shipping calculated at checkout
            </p>
          </div>
        <% end %>
      </div>
    <% end %>

    <style>
      @keyframes spin {
        to { transform: rotate(360deg); }
      }
    </style>
    """
  end

  # -------------------------------------------------------------------------
  # Curator Theme Rendering
  # -------------------------------------------------------------------------

  defp render_curator(assigns) do
    ~H"""
    <div style="min-height: 100vh; padding: 6rem 2rem 4rem;">
      <div style="max-width: 1200px; margin: 0 auto;">
        <div style="text-align: center; margin-bottom: 4rem;">
          <h1 class="curator-heading" style="font-size: 2.5rem; margin-bottom: 1rem;">
            Shop
          </h1>
          <div class="curator-divider"></div>
          <p class="curator-body" style="color: var(--curator-text-muted); max-width: 600px; margin: 2rem auto 0;">
            Acquire original paintings directly from the artist's studio.
          </p>
        </div>

        <%= if @loading do %>
          <div style="text-align: center; padding: 4rem;">
            <p class="curator-body" style="color: var(--curator-text-muted);">Loading...</p>
          </div>
        <% end %>

        <%= if @error == :not_configured do %>
          <div style="text-align: center; padding: 4rem;">
            <p class="curator-body" style="color: var(--curator-text-muted);">
              Shop coming soon. <a href="/contact" style="color: var(--curator-sage);">Contact for enquiries</a>.
            </p>
          </div>
        <% end %>

        <%= if !@loading && !@error && @products != [] do %>
          <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 2rem;">
            <%= for product <- @products do %>
              <div class="curator-artwork-card">
                <div style="aspect-ratio: 4/5; margin-bottom: 1rem;">
                  <%= if first_image = get_first_image(product) do %>
                    <img src={first_image} alt={product["name"]} style="width: 100%; height: 100%; object-fit: cover;" />
                  <% end %>
                </div>
                <h3 class="curator-heading" style="font-size: 1.125rem; margin-bottom: 0.5rem;">
                  <%= product["name"] %>
                </h3>
                <div style="display: flex; justify-content: space-between; align-items: center;">
                  <span style="color: var(--curator-sage);"><%= format_price(product["price"], product["currency"]) %></span>
                  <button phx-click="add_to_cart" phx-value-product_id={product["id"]} class="curator-button" style="padding: 0.5rem 1rem; font-size: 0.75rem;">
                    Add to Cart
                  </button>
                </div>
              </div>
            <% end %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  # -------------------------------------------------------------------------
  # Cottage Theme Rendering
  # -------------------------------------------------------------------------

  defp render_cottage(assigns) do
    render_default(assigns)
  end

  # -------------------------------------------------------------------------
  # Gallery Theme Rendering
  # -------------------------------------------------------------------------

  defp render_gallery(assigns) do
    render_default(assigns)
  end

  # -------------------------------------------------------------------------
  # Default Theme Rendering
  # -------------------------------------------------------------------------

  defp render_default(assigns) do
    ~H"""
    <div style="min-height: 100vh; padding: 6rem 2rem 4rem; background: #fafafa;">
      <div style="max-width: 1200px; margin: 0 auto;">
        <div style="text-align: center; margin-bottom: 4rem;">
          <h1 style="font-size: 2.5rem; font-weight: 300; color: #333; margin-bottom: 1rem;">
            Shop
          </h1>
          <p style="color: #666; max-width: 600px; margin: 0 auto;">
            Acquire original paintings directly from the artist's studio.
          </p>
        </div>

        <%= if @loading do %>
          <div style="text-align: center; padding: 4rem;">
            <p style="color: #666;">Loading...</p>
          </div>
        <% end %>

        <%= if @error == :not_configured do %>
          <div style="text-align: center; padding: 4rem;">
            <p style="color: #666;">
              Shop coming soon. <a href="/contact" style="color: #4a90a4;">Contact for enquiries</a>.
            </p>
          </div>
        <% end %>

        <%= if !@loading && !@error && @products != [] do %>
          <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 2rem;">
            <%= for product <- @products do %>
              <div style="background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.08);">
                <div style="aspect-ratio: 4/5;">
                  <%= if first_image = get_first_image(product) do %>
                    <img src={first_image} alt={product["name"]} style="width: 100%; height: 100%; object-fit: cover;" />
                  <% end %>
                </div>
                <div style="padding: 1.5rem;">
                  <h3 style="font-size: 1.125rem; font-weight: 500; color: #333; margin-bottom: 0.5rem;">
                    <%= product["name"] %>
                  </h3>
                  <div style="display: flex; justify-content: space-between; align-items: center;">
                    <span style="color: #4a90a4; font-weight: 500;"><%= format_price(product["price"], product["currency"]) %></span>
                    <button phx-click="add_to_cart" phx-value-product_id={product["id"]} style="background: #333; color: white; border: none; padding: 0.5rem 1rem; border-radius: 4px; cursor: pointer; font-size: 0.875rem;">
                      Add to Cart
                    </button>
                  </div>
                </div>
              </div>
            <% end %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  # -------------------------------------------------------------------------
  # Helpers
  # -------------------------------------------------------------------------

  defp get_first_image(%{"images" => [%{"file" => %{"url" => url}} | _]}), do: url
  defp get_first_image(%{"images" => [%{"url" => url} | _]}), do: url
  defp get_first_image(_), do: nil

  defp get_item_image(%{"product" => %{"images" => images}}) when is_list(images) and images != [] do
    case hd(images) do
      %{"file" => %{"url" => url}} -> url
      %{"url" => url} -> url
      _ -> nil
    end
  end
  defp get_item_image(_), do: nil

  defp format_price(nil, _), do: "Price on request"
  defp format_price(price, currency) when is_number(price) do
    currency = currency || "GBP"
    symbol = currency_symbol(currency)
    "#{symbol}#{:erlang.float_to_binary(price / 1.0, decimals: 0)}"
  end
  defp format_price(_, _), do: "Price on request"

  defp currency_symbol("GBP"), do: "£"
  defp currency_symbol("USD"), do: "$"
  defp currency_symbol("EUR"), do: "€"
  defp currency_symbol(_), do: "£"

  defp truncate_description(nil, _), do: ""
  defp truncate_description(text, max_length) do
    text = HtmlSanitizeEx.strip_tags(text)
    if String.length(text) > max_length do
      String.slice(text, 0, max_length) <> "..."
    else
      text
    end
  end

  defp checkout_url(%{"checkout_url" => url}) when is_binary(url), do: url
  defp checkout_url(%{"id" => cart_id}), do: "https://olivia.swell.store/checkout/#{cart_id}"
  defp checkout_url(_), do: "/shop"

  end
