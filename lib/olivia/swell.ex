defmodule Olivia.Swell do
  @moduledoc """
  Headless Swell e-commerce API client.

  Provides access to Swell's Backend API for products, carts, and checkout.
  Uses HTTP Basic authentication with store_id as username and secret_key as password.

  Configuration in runtime.exs:
    config :olivia, Olivia.Swell,
      store_id: System.get_env("SWELL_STORE_ID"),
      secret_key: System.get_env("SWELL_SECRET_KEY")
  """

  require Logger

  @base_url "https://api.swell.store"

  # -------------------------------------------------------------------
  # Configuration
  # -------------------------------------------------------------------

  @doc "Check if Swell is configured with credentials"
  def configured? do
    config = get_config()
    not is_nil(config[:store_id]) and config[:store_id] != "" and
      not is_nil(config[:secret_key]) and config[:secret_key] != ""
  end

  defp get_config do
    Application.get_env(:olivia, __MODULE__, [])
  end

  defp auth_header do
    config = get_config()
    credentials = Base.encode64("#{config[:store_id]}:#{config[:secret_key]}")
    {"authorization", "Basic #{credentials}"}
  end

  # -------------------------------------------------------------------
  # Products API
  # -------------------------------------------------------------------

  @doc """
  List products from Swell store.

  Options:
    - :active - filter by active status (default: true)
    - :limit - number of products (default: 25, max: 1000)
    - :page - page number for pagination
    - :sort - sort field (e.g., "name asc", "price desc")
    - :category - filter by category ID
    - :expand - expand related data (e.g., ["variants", "categories"])
  """
  def list_products(opts \\ []) do
    if not configured?() do
      {:error, :not_configured}
    else
      params = build_product_params(opts)
      get("/products", params)
    end
  end

  @doc "Get a single product by ID or slug"
  def get_product(id_or_slug, opts \\ []) do
    if not configured?() do
      {:error, :not_configured}
    else
      params = Keyword.take(opts, [:expand, :fields])
      get("/products/#{id_or_slug}", params)
    end
  end

  @doc """
  Create a new product in Swell.

  Required fields:
    - :name - Product name

  Optional fields:
    - :price - Price in currency units (e.g., 150.00)
    - :description - Product description (HTML supported)
    - :active - Whether product is visible (default: true)
    - :sku - Stock keeping unit
    - :images - List of image maps with :url or :file (base64)
    - :currency - Currency code (default: GBP)
  """
  def create_product(attrs) when is_map(attrs) do
    if not configured?() do
      {:error, :not_configured}
    else
      body = Map.take(attrs, [:name, :price, :description, :active, :sku, :images, :currency, :slug])
      body = Map.put_new(body, :active, true)
      post("/products", body)
    end
  end

  @doc "Delete a product by ID"
  def delete_product(product_id) do
    if not configured?() do
      {:error, :not_configured}
    else
      delete("/products/#{product_id}")
    end
  end

  defp build_product_params(opts) do
    params = []

    params = if Keyword.get(opts, :active, true), do: [{"where[active]", true} | params], else: params
    params = if limit = opts[:limit], do: [{"limit", limit} | params], else: [{"limit", 25} | params]
    params = if page = opts[:page], do: [{"page", page} | params], else: params
    params = if sort = opts[:sort], do: [{"sort", sort} | params], else: params
    params = if category = opts[:category], do: [{"categories", category} | params], else: params

    params = case opts[:expand] do
      nil -> params
      expands when is_list(expands) -> [{"expand", Enum.join(expands, ",")} | params]
      expand -> [{"expand", expand} | params]
    end

    params
  end

  # -------------------------------------------------------------------
  # Cart API
  # -------------------------------------------------------------------

  @doc """
  Create a new cart.

  Items should be a list of maps with at least :product_id.
  Optional item keys: :variant_id, :quantity, :options
  """
  def create_cart(items \\ [], opts \\ []) do
    if not configured?() do
      {:error, :not_configured}
    else
      body = %{items: Enum.map(items, &normalize_cart_item/1)}
      body = if billing = opts[:billing], do: Map.put(body, :billing, billing), else: body
      body = if shipping = opts[:shipping], do: Map.put(body, :shipping, shipping), else: body
      body = if coupon = opts[:coupon_code], do: Map.put(body, :coupon_code, coupon), else: body
      # Request expanded product data including images
      body = Map.put(body, "$expand", "items.product")

      post("/carts", body)
    end
  end

  @doc "Get cart by ID with expanded item products"
  def get_cart(cart_id) do
    if not configured?() do
      {:error, :not_configured}
    else
      # Expand items.product to get product images for cart display
      get("/carts/#{cart_id}", [{"expand", "items.product"}])
    end
  end

  @doc """
  Add item to cart.

  Item should have :product_id, optionally :variant_id, :quantity, :options
  """
  def add_to_cart(cart_id, item) do
    if not configured?() do
      {:error, :not_configured}
    else
      # Swell uses $push operator to add items
      # Using string keys because $expand needs to be a string key
      body = %{
        "items" => %{
          "$push" => [normalize_cart_item(item)]
        },
        "$expand" => "items.product"
      }
      put("/carts/#{cart_id}", body)
    end
  end

  @doc """
  Update cart item quantity.

  Uses item_id (not product_id) to identify the item in the cart.
  """
  def update_cart_item(cart_id, item_id, quantity) do
    if not configured?() do
      {:error, :not_configured}
    else
      body = %{
        items: %{
          "$update" => %{
            id: item_id,
            quantity: quantity
          }
        }
      }
      put("/carts/#{cart_id}", body)
    end
  end

  @doc "Remove item from cart by item_id"
  def remove_from_cart(cart_id, item_id) do
    if not configured?() do
      {:error, :not_configured}
    else
      # First get the current cart to filter out the item
      case get_cart(cart_id) do
        {:ok, cart} ->
          remaining_items =
            (cart["items"] || [])
            |> Enum.reject(fn item -> item["id"] == item_id end)
            |> Enum.map(fn item ->
              %{product_id: item["product_id"], quantity: item["quantity"] || 1}
            end)

          # Use $set to replace entire items array
          body = %{
            "items" => %{
              "$set" => remaining_items
            }
          }
          put("/carts/#{cart_id}", body)

        {:error, _} = error ->
          error
      end
    end
  end

  @doc "Update cart billing/shipping info"
  def update_cart(cart_id, updates) do
    if not configured?() do
      {:error, :not_configured}
    else
      put("/carts/#{cart_id}", updates)
    end
  end

  @doc "Delete a cart"
  def delete_cart(cart_id) do
    if not configured?() do
      {:error, :not_configured}
    else
      delete("/carts/#{cart_id}")
    end
  end

  defp normalize_cart_item(item) when is_map(item) do
    item
    |> Map.take([:product_id, :variant_id, :quantity, :options])
    |> Map.put_new(:quantity, 1)
  end

  # -------------------------------------------------------------------
  # Orders / Checkout API
  # -------------------------------------------------------------------

  @doc """
  Convert cart to order (checkout).

  The cart must have all required info: billing, shipping (if physical), payment.
  """
  def create_order_from_cart(cart_id) do
    if not configured?() do
      {:error, :not_configured}
    else
      post("/orders", %{cart_id: cart_id})
    end
  end

  @doc "Get order by ID"
  def get_order(order_id) do
    if not configured?() do
      {:error, :not_configured}
    else
      get("/orders/#{order_id}")
    end
  end

  @doc "List orders with optional filtering"
  def list_orders(opts \\ []) do
    if not configured?() do
      {:error, :not_configured}
    else
      params = []
      params = if limit = opts[:limit], do: [{"limit", limit} | params], else: params
      params = if page = opts[:page], do: [{"page", page} | params], else: params
      params = if account_id = opts[:account_id], do: [{"where[account_id]", account_id} | params], else: params

      get("/orders", params)
    end
  end

  # -------------------------------------------------------------------
  # Categories API
  # -------------------------------------------------------------------

  @doc "List product categories"
  def list_categories(opts \\ []) do
    if not configured?() do
      {:error, :not_configured}
    else
      params = []
      params = if limit = opts[:limit], do: [{"limit", limit} | params], else: params
      params = if active = Keyword.get(opts, :active, true), do: [{"where[active]", active} | params], else: params

      get("/categories", params)
    end
  end

  # -------------------------------------------------------------------
  # HTTP Helpers
  # -------------------------------------------------------------------

  defp get(path, params \\ []) do
    url = build_url(path, params)
    Logger.debug("Swell GET: #{url}")

    case Req.get(url, headers: [auth_header(), {"content-type", "application/json"}]) do
      {:ok, %{status: 200, body: body}} ->
        {:ok, body}

      {:ok, %{status: 404}} ->
        {:error, :not_found}

      {:ok, %{status: status, body: body}} ->
        Logger.error("Swell API error #{status}: #{inspect(body)}")
        {:error, {:api_error, status, body}}

      {:error, error} ->
        Logger.error("Swell API request failed: #{inspect(error)}")
        {:error, error}
    end
  end

  defp post(path, body) do
    url = build_url(path)
    Logger.debug("Swell POST: #{url}")

    case Req.post(url,
           json: body,
           headers: [auth_header(), {"content-type", "application/json"}]
         ) do
      {:ok, %{status: status, body: response_body}} when status in [200, 201] ->
        {:ok, response_body}

      {:ok, %{status: status, body: error_body}} ->
        Logger.error("Swell API error #{status}: #{inspect(error_body)}")
        {:error, {:api_error, status, error_body}}

      {:error, error} ->
        Logger.error("Swell API request failed: #{inspect(error)}")
        {:error, error}
    end
  end

  defp put(path, body) do
    url = build_url(path)
    Logger.debug("Swell PUT: #{url}")

    case Req.put(url,
           json: body,
           headers: [auth_header(), {"content-type", "application/json"}]
         ) do
      {:ok, %{status: 200, body: response_body}} ->
        {:ok, response_body}

      {:ok, %{status: 404}} ->
        {:error, :not_found}

      {:ok, %{status: status, body: error_body}} ->
        Logger.error("Swell API error #{status}: #{inspect(error_body)}")
        {:error, {:api_error, status, error_body}}

      {:error, error} ->
        Logger.error("Swell API request failed: #{inspect(error)}")
        {:error, error}
    end
  end

  defp delete(path) do
    url = build_url(path)
    Logger.debug("Swell DELETE: #{url}")

    case Req.delete(url, headers: [auth_header(), {"content-type", "application/json"}]) do
      {:ok, %{status: status}} when status in [200, 204] ->
        :ok

      {:ok, %{status: 404}} ->
        {:error, :not_found}

      {:ok, %{status: status, body: error_body}} ->
        Logger.error("Swell API error #{status}: #{inspect(error_body)}")
        {:error, {:api_error, status, error_body}}

      {:error, error} ->
        Logger.error("Swell API request failed: #{inspect(error)}")
        {:error, error}
    end
  end

  defp build_url(path, params \\ []) do
    query = if params == [], do: "", else: "?" <> URI.encode_query(params)
    "#{@base_url}#{path}#{query}"
  end
end
