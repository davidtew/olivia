defmodule Olivia.PromptBase.MediaAnalysisPrompt do
  @moduledoc """
  Generates Tidewave-ready prompts for media analysis.

  This module prepares prompts that can be copied and pasted into
  Tidewave chat, where Claude will execute the analysis workflow.
  """

  alias Olivia.Media

  @template_path "lib/olivia/prompt_base/prompts/analyze_media.md"

  @doc """
  Generates a complete analysis prompt for a given media ID.

  ## Parameters
    - media_id: The ID of the media file to analyze
    - user_context: Optional context/notes from the artist

  ## Returns
    A string containing the complete prompt ready to paste into Tidewave
  """
  def generate(media_id, user_context \\ nil) do
    media = Media.get_media!(media_id)
    next_iteration = Media.get_next_iteration(media_id)

    template = File.read!(@template_path)

    template
    |> String.replace("{{MEDIA_ID}}", to_string(media_id))
    |> String.replace("{{NEXT_ITERATION}}", to_string(next_iteration))
    |> handle_user_context(user_context)
  end

  defp handle_user_context(template, nil) do
    # Remove the user context section if not provided
    template
    |> String.replace(~r/\{\{#USER_CONTEXT\}\}.*?\{\{\/USER_CONTEXT\}\}/s, "")
    |> String.replace("{{^USER_CONTEXT}}nil{{/USER_CONTEXT}}", "nil")
  end

  defp handle_user_context(template, user_context) when is_binary(user_context) do
    template
    |> String.replace("{{#USER_CONTEXT}}", "")
    |> String.replace("{{/USER_CONTEXT}}", "")
    |> String.replace("{{USER_CONTEXT}}", escape_for_elixir(user_context))
    |> String.replace("{{^USER_CONTEXT}}nil{{/USER_CONTEXT}}", "\"#{escape_for_elixir(user_context)}\"")
  end

  defp escape_for_elixir(string) do
    string
    |> String.replace("\\", "\\\\")
    |> String.replace("\"", "\\\"")
    |> String.replace("\n", "\\n")
  end

  @doc """
  Generates a simplified prompt for quick copy-paste.
  Returns just the essential instructions without the full workflow.
  """
  def generate_quick(media_id, user_context \\ nil) do
    media = Media.get_media!(media_id)
    file_path = Path.join("/Users/tewm3/olivia/priv/static", media.url)
    next_iteration = Media.get_next_iteration(media_id)
    previous_analyses = Media.list_analyses(media_id)

    """
    # Quick Media Analysis - ID: #{media_id}

    ## Image
    File: `#{file_path}`
    Filename: #{media.filename}
    Current tags: #{inspect(media.tags)}

    ## Previous Analyses
    #{format_previous_analyses(previous_analyses)}

    #{if user_context, do: "## Artist's Context\n> #{user_context}\n", else: ""}

    ## Your Task
    1. Read the image file from the path above
    2. Analyze the artwork thoughtfully (see full prompt template for guidance)
    3. Provide JSON analysis following the standard structure
    4. Save to database:
       - Insert into `media_analyses` table (media_file_id=#{media_id}, iteration=#{next_iteration})
       - Update `media` table with classification results

    Use British English. Be thoughtful, not formulaic.
    """
  end

  defp format_previous_analyses([]), do: "None - this is the first analysis"
  defp format_previous_analyses(analyses) do
    Enum.map_join(analyses, "\n", fn analysis ->
      context = if analysis.user_context, do: " | Artist: #{analysis.user_context}", else: ""
      "- Iteration #{analysis.iteration}#{context}"
    end)
  end

  @doc """
  Gets just the file path for a media ID.
  Useful for quick reference.
  """
  def get_media_path(media_id) do
    media = Media.get_media!(media_id)
    Path.join("/Users/tewm3/olivia/priv/static", media.url)
  end
end
