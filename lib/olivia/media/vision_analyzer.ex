defmodule Olivia.Media.VisionAnalyzer do
  @moduledoc """
  Behavior for AI vision analysis services.

  Implementations can use different providers:
  - Google Gemini Vision
  - OpenAI GPT-4 Vision
  - Anthropic Claude Vision
  - Local models
  """

  @type media :: Olivia.Media.MediaFile.t()
  @type analysis_result :: %{
          asset_type: String.t() | nil,
          asset_role: String.t() | nil,
          alt_text: String.t() | nil,
          tags: list(String.t()),
          metadata: map(),
          confidence: float(),
          raw_response: any()
        }

  @doc """
  Analyzes a media file and returns structured metadata.

  Options:
    - :user_context - Artist's notes/context for this analysis iteration
    - :previous_analyses - List of previous analysis structs for iterative refinement
  """
  @callback analyze(media, keyword()) :: {:ok, analysis_result} | {:error, term()}

  @doc """
  Returns true if the analyzer is configured and ready to use.
  """
  @callback configured?() :: boolean()
end
