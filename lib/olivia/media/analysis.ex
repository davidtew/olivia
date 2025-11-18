defmodule Olivia.Media.Analysis do
  @moduledoc """
  Represents an AI vision analysis iteration for a media file.

  Supports iterative dialogue between artist and AI, where each analysis
  can build on previous iterations with additional artist context.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Olivia.Media.MediaFile

  schema "media_analyses" do
    field :iteration, :integer
    field :user_context, :string
    field :llm_response, :map
    field :model_used, :string

    belongs_to :media_file, MediaFile

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(analysis, attrs) do
    analysis
    |> cast(attrs, [:media_file_id, :iteration, :user_context, :llm_response, :model_used])
    |> validate_required([:media_file_id, :iteration, :llm_response])
    |> validate_number(:iteration, greater_than: 0)
    |> unique_constraint([:media_file_id, :iteration])
    |> foreign_key_constraint(:media_file_id)
  end

  @doc """
  Extracts interpretation from LLM response for display.
  """
  def get_interpretation(%__MODULE__{llm_response: response}) do
    response["interpretation"] || "No interpretation available"
  end

  @doc """
  Extracts suggested contexts from LLM response.
  """
  def get_contexts(%__MODULE__{llm_response: response}) do
    response["contexts"] || []
  end

  @doc """
  Extracts provocations (questions) from LLM response.
  """
  def get_provocations(%__MODULE__{llm_response: response}) do
    response["provocations"] || []
  end

  @doc """
  Extracts artistic connections from LLM response.
  """
  def get_artistic_connections(%__MODULE__{llm_response: response}) do
    response["artistic_connections"] || []
  end
end
