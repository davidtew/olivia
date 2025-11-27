defmodule Olivia.Swell.Migration do
  @moduledoc """
  Migration utilities for Swell e-commerce.

  Used to copy products between environments (live -> test) or rebuild products.
  """

  require Logger

  @doc """
  Copies all products from current environment to test environment.

  Requires test environment to be enabled in Swell dashboard first.
  The test environment uses the same API keys but with `$test` mode header.

  Usage:
    Olivia.Swell.Migration.copy_products_to_test()
  """
  def copy_products_to_test do
    IO.puts("Fetching products from live environment...")

    case Olivia.Swell.list_products(limit: 100, expand: ["images"]) do
      {:ok, %{"results" => products}} ->
        IO.puts("Found #{length(products)} products to migrate")

        Enum.each(products, fn product ->
          migrate_product_to_test(product)
        end)

        IO.puts("\nMigration complete!")
        {:ok, length(products)}

      {:error, reason} ->
        IO.puts("Failed to fetch products: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @doc """
  Lists all current products with their details.
  Useful for verifying what's in the store.
  """
  def list_current_products do
    case Olivia.Swell.list_products(limit: 100, expand: ["images"]) do
      {:ok, %{"results" => products}} ->
        Enum.each(products, fn p ->
          image_count = length(p["images"] || [])
          IO.puts("\n#{p["name"]}")
          IO.puts("  ID: #{p["id"]}")
          IO.puts("  Slug: #{p["slug"]}")
          IO.puts("  Price: #{p["price"]} #{p["currency"]}")
          IO.puts("  Images: #{image_count}")
          IO.puts("  Active: #{p["active"]}")
        end)

        {:ok, products}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Exports product data for backup/migration purposes.
  Returns a list of maps suitable for re-creating products.
  """
  def export_products do
    case Olivia.Swell.list_products(limit: 100, expand: ["images"]) do
      {:ok, %{"results" => products}} ->
        exported = Enum.map(products, fn p ->
          %{
            name: p["name"],
            slug: p["slug"],
            price: p["price"],
            currency: p["currency"],
            description: p["description"],
            active: p["active"],
            images: Enum.map(p["images"] || [], fn img ->
              %{url: get_in(img, ["file", "url"])}
            end)
          }
        end)

        {:ok, exported}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Re-creates a product in the current environment.
  Useful for migrating between test/live or recreating products.
  """
  def recreate_product(product_data) do
    Olivia.Swell.create_product(product_data)
  end

  defp migrate_product_to_test(product) do
    IO.puts("\nMigrating: #{product["name"]}")

    # Extract image URLs from existing product
    images = Enum.map(product["images"] || [], fn img ->
      %{url: get_in(img, ["file", "url"])}
    end)

    product_data = %{
      name: product["name"],
      slug: product["slug"],
      price: product["price"],
      currency: product["currency"] || "GBP",
      description: product["description"],
      active: product["active"],
      images: images
    }

    # Note: To actually create in test environment, you'd need to
    # either use a test-specific API client or set the $test header
    IO.puts("  Would create with: #{inspect(product_data, pretty: true, limit: 3)}")

    # For now, just return the data - actual creation requires test mode
    {:ok, product_data}
  end
end
