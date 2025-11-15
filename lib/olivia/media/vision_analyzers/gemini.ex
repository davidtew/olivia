defmodule Olivia.Media.VisionAnalyzers.Gemini do
  @moduledoc """
  Google Gemini Vision API implementation for media analysis.

  Configuration:
    config :olivia, Olivia.Media.VisionAnalyzers.Gemini,
      api_key: System.get_env("GEMINI_API_KEY"),
      model: "gemini-pro-vision"
  """

  @behaviour Olivia.Media.VisionAnalyzer

  require Logger

  @impl true
  def configured? do
    case Application.get_env(:olivia, __MODULE__, [])[:api_key] do
      nil -> false
      "" -> false
      _key -> true
    end
  end

  @impl true
  def analyze(media) do
    if not configured?() do
      {:error, :not_configured}
    else
      perform_analysis(media)
    end
  end

  defp perform_analysis(media) do
    api_key = Application.get_env(:olivia, __MODULE__)[:api_key]
    model = Application.get_env(:olivia, __MODULE__, [])[:model] || "gemini-pro-vision"

    Logger.info("Analyzing media #{media.id} with Gemini Vision")

    # Construct the prompt for image analysis
    prompt = """
    Analyse this image and provide structured information in British English:

    1. Asset Type: Identify whether this is an artwork, brand asset (logo), document, or other type
    2. Subject Matter: Describe what the image depicts
    3. Style/Medium: If artwork, identify the style or medium (oil, watercolour, digital, etc.)
    4. Tags: Provide 5-10 relevant tags using British English spelling where applicable
    5. Alt Text: Generate accessible alt text (1-2 sentences) in British English
    6. Asset Role: Suggest the specific role (e.g., "artwork_primary", "brand_logo", "process_photo")

    Use British English spelling and terminology throughout (colour not color, emphasise not emphasize, etc.).
    Maintain a professional, refined tone appropriate for an artist's portfolio.

    Respond in JSON format with these keys:
    {
      "asset_type": "artwork|brand|document|other",
      "asset_role": "specific_role",
      "subject": "description",
      "style_or_medium": "style/medium if applicable",
      "tags": ["tag1", "tag2", ...],
      "alt_text": "accessible description",
      "confidence": 0.0-1.0
    }
    """

    # Make API request to Gemini
    url = "https://generativelanguage.googleapis.com/v1beta/models/#{model}:generateContent?key=#{api_key}"

    body = %{
      "contents" => [
        %{
          "parts" => [
            %{"text" => prompt},
            %{
              "inline_data" => %{
                "mime_type" => media.content_type,
                "data" => get_base64_image(media.url)
              }
            }
          ]
        }
      ]
    }

    case Req.post(url, json: body) do
      {:ok, %{status: 200, body: response_body}} ->
        parse_gemini_response(response_body, media)

      {:ok, %{status: status_code, body: error_body}} ->
        Logger.error("Gemini API error #{status_code}: #{inspect(error_body)}")
        {:error, {:api_error, status_code}}

      {:error, error} ->
        Logger.error("Gemini API request failed: #{inspect(error)}")
        {:error, error}
    end
  end

  defp get_base64_image(url) do
    # For local files, read and encode
    # For remote URLs, download and encode
    if String.starts_with?(url, "http") do
      case Req.get(url) do
        {:ok, %{body: body}} -> Base.encode64(body)
        {:error, _} -> ""
      end
    else
      # Local file path
      file_path = Path.join("priv/static", url)

      case File.read(file_path) do
        {:ok, content} -> Base.encode64(content)
        {:error, _} -> ""
      end
    end
  end

  defp parse_gemini_response(response_body, media) do
    case Jason.decode(response_body) do
      {:ok, %{"candidates" => [%{"content" => %{"parts" => [%{"text" => text}]}} | _]}} ->
        # Extract JSON from the response text
        case extract_json(text) do
          {:ok, analysis} ->
            result = %{
              asset_type: analysis["asset_type"],
              asset_role: analysis["asset_role"],
              alt_text: analysis["alt_text"],
              tags: analysis["tags"] || [],
              metadata: %{
                "subject" => analysis["subject"],
                "style_or_medium" => analysis["style_or_medium"],
                "gemini_analysis" => text
              },
              confidence: analysis["confidence"] || 0.8,
              raw_response: response_body
            }

            {:ok, result}

          {:error, _} ->
            {:error, :invalid_response_format}
        end

      {:ok, response} ->
        Logger.warning("Unexpected Gemini response format: #{inspect(response)}")
        {:error, :unexpected_response}

      {:error, error} ->
        Logger.error("Failed to parse Gemini response: #{inspect(error)}")
        {:error, :parse_error}
    end
  end

  defp extract_json(text) do
    # Try to find JSON in the response (Gemini sometimes wraps it in markdown)
    case Regex.run(~r/\{.*\}/s, text) do
      [json_string] -> Jason.decode(json_string)
      nil -> {:error, :no_json_found}
    end
  end
end
