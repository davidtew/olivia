defmodule OliviaWeb.AssetHelpers do
  @moduledoc """
  Helpers for resolving asset URLs based on environment.
  In production, prepends S3 URL to local paths.
  """

  @doc """
  Resolves an asset URL to the appropriate location.
  - In development: returns path as-is (served from priv/static)
  - In production: prepends S3 public URL
  """
  def resolve_asset_url(nil), do: nil
  def resolve_asset_url(""), do: ""

  def resolve_asset_url(url) when is_binary(url) do
    # If it's already a full URL, return as-is
    if String.starts_with?(url, "http") do
      url
    else
      # In production, prepend S3 URL
      if production?() do
        s3_public_url() <> url
      else
        url
      end
    end
  end

  defp production? do
    System.get_env("PHX_HOST") != nil
  end

  defp s3_public_url do
    Application.get_env(:olivia, :uploads)[:public_url] ||
      "https://fly.storage.tigris.dev/falling-sky-1523"
  end
end
