defmodule Olivia.Notifications.Webhook do
  @moduledoc """
  Sends notifications to external webhooks (Google Sheets via Apps Script).
  """

  require Logger

  @webhook_url "https://script.google.com/macros/s/AKfycbz21w009mLgn1IEg8_ZrhkaKiv58XinHnqRzeDw4jTFqAap6aNsK4uru8cTk0k0aGw-jw/exec"

  @doc """
  Sends an enquiry notification to the webhook.
  """
  def notify_enquiry(enquiry) do
    # Load artwork title if available
    artwork_title = get_artwork_title(enquiry)

    payload = %{
      type: "enquiry",
      timestamp: DateTime.to_iso8601(enquiry.inserted_at),
      name: enquiry.name,
      email: enquiry.email,
      phone: get_in(enquiry.meta || %{}, ["phone"]) || "",
      message: enquiry.message,
      artwork_title: artwork_title
    }

    send_webhook(payload)
  end

  @doc """
  Sends a subscriber notification to the webhook.
  """
  def notify_subscriber(subscriber) do
    payload = %{
      type: "subscriber",
      timestamp: DateTime.to_iso8601(subscriber.inserted_at),
      email: subscriber.email
    }

    send_webhook(payload)
  end

  defp get_artwork_title(enquiry) do
    case enquiry.artwork_id do
      nil -> nil
      _id ->
        # Try to get artwork title if preloaded or load it
        case enquiry do
          %{artwork: %{title: title}} when not is_nil(title) -> title
          %{artwork_id: artwork_id} when not is_nil(artwork_id) ->
            try do
              artwork = Olivia.Repo.get(Olivia.Content.Artwork, artwork_id)
              artwork && artwork.title
            rescue
              _ -> nil
            end
          _ -> nil
        end
    end
  end

  defp send_webhook(payload) do
    # Only send in production or when explicitly enabled
    if should_send_webhook?() do
      Task.start(fn ->
        do_send_webhook(payload)
      end)
    else
      Logger.debug("Webhook notification skipped (not in production): #{inspect(payload)}")
      :ok
    end
  end

  defp do_send_webhook(payload) do
    body = Jason.encode!(payload)

    case :httpc.request(
           :post,
           {String.to_charlist(@webhook_url), [], ~c"application/json", body},
           [{:timeout, 10_000}, {:connect_timeout, 5_000}],
           []
         ) do
      {:ok, {{_, status, _}, _, _response_body}} when status in 200..299 ->
        Logger.info("Webhook notification sent successfully: #{payload.type}")
        :ok

      {:ok, {{_, status, _}, _, response_body}} ->
        Logger.warning("Webhook notification failed with status #{status}: #{inspect(response_body)}")
        {:error, :failed}

      {:error, reason} ->
        Logger.warning("Webhook notification error: #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp should_send_webhook? do
    # Send webhooks when PHX_HOST is set (production) or when WEBHOOK_ENABLED is set
    System.get_env("PHX_HOST") != nil or
      System.get_env("WEBHOOK_ENABLED") == "true"
  end
end
