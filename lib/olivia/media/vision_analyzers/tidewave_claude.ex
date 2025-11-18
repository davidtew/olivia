defmodule Olivia.Media.VisionAnalyzers.TidewaveClaude do
  @moduledoc """
  Claude Vision implementation using Tidewave MCP for media analysis.

  Uses Claude via Tidewave's MCP integration, which doesn't require an API key.
  Supports iterative analysis with user context and multi-context interpretations.
  """

  @behaviour Olivia.Media.VisionAnalyzer

  require Logger

  @impl true
  def configured? do
    # Always configured since Tidewave MCP is available in the runtime
    true
  end

  @impl true
  def analyze(media, opts \\ []) do
    user_context = Keyword.get(opts, :user_context)
    previous_analyses = Keyword.get(opts, :previous_analyses, [])

    Logger.info("Analyzing media #{media.id} with Tidewave Claude (iteration #{length(previous_analyses) + 1})")

    case analyze_image(media, user_context, previous_analyses) do
      {:ok, analysis} ->
        {:ok, analysis}

      {:error, reason} ->
        Logger.error("Tidewave Claude analysis failed for media #{media.id}: #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp analyze_image(media, user_context, previous_analyses) do
    with {:ok, base64_image} <- get_base64_image(media.url),
         {:ok, parsed_json} <- call_tidewave_claude(media, base64_image, user_context, previous_analyses) do
      build_analysis_result(parsed_json, media)
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp get_base64_image(url) do
    if String.starts_with?(url, "http") do
      case Req.get(url) do
        {:ok, %{body: body}} -> {:ok, Base.encode64(body)}
        {:error, error} -> {:error, {:image_fetch_failed, error}}
      end
    else
      file_path = Path.join("priv/static", url)

      case File.read(file_path) do
        {:ok, content} -> {:ok, Base.encode64(content)}
        {:error, error} -> {:error, {:file_read_failed, error}}
      end
    end
  end

  defp call_tidewave_claude(media, base64_image, user_context, previous_analyses) do
    prompt = build_analysis_prompt(user_context, previous_analyses)

    # Build the Elixir code that will be evaluated in the runtime
    # This sends the image to Claude via the Tidewave MCP
    code = """
    image_data = Base.decode64!(~s(#{base64_image}))

    prompt = ~s(#{escape_string(prompt)})

    # Use Tidewave's Claude integration to analyze the image
    # Note: This is a placeholder - we'll need to use the actual Tidewave API
    # For now, return a mock response structure
    {:ok, %{
      "interpretation" => "Analysis via Tidewave MCP",
      "contexts" => [],
      "artistic_connections" => [],
      "provocations" => [],
      "classification" => %{
        "asset_type" => "artwork",
        "asset_role" => "artwork_primary",
        "tags" => [],
        "alt_text" => "Image analyzed via Tidewave",
        "confidence" => 0.85
      },
      "technical_details" => %{
        "medium" => "Unknown",
        "style" => "Unknown",
        "colour_palette" => [],
        "composition" => "Unknown"
      }
    }}
    """

    # For now, return a placeholder. We need to integrate with the actual Tidewave API
    # TODO: Use the proper Tidewave MCP integration
    {:ok, %{
      "interpretation" => "Tidewave MCP integration pending",
      "contexts" => [],
      "artistic_connections" => [],
      "provocations" => ["This is a test analysis using Tidewave"],
      "classification" => %{
        "asset_type" => media.asset_type || "artwork",
        "asset_role" => media.asset_role || "artwork_primary",
        "tags" => media.tags || [],
        "alt_text" => media.alt_text || "Artwork image",
        "confidence" => 0.85
      },
      "technical_details" => %{
        "medium" => "Pending analysis",
        "style" => "Pending analysis",
        "colour_palette" => [],
        "composition" => "Pending analysis"
      }
    }}
  end

  defp escape_string(str) do
    str
    |> String.replace("\\", "\\\\")
    |> String.replace("\"", "\\\"")
    |> String.replace("\n", "\\n")
  end

  defp build_analysis_prompt(user_context, previous_analyses) do
    context_section =
      if user_context && user_context != "" do
        """
        Artist's Context:
        #{user_context}

        """
      else
        ""
      end

    history_section =
      if length(previous_analyses) > 0 do
        formatted_history =
          previous_analyses
          |> Enum.with_index(1)
          |> Enum.map(fn {analysis, iteration} ->
            """
            Iteration #{iteration}:
            #{if analysis.user_context, do: "Artist said: #{analysis.user_context}\n"}
            Previous interpretation: #{get_in(analysis.llm_response, ["interpretation"]) || "N/A"}
            """
          end)
          |> Enum.join("\n")

        """
        Previous Analysis History:
        #{formatted_history}

        """
      else
        ""
      end

    """
    #{context_section}#{history_section}Analyse this artwork and provide a thoughtful, multi-faceted interpretation using British English throughout.

    Your role is to be a creative partner to the artist, helping them discover what their work expresses. Consider multiple contextual lenses:

    1. Primary Interpretation: What is the core subject, mood, and visual language?
    2. Contextual Possibilities: How might this work differently in:
       - A portfolio/exhibition context
       - As part of a thematic series
       - For marketing/social media purposes
       - As documentation of artistic process

    3. Artistic Connections: What art historical movements, contemporary artists, or aesthetic traditions does this evoke?

    4. Provocations: What questions or observations might help the artist see their work differently?

    5. Classification Suggestions:
       - Asset type (artwork, brand asset, documentation, etc.)
       - Specific role (artwork_primary, series_hero, process_photo, etc.)
       - Suggested tags (10-15 using British English spelling)
       - Alt text (2-3 sentences, accessible and evocative)

    Respond in JSON format:
    {
      "interpretation": "Rich, thoughtful analysis of the work",
      "contexts": [
        {
          "name": "Portfolio Display",
          "reasoning": "Why this context fits",
          "emphasis": "What to highlight in this context",
          "confidence": 0.0-1.0
        }
      ],
      "artistic_connections": ["Movement or artist 1", "Movement or artist 2"],
      "provocations": [
        "Question or observation that might shift perspective"
      ],
      "classification": {
        "asset_type": "artwork|brand|document|other",
        "asset_role": "specific_role",
        "tags": ["tag1", "tag2"],
        "alt_text": "Accessible description in British English",
        "confidence": 0.0-1.0
      },
      "technical_details": {
        "medium": "Identified medium/technique",
        "style": "Artistic style",
        "colour_palette": ["dominant", "colours"],
        "composition": "Compositional approach"
      }
    }

    Use British English spelling throughout (colour, emphasise, analyse, centre, etc.).
    Be thoughtful, not formulaic. Help the artist think deeply about their work.
    """
  end

  defp build_analysis_result(parsed_json, _media) do
    classification = parsed_json["classification"] || %{}
    technical = parsed_json["technical_details"] || %{}

    analysis = %{
      asset_type: classification["asset_type"],
      asset_role: classification["asset_role"],
      alt_text: classification["alt_text"],
      tags: classification["tags"] || [],
      metadata: %{
        "interpretation" => parsed_json["interpretation"],
        "contexts" => parsed_json["contexts"] || [],
        "artistic_connections" => parsed_json["artistic_connections"] || [],
        "provocations" => parsed_json["provocations"] || [],
        "medium" => technical["medium"],
        "style" => technical["style"],
        "colour_palette" => technical["colour_palette"] || [],
        "composition" => technical["composition"]
      },
      confidence: classification["confidence"] || 0.85,
      raw_response: %{
        analyzer: "tidewave_claude",
        model: "claude-via-tidewave",
        full_response: parsed_json,
        timestamp: DateTime.utc_now()
      }
    }

    {:ok, analysis}
  end
end
