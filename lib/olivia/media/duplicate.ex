defmodule Olivia.Media.Duplicate do
  @moduledoc """
  Schema for tracking duplicate/similar media files.
  Stores similarity scores between media files for duplicate detection.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "media_duplicates" do
    field :similarity_score, :float
    field :detection_method, :string, default: "phash"

    belongs_to :source_media, Olivia.Media.MediaFile
    belongs_to :target_media, Olivia.Media.MediaFile

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(duplicate, attrs) do
    duplicate
    |> cast(attrs, [:source_media_id, :target_media_id, :similarity_score, :detection_method])
    |> validate_required([:source_media_id, :target_media_id, :similarity_score])
    |> validate_number(:similarity_score, greater_than_or_equal_to: 0, less_than_or_equal_to: 1)
    |> foreign_key_constraint(:source_media_id)
    |> foreign_key_constraint(:target_media_id)
    |> unique_constraint([:source_media_id, :target_media_id])
  end
end
