defmodule Olivia.Uploads do
  @moduledoc """
  Handles file uploads to S3/Tigris storage or local filesystem (for development).

  Set UPLOADS_STORAGE=local in your environment to use local file storage instead of S3.
  Images will be saved to priv/static/uploads/ and served at /uploads/
  """

  alias ExAws.S3

  @storage_type System.get_env("UPLOADS_STORAGE") ||
    if Mix.env() == :dev, do: "local", else: "s3"
  @local_upload_dir "priv/static/uploads"

  defp bucket do
    Application.get_env(:olivia, :uploads)[:bucket] || "olivia-gallery"
  end

  defp public_url do
    Application.get_env(:olivia, :uploads)[:public_url] ||
      "https://fly.storage.tigris.dev/olivia-gallery"
  end

  @spec upload_file(binary(), binary()) :: {:error, any()} | {:ok, nonempty_binary()}
  @doc """
  Uploads a file and returns the public URL.
  Uses local filesystem or S3 depending on UPLOADS_STORAGE environment variable.

  ## Parameters
    - file_path: Path to the local file
    - key: S3 object key (or local path)
    - content_type: MIME type of the file

  ## Returns
    - {:ok, url} on success
    - {:error, reason} on failure
  """
  def upload_file(file_path, key, content_type \\ "image/jpeg") do
    case @storage_type do
      "local" -> upload_file_local(file_path, key)
      _ -> upload_file_s3(file_path, key, content_type)
    end
  end

  defp upload_file_local(file_path, key) do
    dest_path = Path.join(@local_upload_dir, key)
    dest_dir = Path.dirname(dest_path)

    with :ok <- File.mkdir_p(dest_dir),
         {:ok, _} <- File.copy(file_path, dest_path) do
      {:ok, "/uploads/#{key}"}
    else
      error -> {:error, error}
    end
  end

  defp upload_file_s3(file_path, key, content_type) do
    file_path
    |> S3.Upload.stream_file()
    |> S3.upload(bucket(), key,
      acl: :public_read,
      content_type: content_type
    )
    |> ExAws.request()
    |> case do
      {:ok, _response} ->
        {:ok, build_public_url(key)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Uploads binary data to S3 and returns the public URL.

  ## Parameters
    - binary: File data as binary
    - key: S3 object key (path in bucket)
    - content_type: MIME type of the file

  ## Returns
    - {:ok, url} on success
    - {:error, reason} on failure
  """
  def upload_binary(binary, key, content_type \\ "image/jpeg") do
    binary
    |> S3.put_object(bucket(), key,
      acl: :public_read,
      content_type: content_type
    )
    |> ExAws.request()
    |> case do
      {:ok, _response} ->
        {:ok, build_public_url(key)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Deletes a file from storage (S3 or local filesystem).

  ## Parameters
    - key: S3 object key or local path

  ## Returns
    - :ok on success
    - {:error, reason} on failure
  """
  def delete_file(key) do
    case @storage_type do
      "local" -> delete_file_local(key)
      _ -> delete_file_s3(key)
    end
  end

  defp delete_file_local(key) do
    path = Path.join(@local_upload_dir, key)
    case File.rm(path) do
      :ok -> :ok
      {:error, :enoent} -> :ok  # File doesn't exist, that's fine
      error -> error
    end
  end

  defp delete_file_s3(key) do
    key
    |> S3.delete_object(bucket())
    |> ExAws.request()
    |> case do
      {:ok, _response} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Deletes a file by its public URL.
  Extracts the key from the URL and deletes it.
  """
  def delete_by_url(url) when is_binary(url) do
    case extract_key_from_url(url) do
      {:ok, key} -> delete_file(key)
      :error -> {:error, :invalid_url}
    end
  end

  def delete_by_url(nil), do: :ok

  @doc """
  Generates a unique filename with timestamp and random suffix.
  """
  def generate_filename(original_filename) do
    timestamp = DateTime.utc_now() |> DateTime.to_unix()
    random = :crypto.strong_rand_bytes(8) |> Base.encode16(case: :lower)
    extension = Path.extname(original_filename)
    "#{timestamp}_#{random}#{extension}"
  end

  @doc """
  Generates an S3 key for artwork images.
  Format: artworks/{series_slug}/{filename}
  """
  def artwork_key(series_slug, filename) do
    "artworks/#{series_slug}/#{filename}"
  end

  @doc """
  Generates an S3 key for series cover images.
  Format: series/{series_slug}/{filename}
  """
  def series_key(series_slug, filename) do
    "series/#{series_slug}/#{filename}"
  end

  @doc """
  Alias for upload_binary/3 to match the function calls in LiveViews.
  """
  def upload_from_binary(binary, key, content_type \\ "image/jpeg") do
    upload_binary(binary, key, content_type)
  end

  defp build_public_url(key) do
    "#{public_url()}/#{key}"
  end

  defp extract_key_from_url(url) do
    cond do
      # Local file path (starts with /uploads/)
      String.starts_with?(url, "/uploads/") ->
        key = String.replace_prefix(url, "/uploads/", "")
        {:ok, key}

      # S3 URL
      String.starts_with?(url, public_url() <> "/") ->
        key = String.replace_prefix(url, public_url() <> "/", "")
        {:ok, key}

      true ->
        :error
    end
  end

end
