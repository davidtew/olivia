defmodule Olivia.Spatial do
  @moduledoc """
  The Spatial context manages spatial collections, nodes, and edges
  for organizing artworks in a visual canvas.
  """

  import Ecto.Query, warn: false
  alias Olivia.Repo
  alias Olivia.Spatial.{Collection, Node, Edge}

  # Collections

  @doc """
  Returns the list of collections for a user.
  """
  def list_collections(user_id) do
    from(c in Collection,
      where: c.user_id == ^user_id,
      order_by: [desc: c.updated_at]
    )
    |> Repo.all()
  end

  @doc """
  Gets a single collection.
  """
  def get_collection!(id), do: Repo.get!(Collection, id)

  @doc """
  Gets a collection with all its nodes and edges preloaded.
  """
  def get_collection_with_data!(id) do
    Collection
    |> Repo.get!(id)
    |> Repo.preload([:nodes, :edges, nodes: :media_file])
  end

  @doc """
  Creates a collection.
  """
  def create_collection(attrs \\ %{}) do
    %Collection{}
    |> Collection.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a collection.
  """
  def update_collection(%Collection{} = collection, attrs) do
    collection
    |> Collection.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a collection.
  """
  def delete_collection(%Collection{} = collection) do
    Repo.delete(collection)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking collection changes.
  """
  def change_collection(%Collection{} = collection, attrs \\ %{}) do
    Collection.changeset(collection, attrs)
  end

  # Nodes

  @doc """
  Creates a node.
  """
  def create_node(attrs \\ %{}) do
    %Node{}
    |> Node.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a node.
  """
  def update_node(%Node{} = node, attrs) do
    node
    |> Node.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a node.
  """
  def delete_node(%Node{} = node) do
    Repo.delete(node)
  end

  @doc """
  Deletes a node by ID.
  """
  def delete_node_by_id(node_id) do
    case Repo.get(Node, node_id) do
      nil -> {:error, :not_found}
      node -> Repo.delete(node)
    end
  end

  # Edges

  @doc """
  Creates an edge.
  """
  def create_edge(attrs \\ %{}) do
    %Edge{}
    |> Edge.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes an edge.
  """
  def delete_edge(%Edge{} = edge) do
    Repo.delete(edge)
  end

  @doc """
  Deletes an edge by ID.
  """
  def delete_edge_by_id(edge_id) do
    case Repo.get(Edge, edge_id) do
      nil -> {:error, :not_found}
      edge -> Repo.delete(edge)
    end
  end

  # Bulk operations

  @doc """
  Saves the entire graph state for a collection.
  This replaces all nodes and edges with the provided data.
  """
  def save_graph_state(collection_id, nodes_data, edges_data) do
    Repo.transaction(fn ->
      collection = get_collection!(collection_id)

      # Delete all existing nodes and edges (cascade will handle edges)
      from(n in Node, where: n.spatial_collection_id == ^collection_id)
      |> Repo.delete_all()

      # Insert new nodes
      node_id_map =
        Enum.reduce(nodes_data, %{}, fn node_attrs, acc ->
          {:ok, node} = create_node(Map.put(node_attrs, :spatial_collection_id, collection_id))
          # Map cytoscape ID to database ID
          cyto_id = node_attrs[:cytoscape_id] || node_attrs["cytoscape_id"]
          Map.put(acc, cyto_id, node.id)
        end)

      # Insert new edges
      Enum.each(edges_data, fn edge_attrs ->
        source_cyto_id = edge_attrs[:source_cytoscape_id] || edge_attrs["source_cytoscape_id"]
        target_cyto_id = edge_attrs[:target_cytoscape_id] || edge_attrs["target_cytoscape_id"]

        create_edge(%{
          spatial_collection_id: collection_id,
          source_node_id: node_id_map[source_cyto_id],
          target_node_id: node_id_map[target_cyto_id],
          edge_data: edge_attrs[:edge_data] || edge_attrs["edge_data"] || %{}
        })
      end)

      collection
    end)
  end

  @doc """
  Updates node positions in bulk.
  """
  def update_node_positions(position_updates) do
    Repo.transaction(fn ->
      Enum.each(position_updates, fn %{id: id, position_x: x, position_y: y} ->
        from(n in Node, where: n.id == ^id)
        |> Repo.update_all(set: [position_x: x, position_y: y, updated_at: DateTime.utc_now()])
      end)
    end)
  end
end
