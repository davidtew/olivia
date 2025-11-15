defmodule Olivia.Exhibitions.Exhibition do
  use Ecto.Schema
  import Ecto.Changeset

  schema "exhibitions" do
    field :title, :string
    field :venue, :string
    field :city, :string
    field :country, :string
    field :start_date, :date
    field :end_date, :date
    field :description_md, :string
    field :position, :integer, default: 0
    field :published, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(exhibition, attrs) do
    exhibition
    |> cast(attrs, [
      :title,
      :venue,
      :city,
      :country,
      :start_date,
      :end_date,
      :description_md,
      :position,
      :published
    ])
    |> validate_required([:title])
    |> validate_date_order()
  end

  defp validate_date_order(changeset) do
    start_date = get_field(changeset, :start_date)
    end_date = get_field(changeset, :end_date)

    if start_date && end_date && Date.compare(start_date, end_date) == :gt do
      add_error(changeset, :end_date, "must be after start date")
    else
      changeset
    end
  end
end
