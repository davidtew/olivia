defmodule Olivia.Media.ProcessingPipeline do
  @moduledoc """
  Orchestrates the complete media processing pipeline for uploads.

  Pipeline steps:
  1. Process image (thumbnails, metadata, phash)
  2. Upload thumbnails to storage
  3. Update media record with processed data
  4. Check for duplicates
  5. Record upload in audit trail
  """

  require Logger

  alias Olivia.Media
  alias Olivia.Media.{ImageProcessor, DuplicateDetector, ReviewNotes}
  alias Olivia.Uploads

  @doc """
  Processes a newly uploaded media file through the complete pipeline.

  Takes a media file ID and the path to the uploaded file.
  Returns {:ok, updated_media} or {:error, reason}.
  """
  def process_upload(media_id, file_path, user_id \\ nil) do
    media = Media.get_media!(media_id)

    Logger.info("ProcessingPipeline: Starting processing for media #{media_id}")

    with {:ok, processed} <- ImageProcessor.process_image(file_path),
         {:ok, thumb_url} <- upload_thumbnail(processed.thumbnails.thumb_path, media),
         {:ok, medium_url} <- upload_medium(processed.thumbnails.medium_path, media),
         {:ok, updated_media} <- update_media_with_processed_data(media, processed, thumb_url, medium_url),
         {:ok, dup_count} <- DuplicateDetector.check_and_record_duplicates(updated_media),
         {:ok, _note} <- record_upload(updated_media, user_id) do
      # Clean up temp files
      cleanup_temp_files(processed.thumbnails)

      Logger.info("ProcessingPipeline: Completed processing for media #{media_id} (#{dup_count} duplicates found)")

      {:ok, updated_media}
    else
      {:error, reason} = error ->
        Logger.error("ProcessingPipeline: Failed for media #{media_id}: #{inspect(reason)}")
        error
    end
  end

  @doc """
  Processes an existing media file that hasn't been processed yet.
  Downloads the file, processes it, and updates the record.
  """
  def process_existing(media_id) do
    media = Media.get_media!(media_id)

    # Skip if already processed
    if media.thumb_url do
      Logger.info("ProcessingPipeline: Media #{media_id} already processed, skipping")
      {:ok, media}
    else
      # Download the file to a temp location
      case download_to_temp(media.url) do
        {:ok, temp_path} ->
          result = process_upload(media_id, temp_path, nil)
          File.rm(temp_path)
          result

        {:error, reason} ->
          Logger.error("ProcessingPipeline: Could not download media #{media_id}: #{inspect(reason)}")
          {:error, reason}
      end
    end
  end

  @doc """
  Processes all unprocessed media files in batches.
  """
  def process_all_pending(batch_size \\ 10) do
    pending = Media.list_unprocessed_media(batch_size)

    Logger.info("ProcessingPipeline: Processing #{length(pending)} unprocessed media files")

    results =
      Enum.map(pending, fn media ->
        case process_existing(media.id) do
          {:ok, _} -> :ok
          {:error, _} -> :error
        end
      end)

    success_count = Enum.count(results, &(&1 == :ok))
    Logger.info("ProcessingPipeline: Processed #{success_count}/#{length(pending)} successfully")

    {:ok, success_count}
  end

  # Private functions

  defp upload_thumbnail(thumb_path, media) do
    key = generate_thumb_key(media, "thumb")
    content_type = media.content_type || "image/jpeg"

    case Uploads.upload_file(thumb_path, key, content_type) do
      {:ok, url} -> {:ok, url}
      error -> error
    end
  end

  defp upload_medium(medium_path, media) do
    key = generate_thumb_key(media, "medium")
    content_type = media.content_type || "image/jpeg"

    case Uploads.upload_file(medium_path, key, content_type) do
      {:ok, url} -> {:ok, url}
      error -> error
    end
  end

  defp generate_thumb_key(media, size) do
    # Extract base filename
    ext = Path.extname(media.filename)
    base = Path.basename(media.filename, ext)

    "media/#{base}_#{size}_#{media.id}#{ext}"
  end

  defp update_media_with_processed_data(media, processed, thumb_url, medium_url) do
    attrs = %{
      width: processed.width,
      height: processed.height,
      metadata: Map.merge(media.metadata || %{}, processed.metadata),
      phash: processed.phash,
      thumb_url: thumb_url,
      medium_url: medium_url
    }

    Media.update_media(media, attrs)
  end

  defp record_upload(media, nil), do: ReviewNotes.record_upload(media.id, nil)
  defp record_upload(media, user_id), do: ReviewNotes.record_upload(media.id, user_id)

  defp cleanup_temp_files(%{thumb_path: thumb_path, medium_path: medium_path}) do
    File.rm(thumb_path)
    File.rm(medium_path)
  end

  defp cleanup_temp_files(_), do: :ok

  defp download_to_temp(url) do
    temp_path = Path.join(System.tmp_dir!(), "media_#{:rand.uniform(1_000_000)}")

    cond do
      # Local file
      String.starts_with?(url, "/uploads/") ->
        local_path = Path.join("priv/static", url)

        if File.exists?(local_path) do
          File.cp(local_path, temp_path)
          {:ok, temp_path}
        else
          {:error, :file_not_found}
        end

      # Remote URL
      String.starts_with?(url, "http") ->
        case Req.get(url, into: File.stream!(temp_path)) do
          {:ok, %{status: 200}} -> {:ok, temp_path}
          {:ok, %{status: status}} -> {:error, {:http_error, status}}
          {:error, reason} -> {:error, reason}
        end

      true ->
        {:error, :invalid_url}
    end
  end
end
