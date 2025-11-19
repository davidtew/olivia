defmodule Olivia.Media.ReviewNote do
  @moduledoc """
  Schema for tracking review actions and notes on media files.
  Provides an audit trail for the quarantine workflow.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @actions ~w(upload approve reject archive restore note status_change)

  schema "media_review_notes" do
    field :action, :string
    field :note, :string
    field :previous_status, :string
    field :new_status, :string

    belongs_to :media, Olivia.Media.MediaFile
    belongs_to :user, Olivia.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(review_note, attrs) do
    review_note
    |> cast(attrs, [:media_id, :user_id, :action, :note, :previous_status, :new_status])
    |> validate_required([:media_id, :action])
    |> validate_inclusion(:action, @actions)
    |> foreign_key_constraint(:media_id)
    |> foreign_key_constraint(:user_id)
  end

  def actions, do: @actions
end
