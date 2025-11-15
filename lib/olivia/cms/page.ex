defmodule Olivia.CMS.Page do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pages" do
    field :slug, :string
    field :title, :string

    has_many :sections, Olivia.CMS.PageSection

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(page, attrs) do
    page
    |> cast(attrs, [:slug, :title])
    |> validate_required([:slug, :title])
    |> unique_constraint(:slug)
  end
end
