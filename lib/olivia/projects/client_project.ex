defmodule Olivia.Projects.ClientProject do
  use Ecto.Schema
  import Ecto.Changeset

  schema "client_projects" do
    field :name, :string
    field :client_name, :string
    field :location, :string
    field :status, :string
    field :description_md, :string
    field :position, :integer, default: 0
    field :published, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(client_project, attrs) do
    client_project
    |> cast(attrs, [:name, :client_name, :location, :status, :description_md, :position, :published])
    |> validate_required([:name])
  end
end
