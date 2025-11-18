defmodule Olivia.Spatial.Node do
  use Ecto.Schema
  import Ecto.Changeset

  schema "spatial_nodes" do
    field :position_x, :float
    field :position_y, :float
    field :node_data, :map, default: %{}

    belongs_to :spatial_collection, Olivia.Spatial.Collection
    belongs_to :media_file, Olivia.Media.MediaFile
    has_many :outgoing_edges, Olivia.Spatial.Edge, foreign_key: :source_node_id
    has_many :incoming_edges, Olivia.Spatial.Edge, foreign_key: :target_node_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(node, attrs) do
    node
    |> cast(attrs, [:spatial_collection_id, :media_file_id, :position_x, :position_y, :node_data])
    |> validate_required([:spatial_collection_id, :media_file_id, :position_x, :position_y])
    |> unique_constraint([:spatial_collection_id, :media_file_id])
  end
end
