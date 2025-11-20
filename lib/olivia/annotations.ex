defmodule Olivia.Annotations do
  @moduledoc """
  Context for managing voice annotations on page elements.
  """

  import Ecto.Query
  alias Olivia.Repo
  alias Olivia.Annotations.VoiceNote

  @doc """
  Lists all voice notes for a given page and theme.
  """
  def list_voice_notes(page_path, theme) do
    VoiceNote
    |> where([v], v.page_path == ^page_path and v.theme == ^theme)
    |> order_by([v], [desc: v.inserted_at])
    |> Repo.all()
  end

  @doc """
  Gets a single voice note by ID.
  Raises if not found.
  """
  def get_voice_note!(id), do: Repo.get!(VoiceNote, id)

  @doc """
  Creates a voice note.
  """
  def create_voice_note(attrs) do
    %VoiceNote{}
    |> VoiceNote.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes a voice note and its associated audio file from storage.
  """
  def delete_voice_note(%VoiceNote{} = voice_note) do
    # Delete from S3/storage
    if voice_note.audio_url do
      Olivia.Uploads.delete_by_url(voice_note.audio_url)
    end

    Repo.delete(voice_note)
  end

  @doc """
  Groups voice notes by their anchor key for a given page.
  Useful for loading existing notes and placing markers.
  """
  def voice_notes_by_anchor(page_path, theme) do
    list_voice_notes(page_path, theme)
    |> Enum.group_by(& &1.anchor_key)
  end
end
