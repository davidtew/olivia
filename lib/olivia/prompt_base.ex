defmodule Olivia.PromptBase do
  @moduledoc """
  PromptBase - Knowledge management and prompt library system for Olivia.

  Provides structured context about the codebase through YAML manifests
  and visualizes relationships through graph representations.
  """

  @manifest_path "lib/olivia/prompt_base/manifests/olivia-site.yml"

  @doc """
  Loads and parses the main Olivia site manifest.
  """
  def load_manifest do
    case YamlElixir.read_from_file(@manifest_path) do
      {:ok, manifest} -> {:ok, manifest}
      {:error, reason} -> {:error, "Failed to load manifest: #{inspect(reason)}"}
    end
  end

  @doc """
  Transforms the YAML manifest into a graph structure suitable for Cytoscape.js

  Returns a map with:
  - nodes: List of graph nodes (concepts, ADRs, patterns)
  - edges: List of graph edges (relationships, constraints, references)
  """
  def manifest_to_graph do
    case load_manifest() do
      {:ok, manifest} -> {:ok, build_graph(manifest)}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Gets manifest information as JSON-encodable data structure.
  """
  def get_manifest_data do
    case load_manifest() do
      {:ok, manifest} -> {:ok, manifest}
      {:error, reason} -> {:error, reason}
    end
  end

  # Private functions

  defp build_graph(manifest) do
    nodes = []
    edges = []

    # Add concept nodes
    {nodes, edges} =
      manifest
      |> Map.get("core_concepts", [])
      |> Enum.reduce({nodes, edges}, fn concept, {acc_nodes, acc_edges} ->
        concept_node = build_concept_node(concept)
        new_edges = build_concept_edges(concept)
        {[concept_node | acc_nodes], new_edges ++ acc_edges}
      end)

    # Add ADR nodes and their relationships
    {nodes, edges} =
      manifest
      |> Map.get("architectural_decisions", [])
      |> Enum.reduce({nodes, edges}, fn adr, {acc_nodes, acc_edges} ->
        adr_node = build_adr_node(adr)
        new_edges = build_adr_edges(adr, manifest)
        {[adr_node | acc_nodes], new_edges ++ acc_edges}
      end)

    # Add pattern nodes
    {nodes, edges} =
      manifest
      |> Map.get("common_patterns", [])
      |> Enum.reduce({nodes, edges}, fn pattern, {acc_nodes, acc_edges} ->
        pattern_node = build_pattern_node(pattern)
        new_edges = build_pattern_edges(pattern, manifest)
        {[pattern_node | acc_nodes], new_edges ++ acc_edges}
      end)

    %{
      nodes: nodes,
      edges: edges
    }
  end

  defp build_concept_node(concept) do
    %{
      data: %{
        id: concept["id"],
        label: concept["name"],
        type: "concept",
        domain: concept["domain"],
        schema: concept["schema"],
        location: concept["location"],
        description: concept["description"],
        table: concept["table"],
        admin_ui: concept["admin_ui"],
        key_fields: concept["key_fields"] || [],
        invariants: concept["invariants"] || []
      }
    }
  end

  defp build_concept_edges(concept) do
    concept_id = concept["id"]
    relationships = concept["relationships"] || %{}
    edges = []

    # has_many relationships
    edges =
      relationships
      |> Map.get("has_many", [])
      |> Enum.reduce(edges, fn rel, acc ->
        target = if is_map(rel), do: rel["target"], else: "concept.#{String.downcase(rel)}"

        [
          %{
            data: %{
              id: "#{concept_id}_has_many_#{target}",
              source: concept_id,
              target: target,
              label: "has many",
              type: "has_many"
            }
          }
          | acc
        ]
      end)

    # belongs_to relationships
    edges =
      relationships
      |> Map.get("belongs_to", [])
      |> Enum.reduce(edges, fn rel, acc ->
        target = if is_map(rel), do: rel["target"], else: "concept.#{String.downcase(rel)}"

        [
          %{
            data: %{
              id: "#{concept_id}_belongs_to_#{target}",
              source: concept_id,
              target: target,
              label: "belongs to",
              type: "belongs_to"
            }
          }
          | acc
        ]
      end)

    edges
  end

  defp build_adr_node(adr) do
    %{
      data: %{
        id: adr["id"],
        label: adr["title"],
        type: "adr",
        status: adr["status"],
        rationale: adr["rationale"],
        implications: adr["implications"],
        affected_areas: adr["affected_areas"] || []
      }
    }
  end

  defp build_adr_edges(adr, manifest) do
    adr_id = adr["id"]
    affected_areas = adr["affected_areas"] || []
    concepts = manifest["core_concepts"] || []

    # Link ADRs to concepts they affect
    Enum.flat_map(affected_areas, fn area ->
      area_lower = String.downcase(area)

      concepts
      |> Enum.filter(fn concept ->
        domain_match = String.downcase(concept["domain"] || "") == area_lower
        location_match = String.contains?(String.downcase(concept["location"] || ""), area_lower)
        domain_match or location_match
      end)
      |> Enum.map(fn concept ->
        %{
          data: %{
            id: "#{adr_id}_constrains_#{concept["id"]}",
            source: adr_id,
            target: concept["id"],
            label: "constrains",
            type: "constrains"
          }
        }
      end)
    end)
  end

  defp build_pattern_node(pattern) do
    %{
      data: %{
        id: pattern["id"],
        label: pattern["name"],
        type: "pattern",
        description: pattern["description"],
        applies_to: pattern["applies_to"] || [],
        steps: pattern["steps"] || [],
        reference_implementations: pattern["reference_implementations"] || []
      }
    }
  end

  defp build_pattern_edges(pattern, manifest) do
    pattern_id = pattern["id"]
    applies_to = pattern["applies_to"] || []
    concepts = manifest["core_concepts"] || []

    # Link patterns to concepts they apply to
    Enum.flat_map(applies_to, fn area ->
      area_lower = String.downcase(area)

      concepts
      |> Enum.filter(fn concept ->
        domain_match = String.downcase(concept["domain"] || "") == area_lower
        admin_match = area_lower == "admin" and concept["admin_ui"] != nil
        domain_match or admin_match
      end)
      |> Enum.map(fn concept ->
        %{
          data: %{
            id: "#{pattern_id}_applies_to_#{concept["id"]}",
            source: pattern_id,
            target: concept["id"],
            label: "applies to",
            type: "applies_to"
          }
        }
      end)
    end)
  end

  @doc """
  Gets a specific prompt template by ID.
  """
  def get_prompt_template(template_id) do
    case load_manifest() do
      {:ok, manifest} ->
        templates = manifest["prompt_templates"] || []
        template = Enum.find(templates, fn t -> t["id"] == template_id end)

        case template do
          nil -> {:error, "Template not found: #{template_id}"}
          t -> {:ok, t}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Lists all available prompt templates.
  """
  def list_prompt_templates do
    case load_manifest() do
      {:ok, manifest} ->
        templates = manifest["prompt_templates"] || []
        {:ok, templates}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Builds a complete prompt from a template with provided variables.
  """
  def build_prompt(template_id, variables \\ %{}) do
    case get_prompt_template(template_id) do
      {:ok, template} ->
        prompt_text = interpolate_variables(template, variables)
        {:ok, prompt_text}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp interpolate_variables(template, variables) do
    # Basic variable interpolation - replace {{variable_name}} with values
    # This is a simple implementation; could be enhanced with more sophisticated templating
    template_text = template["template"] || ""

    Enum.reduce(variables, template_text, fn {key, value}, text ->
      String.replace(text, "{{#{key}}}", to_string(value))
    end)
  end
end
