defmodule Olivia.CMS.PageSection do
  use Ecto.Schema
  import Ecto.Changeset

  schema "page_sections" do
    field :key, :string
    field :content_md, :string
    field :position, :integer, default: 0

    belongs_to :page, Olivia.CMS.Page

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(page_section, attrs) do
    page_section
    |> cast(attrs, [:key, :content_md, :position, :page_id])
    |> validate_required([:key, :page_id])
    |> unique_constraint([:page_id, :key])
    |> foreign_key_constraint(:page_id)
  end
end
