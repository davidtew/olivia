defmodule Olivia.Spatial.Edge do
  use Ecto.Schema
  import Ecto.Changeset

  schema "spatial_edges" do
    field :edge_data, :map, default: %{}

    belongs_to :spatial_collection, Olivia.Spatial.Collection
    belongs_to :source_node, Olivia.Spatial.Node
    belongs_to :target_node, Olivia.Spatial.Node

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(edge, attrs) do
    edge
    |> cast(attrs, [:spatial_collection_id, :source_node_id, :target_node_id, :edge_data])
    |> validate_required([:spatial_collection_id, :source_node_id, :target_node_id])
    |> validate_different_nodes()
  end

  defp validate_different_nodes(changeset) do
    source = get_field(changeset, :source_node_id)
    target = get_field(changeset, :target_node_id)

    if source && target && source == target do
      add_error(changeset, :target_node_id, "cannot connect a node to itself")
    else
      changeset
    end
  end
end
