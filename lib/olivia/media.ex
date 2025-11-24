defmodule Olivia.Media do
  @moduledoc """
  The Media context - manages uploaded images and files.
  """

  import Ecto.Query, warn: false
  alias Olivia.Repo
  alias Olivia.Media.{MediaFile, Analysis, Events}

  @doc """
  Returns the list of media files.

  Options:
    - :status - Filter by status (quarantine, approved, archived)
    - :tags - Filter by tags
    - :order_by - Tuple of {direction, field}, e.g. {:desc, :inserted_at}
    - :limit - Limit number of results
    - :offset - Offset for pagination
    - :preload - Associations to preload
  """
  def list_media(opts \\ []) do
    query = from m in MediaFile

    query
    |> maybe_filter_by_status(opts[:status])
    |> maybe_filter_by_tags(opts[:tags])
    |> maybe_filter_by_analysis(opts[:analysis_filter])
    |> apply_ordering(opts[:order_by])
    |> apply_pagination(opts[:limit], opts[:offset])
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

  defp maybe_filter_by_status(query, nil), do: query
  defp maybe_filter_by_status(query, status) when is_binary(status) do
    from m in query, where: m.status == ^status
  end

  defp maybe_filter_by_tags(query, nil), do: query
  defp maybe_filter_by_tags(query, []), do: query
  defp maybe_filter_by_tags(query, tags) when is_list(tags) do
    from m in query,
      where: fragment("? && ?", m.tags, ^tags)
  end

  defp maybe_filter_by_analysis(query, nil), do: query
  defp maybe_filter_by_analysis(query, "all"), do: query
  defp maybe_filter_by_analysis(query, "analysed") do
    from m in query,
      join: a in assoc(m, :analyses),
      distinct: m.id
  end
  defp maybe_filter_by_analysis(query, "not_analysed") do
    from m in query,
      left_join: a in assoc(m, :analyses),
      where: is_nil(a.id)
  end

  defp apply_ordering(query, nil), do: from(m in query, order_by: [desc: m.inserted_at])
  defp apply_ordering(query, {direction, field}) do
    from m in query, order_by: [{^direction, ^field}]
  end

  defp apply_pagination(query, nil, _offset), do: query
  defp apply_pagination(query, limit, nil), do: from(m in query, limit: ^limit)
  defp apply_pagination(query, limit, offset) do
    from m in query, limit: ^limit, offset: ^offset
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

  defp maybe_broadcast_upload({:ok, media}) do
    context = Map.get(media.metadata || %{}, "upload_context", "unknown")
    Events.broadcast_media_uploaded(media, %{source: context})
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
  Returns media files that haven't been processed yet (no thumbnail).
  """
  def list_unprocessed_media(limit \\ 50) do
    from(m in MediaFile,
      where: is_nil(m.thumb_url),
      order_by: [asc: m.inserted_at],
      limit: ^limit
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

  @doc """
  Creates a new analysis iteration for a media file.
  """
  def create_analysis(attrs \\ %{}) do
    %Analysis{}
    |> Analysis.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Lists all analysis iterations for a media file, ordered by iteration number.
  """
  def list_analyses(media_file_id) do
    from(a in Analysis,
      where: a.media_file_id == ^media_file_id,
      order_by: [asc: a.iteration]
    )
    |> Repo.all()
  end

  @doc """
  Gets the latest analysis for a media file.
  """
  def get_latest_analysis(media_file_id) do
    from(a in Analysis,
      where: a.media_file_id == ^media_file_id,
      order_by: [desc: a.iteration],
      limit: 1
    )
    |> Repo.one()
  end

  @doc """
  Gets the next iteration number for a media file's analyses.
  """
  def get_next_iteration(media_file_id) do
    case get_latest_analysis(media_file_id) do
      nil -> 1
      analysis -> analysis.iteration + 1
    end
  end

  @doc """
  Analyzes media with user context and previous analyses for iterative refinement.

  This is the new preferred method for analysis that supports the iterative
  dialogue workflow between artist and AI.
  """
  def analyze_with_context(media_id, user_context \\ nil) do
    media = get_media!(media_id)
    previous_analyses = list_analyses(media_id)
    iteration = get_next_iteration(media_id)

    analyzer = get_configured_analyzer()

    case analyzer.analyze(media, user_context: user_context, previous_analyses: previous_analyses) do
      {:ok, analysis_result} ->
        attrs = %{
          media_file_id: media_id,
          iteration: iteration,
          user_context: user_context,
          llm_response: analysis_result.raw_response["full_response"] || %{},
          model_used: analysis_result.raw_response[:model] || "unknown"
        }

        case create_analysis(attrs) do
          {:ok, analysis} ->
            case update_media_from_analysis(media, analysis_result) do
              {:ok, updated_media} ->
                Events.broadcast_media_analyzed(updated_media, analysis_result)
                {:ok, {updated_media, analysis}}

              {:error, reason} ->
                {:error, reason}
            end

          {:error, reason} ->
            {:error, reason}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp update_media_from_analysis(media, analysis_result) do
    attrs = %{
      asset_type: analysis_result.asset_type,
      asset_role: analysis_result.asset_role,
      alt_text: analysis_result.alt_text || media.alt_text,
      tags: analysis_result.tags || media.tags,
      metadata: Map.merge(media.metadata || %{}, analysis_result.metadata || %{})
    }

    update_media(media, attrs)
  end

  # Returns the configured vision analyzer module
  defp get_configured_analyzer do
    # Use Tidewave Claude by default (no API key required)
    # Fall back to regular Claude if Tidewave not available
    Application.get_env(:olivia, :vision_analyzer, Olivia.Media.VisionAnalyzers.TidewaveClaude)
  end

  # Analysis search and aggregation functions

  @doc """
  Searches media by artistic movements/connections mentioned in analyses.
  Returns media files with analyses that reference the given artist or movement.
  """
  def search_by_artistic_connection(search_term) when is_binary(search_term) do
    search_pattern = "%#{String.downcase(search_term)}%"

    from(m in MediaFile,
      join: a in assoc(m, :analyses),
      where:
        fragment(
          "EXISTS (SELECT 1 FROM jsonb_array_elements(?) elem WHERE lower(elem->>'artist_or_movement') LIKE ? OR lower(elem::text) LIKE ?)",
          a.llm_response["artistic_connections"],
          ^search_pattern,
          ^search_pattern
        ),
      distinct: m.id,
      order_by: [desc: m.inserted_at],
      preload: [:analyses]
    )
    |> Repo.all()
  end

  @doc """
  Searches media by contextual frameworks mentioned in analyses.
  E.g., "Portfolio Centrepiece", "Exhibition", "Series"
  """
  def search_by_context(search_term) when is_binary(search_term) do
    search_pattern = "%#{String.downcase(search_term)}%"

    from(m in MediaFile,
      join: a in assoc(m, :analyses),
      where:
        fragment(
          "EXISTS (SELECT 1 FROM jsonb_array_elements(?) elem WHERE lower(elem->>'title') LIKE ? OR lower(elem->>'name') LIKE ?)",
          a.llm_response["contexts"],
          ^search_pattern,
          ^search_pattern
        ),
      distinct: m.id,
      order_by: [desc: m.inserted_at],
      preload: [:analyses]
    )
    |> Repo.all()
  end

  @doc """
  Finds all works identified as part of series.
  Returns a map grouped by series relationships.
  """
  def list_series_works do
    media_with_series_context =
      from(m in MediaFile,
        join: a in assoc(m, :analyses),
        where:
          fragment(
            "EXISTS (SELECT 1 FROM jsonb_array_elements(?) elem WHERE lower(elem->>'title') LIKE '%series%' OR lower(elem->>'title') LIKE '%companion%' OR lower(elem->>'title') LIKE '%diptych%' OR lower(elem->>'title') LIKE '%triptych%' OR lower(elem->>'name') LIKE '%series%')",
            a.llm_response["contexts"]
          ) or
            fragment("lower(?) LIKE '%series%' OR lower(?) LIKE '%set%' OR lower(?) LIKE '%suite%'",
              a.user_context,
              a.user_context,
              a.user_context
            ),
        distinct: m.id,
        order_by: [desc: m.inserted_at],
        preload: [:analyses]
      )
      |> Repo.all()

    # Group by detected series names
    media_with_series_context
    |> Enum.group_by(fn media ->
      # Try to extract series name from filename or context
      cond do
        String.contains?(media.filename, "SHIFTING") -> "SHIFTING Series"
        String.contains?(media.filename, "Marilyn") -> "Marilyn Series"
        String.contains?(media.filename, "IN MOTION") -> "IN MOTION Series"
        String.contains?(media.filename, "Mum") -> "Memorial Series"
        String.contains?(media.filename, "PXL_20250411") -> "Red Ground Florals"
        true -> extract_series_name_from_analyses(media)
      end
    end)
  end

  defp extract_series_name_from_analyses(media) do
    latest_analysis = List.first(media.analyses || [])

    if latest_analysis && latest_analysis.user_context do
      latest_analysis.user_context
      |> String.slice(0..50)
    else
      "Untitled Series"
    end
  end

  @doc """
  Finds works by thematic content (memorial, garden, travel, etc.)
  """
  def search_by_theme(theme) when is_binary(theme) do
    search_pattern = "%#{String.downcase(theme)}%"

    from(m in MediaFile,
      join: a in assoc(m, :analyses),
      where:
        fragment("lower(?->>'interpretation') LIKE ?", a.llm_response, ^search_pattern),
      distinct: m.id,
      order_by: [desc: m.inserted_at],
      preload: [:analyses]
    )
    |> Repo.all()
  end

  @doc """
  Gets provocations (critical questions) for a media file.
  Useful for studio practice and reflection.
  """
  def get_provocations(media_id) do
    latest_analysis = get_latest_analysis(media_id)

    if latest_analysis do
      provocations = latest_analysis.llm_response["provocations"] || []

      provocations
      |> Enum.map(fn prov ->
        case prov do
          %{"question" => q} -> q
          q when is_binary(q) -> q
          _ -> nil
        end
      end)
      |> Enum.filter(& &1)
    else
      []
    end
  end

  @doc """
  Generates aggregated statistics about all analyses.
  """
  def get_analysis_stats do
    analyses = Repo.all(from a in Analysis, preload: [:media_file])

    %{
      total_analyses: length(analyses),
      total_media_analyzed: analyses |> Enum.map(& &1.media_file_id) |> Enum.uniq() |> length(),
      top_movements: get_top_artistic_connections(5),
      top_contexts: get_top_contexts(5),
      themes: %{
        memorial: length(search_by_theme("memorial")),
        garden: length(search_by_theme("garden")),
        travel: length(search_by_theme("travel")),
        portrait: length(search_by_theme("portrait"))
      }
    }
  end

  @doc """
  Gets most frequently mentioned artistic connections across all analyses.
  """
  def get_top_artistic_connections(limit \\ 10) do
    query = """
    SELECT
      COALESCE(elem->>'artist_or_movement', elem::text) as connection,
      COUNT(*) as frequency
    FROM media_analyses,
         jsonb_array_elements(llm_response->'artistic_connections') elem
    WHERE llm_response->'artistic_connections' IS NOT NULL
    GROUP BY COALESCE(elem->>'artist_or_movement', elem::text)
    ORDER BY frequency DESC
    LIMIT $1
    """

    case Repo.query(query, [limit]) do
      {:ok, %{rows: rows}} ->
        Enum.map(rows, fn [connection, frequency] ->
          %{connection: connection, frequency: frequency}
        end)

      _ ->
        []
    end
  end

  @doc """
  Gets most frequently used contextual frameworks across all analyses.
  """
  def get_top_contexts(limit \\ 10) do
    query = """
    SELECT
      COALESCE(elem->>'title', elem->>'name', 'Unknown') as context,
      COUNT(*) as frequency
    FROM media_analyses,
         jsonb_array_elements(llm_response->'contexts') elem
    WHERE llm_response->'contexts' IS NOT NULL
    GROUP BY COALESCE(elem->>'title', elem->>'name', 'Unknown')
    ORDER BY frequency DESC
    LIMIT $1
    """

    case Repo.query(query, [limit]) do
      {:ok, %{rows: rows}} ->
        Enum.map(rows, fn [context, frequency] ->
          %{context: context, frequency: frequency}
        end)

      _ ->
        []
    end
  end

  @doc """
  Exports exhibition-ready text for a media file.
  Returns formatted text suitable for gallery walls, catalogues, or website.
  """
  def export_exhibition_text(media_id, format \\ :long) do
    media = get_media!(media_id) |> Repo.preload(:analyses)
    latest_analysis = get_latest_analysis(media_id)

    if latest_analysis do
      interpretation = latest_analysis.llm_response["interpretation"] || ""
      technical = latest_analysis.llm_response["technical_details"] || %{}
      classification = latest_analysis.llm_response["classification"] || %{}

      case format do
        :short ->
          # 100-150 words for wall labels
          interpretation
          |> String.split(".")
          |> Enum.take(3)
          |> Enum.join(". ")
          |> Kernel.<>(".")

        :medium ->
          # First paragraph for web/catalogue
          interpretation
          |> String.split("\n\n")
          |> List.first()

        :long ->
          # Full interpretation
          interpretation

        :technical ->
          # Technical details only
          format_technical_details(technical, classification)
      end
    else
      nil
    end
  end

  defp format_technical_details(technical, classification) do
    medium = technical["medium"] || classification["medium"] || "Unknown"
    dimensions = technical["dimensions"] || "Dimensions TBC"
    year = technical["year"] || "2024"

    "#{medium}\n#{dimensions}\n#{year}"
  end
end
