defmodule Olivia.Media.Events do
  @moduledoc """
  Media upload event broadcasting system.

  Emits events when media files are uploaded, allowing external systems
  (AI vision analysis, webhooks, etc.) to react to new uploads.
  """

  require Logger

  @doc """
  Broadcasts a media_uploaded event.

  Event payload includes:
  - media: The MediaFile struct
  - context: Upload context (artwork_form, media_library, etc.)
  - requires_analysis: Boolean indicating if AI analysis should run
  """
  def broadcast_media_uploaded(media, context \\ %{}) do
    event_payload = %{
      media: media,
      context: context,
      requires_analysis: requires_analysis?(media),
      timestamp: DateTime.utc_now()
    }

    Phoenix.PubSub.broadcast(
      Olivia.PubSub,
      "media:uploads",
      {:media_uploaded, event_payload}
    )

    Logger.info("Media uploaded event: #{media.filename} (ID: #{media.id}, Status: #{media.status})")

    {:ok, event_payload}
  end

  @doc """
  Broadcasts a media_analyzed event after AI analysis completes.
  """
  def broadcast_media_analyzed(media, analysis_result) do
    event_payload = %{
      media: media,
      analysis: analysis_result,
      timestamp: DateTime.utc_now()
    }

    Phoenix.PubSub.broadcast(
      Olivia.PubSub,
      "media:analysis",
      {:media_analyzed, event_payload}
    )

    Logger.info("Media analyzed event: #{media.filename} (ID: #{media.id})")

    {:ok, event_payload}
  end

  @doc """
  Subscribes to media upload events.
  Useful for LiveViews or background processes that need to react to uploads.
  """
  def subscribe_uploads do
    Phoenix.PubSub.subscribe(Olivia.PubSub, "media:uploads")
  end

  @doc """
  Subscribes to media analysis events.
  """
  def subscribe_analysis do
    Phoenix.PubSub.subscribe(Olivia.PubSub, "media:analysis")
  end

  # Determines if media requires AI analysis
  defp requires_analysis?(media) do
    # Quarantined media with no asset_type needs analysis
    media.status == "quarantine" && is_nil(media.asset_type)
  end
end
