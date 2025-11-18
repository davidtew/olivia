defmodule Olivia.Repo.Migrations.CreateSpatialCollectionsAndNodes do
  use Ecto.Migration

  def change do
    create table(:spatial_collections) do
      add :name, :string, null: false
      add :description, :text
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :layout_config, :map, default: %{}
      add :metadata, :map, default: %{}

      timestamps(type: :utc_datetime)
    end

    create index(:spatial_collections, [:user_id])

    create table(:spatial_nodes) do
      add :spatial_collection_id, references(:spatial_collections, on_delete: :delete_all), null: false
      add :media_file_id, references(:media, on_delete: :delete_all), null: false
      add :position_x, :float, null: false
      add :position_y, :float, null: false
      add :node_data, :map, default: %{}

      timestamps(type: :utc_datetime)
    end

    create index(:spatial_nodes, [:spatial_collection_id])
    create index(:spatial_nodes, [:media_file_id])
    create unique_index(:spatial_nodes, [:spatial_collection_id, :media_file_id])

    create table(:spatial_edges) do
      add :spatial_collection_id, references(:spatial_collections, on_delete: :delete_all), null: false
      add :source_node_id, references(:spatial_nodes, on_delete: :delete_all), null: false
      add :target_node_id, references(:spatial_nodes, on_delete: :delete_all), null: false
      add :edge_data, :map, default: %{}

      timestamps(type: :utc_datetime)
    end

    create index(:spatial_edges, [:spatial_collection_id])
    create index(:spatial_edges, [:source_node_id])
    create index(:spatial_edges, [:target_node_id])
  end
end
