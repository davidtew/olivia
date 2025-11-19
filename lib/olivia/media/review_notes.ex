defmodule Olivia.Media.ReviewNotes do
  @moduledoc """
  Functions for managing review notes and audit trail for media files.
  """

  import Ecto.Query
  alias Olivia.Repo
  alias Olivia.Media.ReviewNote

  @doc """
  Records a new action on a media file.
  """
  def record_action(media_id, action, opts \\ []) do
    attrs = %{
      media_id: media_id,
      action: action,
      user_id: Keyword.get(opts, :user_id),
      note: Keyword.get(opts, :note),
      previous_status: Keyword.get(opts, :previous_status),
      new_status: Keyword.get(opts, :new_status)
    }

    %ReviewNote{}
    |> ReviewNote.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Records an upload action.
  """
  def record_upload(media_id, user_id) do
    record_action(media_id, "upload",
      user_id: user_id,
      new_status: "quarantine"
    )
  end

  @doc """
  Records an approval action.
  """
  def record_approval(media_id, user_id, note \\ nil) do
    record_action(media_id, "approve",
      user_id: user_id,
      note: note,
      previous_status: "quarantine",
      new_status: "approved"
    )
  end

  @doc """
  Records a rejection action.
  """
  def record_rejection(media_id, user_id, note \\ nil) do
    record_action(media_id, "reject",
      user_id: user_id,
      note: note,
      previous_status: "quarantine",
      new_status: "archived"
    )
  end

  @doc """
  Records an archive action.
  """
  def record_archive(media_id, user_id, note \\ nil) do
    record_action(media_id, "archive",
      user_id: user_id,
      note: note,
      new_status: "archived"
    )
  end

  @doc """
  Records a status change.
  """
  def record_status_change(media_id, user_id, previous_status, new_status, note \\ nil) do
    record_action(media_id, "status_change",
      user_id: user_id,
      note: note,
      previous_status: previous_status,
      new_status: new_status
    )
  end

  @doc """
  Adds a note to a media file without changing status.
  """
  def add_note(media_id, user_id, note) do
    record_action(media_id, "note",
      user_id: user_id,
      note: note
    )
  end

  @doc """
  Gets all review notes for a media file.
  """
  def get_notes(media_id) do
    from(r in ReviewNote,
      where: r.media_id == ^media_id,
      order_by: [desc: r.inserted_at],
      preload: [:user]
    )
    |> Repo.all()
  end

  @doc """
  Gets recent review actions across all media.
  """
  def get_recent_actions(limit \\ 50) do
    from(r in ReviewNote,
      order_by: [desc: r.inserted_at],
      limit: ^limit,
      preload: [:user, :media]
    )
    |> Repo.all()
  end

  @doc """
  Gets actions by a specific user.
  """
  def get_user_actions(user_id, limit \\ 50) do
    from(r in ReviewNote,
      where: r.user_id == ^user_id,
      order_by: [desc: r.inserted_at],
      limit: ^limit,
      preload: [:media]
    )
    |> Repo.all()
  end

  @doc """
  Gets count of actions by type for a time period.
  """
  def get_action_stats(since \\ nil) do
    query =
      from(r in ReviewNote,
        group_by: r.action,
        select: {r.action, count(r.id)}
      )

    query =
      if since do
        from(r in query, where: r.inserted_at >= ^since)
      else
        query
      end

    query
    |> Repo.all()
    |> Map.new()
  end
end
