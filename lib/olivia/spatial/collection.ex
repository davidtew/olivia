defmodule Olivia.Spatial.Collection do
  use Ecto.Schema
  import Ecto.Changeset

  schema "spatial_collections" do
    field :name, :string
    field :description, :string
    field :layout_config, :map, default: %{}
    field :metadata, :map, default: %{}

    belongs_to :user, Olivia.Accounts.User
    has_many :nodes, Olivia.Spatial.Node, foreign_key: :spatial_collection_id
    has_many :edges, Olivia.Spatial.Edge, foreign_key: :spatial_collection_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(collection, attrs) do
    collection
    |> cast(attrs, [:name, :description, :layout_config, :metadata, :user_id])
    |> validate_required([:name, :user_id])
    |> validate_length(:name, min: 1, max: 255)
  end
end
