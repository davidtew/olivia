defmodule Olivia.Communications.Enquiry do
  use Ecto.Schema
  import Ecto.Changeset

  @types ~w(artwork project commission general)

  schema "enquiries" do
    field :type, :string
    field :name, :string
    field :email, :string
    field :message, :string
    field :meta, :map

    belongs_to :artwork, Olivia.Content.Artwork

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(enquiry, attrs) do
    enquiry
    |> cast(attrs, [:type, :name, :email, :message, :meta, :artwork_id])
    |> validate_required([:type, :name, :email, :message])
    |> validate_inclusion(:type, @types)
    |> validate_format(:email, ~r/^[^@,;\s]+@[^@,;\s]+$/, message: "must be a valid email")
    |> foreign_key_constraint(:artwork_id)
  end

  def types, do: @types
end
