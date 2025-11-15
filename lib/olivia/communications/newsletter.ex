defmodule Olivia.Communications.Newsletter do
  use Ecto.Schema
  import Ecto.Changeset

  @statuses ~w(draft sent)

  schema "newsletters" do
    field :subject, :string
    field :body_md, :string
    field :status, :string, default: "draft"
    field :sent_at, :utc_datetime
    field :sent_count, :integer, default: 0

    belongs_to :user, Olivia.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(newsletter, attrs) do
    newsletter
    |> cast(attrs, [:subject, :body_md, :status, :sent_at, :sent_count, :user_id])
    |> validate_required([:subject, :body_md, :status])
    |> validate_inclusion(:status, @statuses)
  end

  def statuses, do: @statuses
end
