defmodule Olivia.Press.PressFeature do
  use Ecto.Schema
  import Ecto.Changeset

  schema "press_features" do
    field :title, :string
    field :publication, :string
    field :issue, :string
    field :date, :date
    field :url, :string
    field :excerpt_md, :string
    field :position, :integer, default: 0
    field :published, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(press_feature, attrs) do
    press_feature
    |> cast(attrs, [:title, :publication, :issue, :date, :url, :excerpt_md, :position, :published])
    |> validate_required([:title])
    |> validate_url()
  end

  defp validate_url(changeset) do
    case get_change(changeset, :url) do
      nil ->
        changeset

      url ->
        if String.match?(url, ~r/^https?:\/\/.+/) do
          changeset
        else
          add_error(changeset, :url, "must be a valid URL starting with http:// or https://")
        end
    end
  end
end
