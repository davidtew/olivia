defmodule Olivia.Communications do
  @moduledoc """
  The Communications context - manages subscribers and enquiries.
  """

  import Ecto.Query, warn: false
  alias Olivia.Repo
  alias Olivia.Communications.{Subscriber, Enquiry, Newsletter}
  alias Olivia.Emails.{NewsletterEmail, EnquiryEmail}
  alias Olivia.Mailer
  alias Olivia.Notifications.Webhook

  ## Subscribers

  @doc """
  Returns the list of subscribers.
  """
  def list_subscribers do
    Subscriber
    |> order_by([s], desc: s.inserted_at)
    |> Repo.all()
  end

  @doc """
  Gets a single subscriber.

  Raises `Ecto.NoResultsError` if the Subscriber does not exist.
  """
  def get_subscriber!(id), do: Repo.get!(Subscriber, id)

  @doc """
  Subscribes an email to the list.

  Returns {:ok, subscriber} or {:error, changeset}.
  Handles duplicate email gracefully.
  """
  def subscribe(attrs \\ %{}) do
    create_subscriber(attrs)
  end

  @doc """
  Creates a subscriber.

  Returns {:ok, subscriber} or {:error, changeset}.
  """
  def create_subscriber(attrs \\ %{}) do
    result =
      %Subscriber{}
      |> Subscriber.changeset(attrs)
      |> Repo.insert()

    case result do
      {:ok, subscriber} ->
        Webhook.notify_subscriber(subscriber)
        {:ok, subscriber}

      error ->
        error
    end
  end

  @doc """
  Deletes a subscriber.
  """
  def delete_subscriber(%Subscriber{} = subscriber) do
    Repo.delete(subscriber)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking subscriber changes.
  """
  def change_subscriber(%Subscriber{} = subscriber, attrs \\ %{}) do
    Subscriber.changeset(subscriber, attrs)
  end

  @doc """
  Exports subscribers as CSV data.

  Returns a string containing CSV data.
  """
  def export_subscribers_csv do
    subscribers = list_subscribers()

    header = "Email,Source,Subscribed At\n"

    rows =
      Enum.map_join(subscribers, "\n", fn sub ->
        "#{sub.email},#{sub.source},#{DateTime.to_iso8601(sub.inserted_at)}"
      end)

    header <> rows
  end

  ## Enquiries

  @doc """
  Returns the list of enquiries.

  ## Options
    * `:type` - Filter by enquiry type
    * `:limit` - Limit number of results
  """
  def list_enquiries(opts \\ []) do
    Enquiry
    |> apply_enquiry_filters(opts)
    |> order_by([e], desc: e.inserted_at)
    |> maybe_limit(opts)
    |> Repo.all()
  end

  defp apply_enquiry_filters(query, opts) do
    Enum.reduce(opts, query, fn
      {:type, type}, query ->
        where(query, [e], e.type == ^type)

      _, query ->
        query
    end)
  end

  defp maybe_limit(query, opts) do
    case Keyword.get(opts, :limit) do
      nil -> query
      limit -> limit(query, ^limit)
    end
  end

  @doc """
  Gets a single enquiry.

  Raises `Ecto.NoResultsError` if the Enquiry does not exist.
  """
  def get_enquiry!(id), do: Repo.get!(Enquiry, id)

  @doc """
  Creates an enquiry and sends email notification.
  """
  def create_enquiry(attrs \\ %{}) do
    result =
      %Enquiry{}
      |> Enquiry.changeset(attrs)
      |> Repo.insert()

    case result do
      {:ok, enquiry} ->
        send_enquiry_notification(enquiry)
        Webhook.notify_enquiry(enquiry)
        {:ok, enquiry}

      error ->
        error
    end
  end

  defp send_enquiry_notification(enquiry) do
    admin_email = Application.get_env(:olivia, :emails)[:admin_email] || "admin@olivia.art"

    try do
      EnquiryEmail.new_enquiry_notification(enquiry, admin_email)
      |> Mailer.deliver()
    rescue
      e ->
        require Logger
        Logger.warning("Failed to send enquiry notification email: #{inspect(e)}")
        :ok
    end
  end

  @doc """
  Deletes an enquiry.
  """
  def delete_enquiry(%Enquiry{} = enquiry) do
    Repo.delete(enquiry)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking enquiry changes.
  """
  def change_enquiry(%Enquiry{} = enquiry, attrs \\ %{}) do
    Enquiry.changeset(enquiry, attrs)
  end

  ## Newsletters

  @doc """
  Returns the list of newsletters.

  ## Options
    * `:status` - Filter by status
  """
  def list_newsletters(opts \\ []) do
    Newsletter
    |> apply_newsletter_filters(opts)
    |> order_by([n], desc: n.inserted_at)
    |> Repo.all()
  end

  defp apply_newsletter_filters(query, opts) do
    Enum.reduce(opts, query, fn
      {:status, status}, query ->
        where(query, [n], n.status == ^status)

      _, query ->
        query
    end)
  end

  @doc """
  Gets a single newsletter.

  Raises `Ecto.NoResultsError` if the Newsletter does not exist.
  """
  def get_newsletter!(id), do: Repo.get!(Newsletter, id)

  @doc """
  Creates a newsletter.
  """
  def create_newsletter(attrs \\ %{}) do
    %Newsletter{}
    |> Newsletter.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a newsletter.
  """
  def update_newsletter(%Newsletter{} = newsletter, attrs) do
    newsletter
    |> Newsletter.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a newsletter.
  """
  def delete_newsletter(%Newsletter{} = newsletter) do
    Repo.delete(newsletter)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking newsletter changes.
  """
  def change_newsletter(%Newsletter{} = newsletter, attrs \\ %{}) do
    Newsletter.changeset(newsletter, attrs)
  end

  @doc """
  Sends a newsletter to all subscribers.

  Returns {:ok, newsletter} with updated sent_at and sent_count or {:error, reason}.
  """
  def send_newsletter(%Newsletter{} = newsletter) do
    if newsletter.status == "sent" do
      {:error, :already_sent}
    else
      subscribers = list_subscribers()
      body_html = Earmark.as_html!(newsletter.body_md)

      results =
        Enum.map(subscribers, fn subscriber ->
          NewsletterEmail.build(subscriber.email, newsletter.subject, body_html)
          |> Mailer.deliver()
        end)

      successful_sends = Enum.count(results, &match?({:ok, _}, &1))

      update_newsletter(newsletter, %{
        status: "sent",
        sent_at: DateTime.utc_now(),
        sent_count: successful_sends
      })
    end
  end
end
