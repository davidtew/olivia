defmodule Olivia.Media do
  @moduledoc """
  The Media context - manages uploaded images and files.
  """

  import Ecto.Query, warn: false
  alias Olivia.Repo
  alias Olivia.Media.MediaFile

  @doc """
  Returns the list of media files.
  """
  def list_media(opts \\ []) do
    query = from m in MediaFile, order_by: [desc: m.inserted_at]

    query
    |> maybe_filter_by_tags(opts[:tags])
    |> maybe_preload(opts[:preload])
    |> Repo.all()
  end

  @doc """
  Gets a single media file.
  """
  def get_media!(id), do: Repo.get!(MediaFile, id)

  @doc """
  Creates a media file record.
  """
  def create_media(attrs \\ %{}) do
    %MediaFile{}
    |> MediaFile.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a media file record.
  """
  def update_media(%MediaFile{} = media, attrs) do
    media
    |> MediaFile.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a media file record and the physical file.
  """
  def delete_media(%MediaFile{} = media) do
    # Delete physical file
    Olivia.Uploads.delete_by_url(media.url)

    # Delete database record
    Repo.delete(media)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking media file changes.
  """
  def change_media(%MediaFile{} = media, attrs \\ %{}) do
    MediaFile.changeset(media, attrs)
  end

  @doc """
  Searches media by tags or filename.
  """
  def search_media(query_string) do
    search_term = "%#{query_string}%"

    from(m in MediaFile,
      where:
        ilike(m.filename, ^search_term) or
          ilike(m.alt_text, ^search_term) or
          ilike(m.caption, ^search_term) or
          fragment("? && ARRAY[?]::varchar[]", m.tags, ^query_string),
      order_by: [desc: m.inserted_at]
    )
    |> Repo.all()
  end

  @doc """
  Returns media statistics.
  """
  def get_stats do
    query = from m in MediaFile,
      select: %{
        total_count: count(m.id),
        total_size: sum(m.file_size)
      }

    Repo.one(query) || %{total_count: 0, total_size: 0}
  end

  defp maybe_filter_by_tags(query, nil), do: query
  defp maybe_filter_by_tags(query, []), do: query
  defp maybe_filter_by_tags(query, tags) when is_list(tags) do
    from m in query,
      where: fragment("? && ?", m.tags, ^tags)
  end

  defp maybe_preload(query, nil), do: query
  defp maybe_preload(query, preloads) do
    from m in query, preload: ^preloads
  end

  # Quarantine workflow functions

  @doc """
  Creates a media file in quarantine with minimal metadata.
  This is the entry point for all uploads.
  """
  def create_quarantine_media(attrs \\ %{}) do
    attrs
    |> Map.put("status", "quarantine")
    |> then(&create_media/1)
    |> tap(&maybe_broadcast_upload/1)
  end

  @doc """
  Creates a media file with classification, auto-approving if metadata is complete.
  Used when context is known (e.g., artwork upload).
  """
  def create_classified_media(attrs \\ %{}) do
    create_media(attrs)
    |> tap(&maybe_broadcast_upload/1)
  end

  defp maybe_broadcast_upload({:ok, media}) do
    context = Map.get(media.metadata || %{}, "upload_context", "unknown")
    Olivia.Media.Events.broadcast_media_uploaded(media, %{source: context})
  end

  defp maybe_broadcast_upload({:error, _}), do: :ok

  @doc """
  Returns media files in quarantine.
  """
  def list_quarantine_media do
    from(m in MediaFile,
      where: m.status == "quarantine",
      order_by: [desc: m.inserted_at]
    )
    |> Repo.all()
  end

  @doc """
  Returns approved media files.
  """
  def list_approved_media do
    from(m in MediaFile,
      where: m.status == "approved",
      order_by: [desc: m.inserted_at]
    )
    |> Repo.all()
  end

  @doc """
  Approves a media file, moving it out of quarantine.
  """
  def approve_media(%MediaFile{} = media) do
    update_media(media, %{status: "approved"})
  end

  @doc """
  Returns quarantine statistics.
  """
  def get_quarantine_stats do
    query = from m in MediaFile,
      group_by: m.status,
      select: {m.status, count(m.id)}

    Repo.all(query)
    |> Enum.into(%{})
  end

  # AI Vision Analysis functions

  @doc """
  Triggers AI vision analysis on a media file.
  Uses the configured vision analyzer (e.g., Gemini, Claude, GPT-4V).
  """
  def analyze_media(media_id) when is_binary(media_id) or is_integer(media_id) do
    media = get_media!(media_id)
    analyze_media(media)
  end

  def analyze_media(%MediaFile{} = media) do
    analyzer = get_configured_analyzer()

    case analyzer.analyze(media) do
      {:ok, analysis_result} ->
        # Update media with analysis results
        update_attrs = %{
          "asset_type" => analysis_result.asset_type,
          "asset_role" => analysis_result.asset_role,
          "alt_text" => analysis_result.alt_text,
          "tags" => analysis_result.tags,
          "metadata" =>
            Map.merge(media.metadata || %{}, analysis_result.metadata)
        }

        case update_media(media, update_attrs) do
          {:ok, updated_media} ->
            # Broadcast analysis complete event
            Olivia.Media.Events.broadcast_media_analyzed(updated_media, analysis_result)
            {:ok, updated_media, analysis_result}

          {:error, changeset} ->
            {:error, {:update_failed, changeset}}
        end

      {:error, :not_configured} ->
        {:error, :analyzer_not_configured}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Analyzes all media in quarantine that require analysis.
  Returns a list of results.
  """
  def analyze_quarantine_batch(limit \\ 10) do
    quarantine_media =
      from(m in MediaFile,
        where: m.status == "quarantine" and is_nil(m.asset_type),
        limit: ^limit,
        order_by: [asc: m.inserted_at]
      )
      |> Repo.all()

    Enum.map(quarantine_media, &analyze_media/1)
  end

  # Returns the configured vision analyzer module
  defp get_configured_analyzer do
    # Check which analyzer is configured
    # Using Claude for demonstration until Gemini API key is configured
    Application.get_env(:olivia, :vision_analyzer, Olivia.Media.VisionAnalyzers.Claude)
  end
end
