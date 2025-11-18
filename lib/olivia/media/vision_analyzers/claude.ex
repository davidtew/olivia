defmodule Olivia.Media.VisionAnalyzers.Claude do
  @moduledoc """
  Claude Vision API implementation for media analysis.

  Uses Anthropic's Claude 3.5 Sonnet with vision capabilities to analyze
  artwork images. Supports iterative analysis with user context and
  multi-context interpretations.
  """

  @behaviour Olivia.Media.VisionAnalyzer

  require Logger

  @model "claude-3-5-sonnet-20241022"
  @api_version "2023-06-01"

  @impl true
  def configured? do
    case System.get_env("ANTHROPIC_API_KEY") do
      nil -> false
      "" -> false
      _key -> true
    end
  end

  @impl true
  def analyze(media, opts \\ []) do
    if not configured?() do
      Logger.error("Claude Vision analyzer not configured - missing ANTHROPIC_API_KEY")
      {:error, :not_configured}
    else
      user_context = Keyword.get(opts, :user_context)
      previous_analyses = Keyword.get(opts, :previous_analyses, [])

      Logger.info("Analyzing media #{media.id} with Claude Vision (iteration #{length(previous_analyses) + 1})")

      case analyze_image(media, user_context, previous_analyses) do
        {:ok, analysis} ->
          {:ok, analysis}

        {:error, reason} ->
          Logger.error("Claude analysis failed for media #{media.id}: #{inspect(reason)}")
          {:error, reason}
      end
    end
  end

  defp analyze_image(media, user_context, previous_analyses) do
    with {:ok, base64_image} <- get_base64_image(media.url),
         {:ok, api_response} <- call_claude_api(media, base64_image, user_context, previous_analyses) do
      parse_claude_response(api_response, media)
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

  defp call_claude_api(media, base64_image, user_context, previous_analyses) do
    api_key = System.get_env("ANTHROPIC_API_KEY")
    prompt = build_analysis_prompt(user_context, previous_analyses)

    url = "https://api.anthropic.com/v1/messages"

    headers = [
      {"x-api-key", api_key},
      {"anthropic-version", @api_version},
      {"content-type", "application/json"}
    ]

    body = %{
      "model" => @model,
      "max_tokens" => 2048,
      "messages" => [
        %{
          "role" => "user",
          "content" => [
            %{
              "type" => "image",
              "source" => %{
                "type" => "base64",
                "media_type" => media.content_type || "image/jpeg",
                "data" => base64_image
              }
            },
            %{
              "type" => "text",
              "text" => prompt
            }
          ]
        }
      ]
    }

    case Req.post(url, headers: headers, json: body) do
      {:ok, %{status: 200, body: response_body}} ->
        {:ok, response_body}

      {:ok, %{status: status_code, body: error_body}} ->
        Logger.error("Claude API error #{status_code}: #{inspect(error_body)}")
        {:error, {:api_error, status_code}}

      {:error, error} ->
        Logger.error("Claude API request failed: #{inspect(error)}")
        {:error, error}
    end
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

  defp parse_claude_response(response_body, media) do
    with {:ok, content} <- extract_text_content(response_body),
         {:ok, parsed_json} <- parse_json_from_text(content) do
      build_analysis_result(parsed_json, response_body, media)
    else
      {:error, reason} ->
        Logger.error("Failed to parse Claude response: #{inspect(reason)}")
        {:error, {:parse_error, reason}}
    end
  end

  defp extract_text_content(response_body) do
    case response_body do
      %{"content" => [%{"text" => text} | _]} ->
        {:ok, text}

      %{"content" => content} when is_list(content) ->
        text_parts =
          Enum.filter(content, fn
            %{"type" => "text", "text" => _} -> true
            _ -> false
          end)

        case text_parts do
          [%{"text" => text} | _] -> {:ok, text}
          _ -> {:error, :no_text_content}
        end

      _ ->
        {:error, :invalid_response_format}
    end
  end

  defp parse_json_from_text(text) do
    text
    |> String.trim()
    |> then(fn content ->
      cond do
        String.starts_with?(content, "```json") ->
          content
          |> String.replace_prefix("```json", "")
          |> String.replace_suffix("```", "")
          |> String.trim()

        String.starts_with?(content, "```") ->
          content
          |> String.replace_prefix("```", "")
          |> String.replace_suffix("```", "")
          |> String.trim()

        true ->
          content
      end
    end)
    |> Jason.decode()
  end

  defp build_analysis_result(parsed_json, raw_response, _media) do
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
        analyzer: "claude",
        model: @model,
        full_response: raw_response,
        timestamp: DateTime.utc_now()
      }
    }

    {:ok, analysis}
  end
end
