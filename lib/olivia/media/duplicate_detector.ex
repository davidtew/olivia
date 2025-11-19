defmodule Olivia.Media.DuplicateDetector do
  @moduledoc """
  Detects duplicate or similar media files using perceptual hashing.
  """

  import Ecto.Query
  alias Olivia.Repo
  alias Olivia.Media.{MediaFile, Duplicate, ImageProcessor}

  require Logger

  @similarity_threshold 0.9

  @doc """
  Finds potential duplicates for a media file.
  Returns a list of {media_file, similarity_score} tuples.
  """
  def find_duplicates(%MediaFile{phash: nil}), do: []

  def find_duplicates(%MediaFile{id: id, phash: phash}) do
    # Get all media files with phashes (excluding self)
    candidates =
      from(m in MediaFile,
        where: m.id != ^id and not is_nil(m.phash),
        select: {m.id, m.phash, m.filename}
      )
      |> Repo.all()

    # Calculate similarity for each candidate
    candidates
    |> Enum.map(fn {candidate_id, candidate_hash, filename} ->
      similarity = ImageProcessor.hash_similarity(phash, candidate_hash)
      {candidate_id, filename, similarity}
    end)
    |> Enum.filter(fn {_, _, similarity} -> similarity >= @similarity_threshold end)
    |> Enum.sort_by(fn {_, _, similarity} -> similarity end, :desc)
  end

  @doc """
  Checks a new media file for duplicates and records them.
  Returns {:ok, duplicates_found} or {:error, reason}.
  """
  def check_and_record_duplicates(%MediaFile{} = media) do
    duplicates = find_duplicates(media)

    recorded =
      Enum.map(duplicates, fn {target_id, _filename, similarity} ->
        attrs = %{
          source_media_id: media.id,
          target_media_id: target_id,
          similarity_score: similarity,
          detection_method: "phash"
        }

        case create_duplicate(attrs) do
          {:ok, dup} -> dup
          {:error, _} -> nil
        end
      end)
      |> Enum.filter(&(&1 != nil))

    {:ok, length(recorded)}
  end

  @doc """
  Gets all recorded duplicates for a media file.
  """
  def get_duplicates(media_id) do
    from(d in Duplicate,
      where: d.source_media_id == ^media_id or d.target_media_id == ^media_id,
      preload: [:source_media, :target_media],
      order_by: [desc: d.similarity_score]
    )
    |> Repo.all()
  end

  @doc """
  Returns true if the media file has any duplicates above threshold.
  """
  def has_duplicates?(%MediaFile{} = media) do
    case find_duplicates(media) do
      [] -> false
      _ -> true
    end
  end

  @doc """
  Scans all media files and updates duplicate records.
  Useful for batch processing existing media.
  """
  def scan_all_media do
    media_files =
      from(m in MediaFile,
        where: not is_nil(m.phash),
        order_by: [asc: m.inserted_at]
      )
      |> Repo.all()

    Logger.info("DuplicateDetector: Scanning #{length(media_files)} media files")

    results =
      Enum.map(media_files, fn media ->
        case check_and_record_duplicates(media) do
          {:ok, count} -> count
          _ -> 0
        end
      end)

    total = Enum.sum(results)
    Logger.info("DuplicateDetector: Found #{total} duplicate relationships")
    {:ok, total}
  end

  defp create_duplicate(attrs) do
    %Duplicate{}
    |> Duplicate.changeset(attrs)
    |> Repo.insert(on_conflict: :nothing)
  end
end
