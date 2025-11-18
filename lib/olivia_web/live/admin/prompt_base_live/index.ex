defmodule OliviaWeb.Admin.PromptBaseLive.Index do
  use OliviaWeb, :live_view

  alias Olivia.PromptBase

  @impl true
  def mount(_params, _session, socket) do
    {:ok, graph_data} = PromptBase.manifest_to_graph()
    {:ok, manifest} = PromptBase.get_manifest_data()
    {:ok, templates} = PromptBase.list_prompt_templates()

    {:ok,
     socket
     |> assign(:page_title, "PromptBase - Knowledge Graph")
     |> assign(:graph_data, graph_data)
     |> assign(:manifest, manifest)
     |> assign(:templates, templates)
     |> assign(:selected_node, nil)
     |> assign(:current_filter, "all")
     |> assign(:copied_template, nil)}
  end

  @impl true
  def handle_event("node-selected", %{"id" => id, "type" => type, "data" => data}, socket) do
    {:noreply, assign(socket, selected_node: %{id: id, type: type, data: data})}
  end

  @impl true
  def handle_event("node-deselected", _params, socket) do
    {:noreply, assign(socket, selected_node: nil)}
  end

  @impl true
  def handle_event("filter-graph", %{"type" => filter_type}, socket) do
    {:noreply,
     socket
     |> assign(:current_filter, filter_type)
     |> push_event("filter-graph", %{filterType: filter_type})}
  end

  @impl true
  def handle_event("change-layout", %{"layout" => layout_name}, socket) do
    {:noreply, push_event(socket, "change-layout", %{layoutName: layout_name})}
  end

  @impl true
  def handle_event("copy-prompt", %{"template-id" => template_id}, socket) do
    case PromptBase.get_prompt_template(template_id) do
      {:ok, template} ->
        # In a real implementation, you'd use JavaScript to copy to clipboard
        # For now, we'll just show a success message
        {:noreply,
         socket
         |> assign(:copied_template, template)
         |> put_flash(:info, "Prompt template copied to clipboard!")}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Failed to load prompt template")}
    end
  end

  @impl true
  def handle_event("copy-node-prompt", %{"concept-id" => concept_id}, socket) do
    # Generate a contextualized prompt for working with this concept
    node_prompt = generate_concept_prompt(concept_id, socket.assigns.manifest)

    {:noreply,
     socket
     |> assign(:copied_template, %{"name" => "Concept: #{concept_id}", "template" => node_prompt})
     |> put_flash(:info, "Concept prompt ready to copy!")}
  end

  @impl true
  def handle_event("close-modal", _params, socket) do
    {:noreply, assign(socket, :copied_template, nil)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <style>
      .prompt-base-container { width: 100%; min-height: calc(100vh - 200px); display: flex; flex-direction: column; padding: 1.5rem; background-color: #f9fafb; }
      .pb-main { flex: 1; display: flex; gap: 1rem; height: 600px; }
      .pb-graph-container { flex: 1; background-color: white; border-radius: 0.5rem; box-shadow: 0 1px 3px rgba(0,0,0,0.1); overflow: hidden; min-height: 600px; }
      .graph-canvas { width: 100%; height: 100%; min-height: 600px; }
      .pb-detail-panel { width: 24rem; background-color: white; border-radius: 0.5rem; box-shadow: 0 1px 3px rgba(0,0,0,0.1); padding: 1.5rem; overflow-y: auto; max-height: 600px; }
      .filter-btn { padding: 0.5rem 1rem; font-size: 0.875rem; font-weight: 500; color: #374151; background-color: white; border: 1px solid #d1d5db; border-radius: 0.375rem; cursor: pointer; }
      .filter-btn.active { background-color: #2563eb; color: white; border-color: #2563eb; }
      .copy-prompt-btn { width: 100%; padding: 0.5rem 1rem; font-size: 0.875rem; font-weight: 500; color: white; background-color: #2563eb; border-radius: 0.375rem; cursor: pointer; }
      .node-type-badge { display: inline-block; padding: 0.25rem 0.75rem; font-size: 0.75rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; border-radius: 9999px; background-color: #e3f2fd; color: #1565c0; }
    </style>
    <div class="prompt-base-container">
      <div class="pb-header">
        <h1 class="text-3xl font-bold">PromptBase Knowledge Graph</h1>
        <p class="text-gray-600 mt-2">
          Interactive visualization of the Olivia site architecture, patterns, and conventions
        </p>
      </div>

      <div class="pb-controls">
        <div class="filter-buttons">
          <button
            phx-click="filter-graph"
            phx-value-type="all"
            class={["filter-btn", @current_filter == "all" && "active"]}
          >
            All
          </button>
          <button
            phx-click="filter-graph"
            phx-value-type="concepts"
            class={["filter-btn", @current_filter == "concepts" && "active"]}
          >
            Concepts
          </button>
          <button
            phx-click="filter-graph"
            phx-value-type="adrs"
            class={["filter-btn", @current_filter == "adrs" && "active"]}
          >
            ADRs
          </button>
          <button
            phx-click="filter-graph"
            phx-value-type="patterns"
            class={["filter-btn", @current_filter == "patterns" && "active"]}
          >
            Patterns
          </button>
          <button
            phx-click="filter-graph"
            phx-value-type="relationships"
            class={["filter-btn", @current_filter == "relationships" && "active"]}
          >
            Relationships
          </button>
        </div>

        <div class="layout-buttons">
          <label class="text-sm font-medium text-gray-700">Layout:</label>
          <button phx-click="change-layout" phx-value-layout="cose" class="layout-btn">
            Force
          </button>
          <button phx-click="change-layout" phx-value-layout="circle" class="layout-btn">
            Circle
          </button>
          <button phx-click="change-layout" phx-value-layout="grid" class="layout-btn">
            Grid
          </button>
          <button phx-click="change-layout" phx-value-layout="breadthfirst" class="layout-btn">
            Hierarchy
          </button>
        </div>
      </div>

      <div class="pb-main">
        <div class="pb-graph-container">
          <div
            id="prompt-base-graph"
            phx-hook="PromptBaseGraph"
            data-graph={Jason.encode!(@graph_data)}
            class="graph-canvas"
          >
          </div>
        </div>

        <div class="pb-detail-panel">
          <%= if @selected_node do %>
            <div class="detail-content">
              <h2 class="text-xl font-bold mb-2"><%= @selected_node.data["label"] %></h2>

              <div class="node-type-badge">
                <%= @selected_node.type %>
              </div>

              <%= if @selected_node.type == "concept" do %>
                <div class="mt-4 space-y-3">
                  <div>
                    <h3 class="font-semibold text-sm text-gray-700">Domain</h3>
                    <p class="text-gray-900"><%= @selected_node.data["domain"] %></p>
                  </div>

                  <div>
                    <h3 class="font-semibold text-sm text-gray-700">Schema</h3>
                    <code class="text-sm bg-gray-100 px-2 py-1 rounded">
                      <%= @selected_node.data["schema"] %>
                    </code>
                  </div>

                  <div>
                    <h3 class="font-semibold text-sm text-gray-700">Location</h3>
                    <code class="text-xs bg-gray-100 px-2 py-1 rounded block">
                      <%= @selected_node.data["location"] %>
                    </code>
                  </div>

                  <%= if @selected_node.data["description"] do %>
                    <div>
                      <h3 class="font-semibold text-sm text-gray-700">Description</h3>
                      <p class="text-sm text-gray-600"><%= @selected_node.data["description"] %></p>
                    </div>
                  <% end %>

                  <%= if @selected_node.data["admin_ui"] do %>
                    <div>
                      <h3 class="font-semibold text-sm text-gray-700">Admin UI</h3>
                      <p class="text-sm">
                        Route: <code class="bg-gray-100 px-1">
                          <%= @selected_node.data["admin_ui"]["route"] %>
                        </code>
                      </p>
                    </div>
                  <% end %>

                  <%= if length(@selected_node.data["invariants"] || []) > 0 do %>
                    <div>
                      <h3 class="font-semibold text-sm text-gray-700">Invariants</h3>
                      <ul class="text-sm list-disc list-inside">
                        <%= for invariant <- @selected_node.data["invariants"] do %>
                          <li><%= invariant["description"] %></li>
                        <% end %>
                      </ul>
                    </div>
                  <% end %>

                  <button
                    phx-click="copy-node-prompt"
                    phx-value-concept-id={@selected_node.id}
                    class="copy-prompt-btn"
                  >
                    Generate Prompt for this Concept
                  </button>
                </div>
              <% end %>

              <%= if @selected_node.type == "adr" do %>
                <div class="mt-4 space-y-3">
                  <div>
                    <h3 class="font-semibold text-sm text-gray-700">Status</h3>
                    <span class="inline-block px-2 py-1 text-xs font-semibold text-white bg-green-500 rounded">
                      <%= @selected_node.data["status"] %>
                    </span>
                  </div>

                  <%= if @selected_node.data["rationale"] do %>
                    <div>
                      <h3 class="font-semibold text-sm text-gray-700">Rationale</h3>
                      <p class="text-sm text-gray-600"><%= @selected_node.data["rationale"] %></p>
                    </div>
                  <% end %>

                  <%= if @selected_node.data["implications"] do %>
                    <div>
                      <h3 class="font-semibold text-sm text-gray-700">Implications</h3>
                      <ul class="text-sm list-disc list-inside">
                        <%= for implication <- @selected_node.data["implications"] do %>
                          <li><%= implication %></li>
                        <% end %>
                      </ul>
                    </div>
                  <% end %>
                </div>
              <% end %>

              <%= if @selected_node.type == "pattern" do %>
                <div class="mt-4 space-y-3">
                  <%= if @selected_node.data["description"] do %>
                    <div>
                      <h3 class="font-semibold text-sm text-gray-700">Description</h3>
                      <p class="text-sm text-gray-600"><%= @selected_node.data["description"] %></p>
                    </div>
                  <% end %>

                  <%= if length(@selected_node.data["steps"] || []) > 0 do %>
                    <div>
                      <h3 class="font-semibold text-sm text-gray-700">Steps</h3>
                      <ol class="text-sm list-decimal list-inside space-y-1">
                        <%= for step <- @selected_node.data["steps"] do %>
                          <li><%= step["title"] %></li>
                        <% end %>
                      </ol>
                    </div>
                  <% end %>

                  <%= if length(@selected_node.data["reference_implementations"] || []) > 0 do %>
                    <div>
                      <h3 class="font-semibold text-sm text-gray-700">Reference Implementations</h3>
                      <ul class="text-xs list-disc list-inside">
                        <%= for ref <- @selected_node.data["reference_implementations"] do %>
                          <li><code class="bg-gray-100 px-1"><%= ref %></code></li>
                        <% end %>
                      </ul>
                    </div>
                  <% end %>
                </div>
              <% end %>
            </div>
          <% else %>
            <div class="detail-placeholder">
              <p class="text-gray-500 text-center">
                Click on a node in the graph to see details
              </p>
            </div>
          <% end %>
        </div>
      </div>

      <div class="pb-templates">
        <h2 class="text-xl font-bold mb-4">Prompt Templates</h2>
        <div class="templates-grid">
          <%= for template <- @templates do %>
            <div class="template-card">
              <h3 class="font-semibold"><%= template["name"] %></h3>
              <p class="text-sm text-gray-600 mt-1"><%= template["description"] %></p>
              <button
                phx-click="copy-prompt"
                phx-value-template-id={template["id"]}
                class="mt-2 text-sm text-blue-600 hover:text-blue-800"
              >
                Copy Template
              </button>
            </div>
          <% end %>
        </div>
      </div>

      <%= if @copied_template do %>
        <div class="copy-modal">
          <div class="copy-modal-content">
            <h3 class="text-lg font-bold mb-2"><%= @copied_template["name"] %></h3>
            <textarea
              id="prompt-textarea"
              phx-hook="CopyToClipboard"
              class="prompt-textarea"
              readonly
            ><%= @copied_template["template"] || inspect(@copied_template, pretty: true) %></textarea>
            <button phx-click="close-modal" class="close-modal-btn">Close</button>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  defp generate_concept_prompt(concept_id, manifest) do
    concepts = manifest["core_concepts"] || []
    concept = Enum.find(concepts, fn c -> c["id"] == concept_id end)

    if concept do
      """
      # Context: Working with #{concept["name"]}

      You are working on the Olivia Portfolio Site.

      ## Concept Overview
      - **Name**: #{concept["name"]}
      - **Domain**: #{concept["domain"]}
      - **Schema**: #{concept["schema"]}
      - **Location**: #{concept["location"]}

      ## Description
      #{concept["description"]}

      ## Key Conventions
      #{format_invariants(concept["invariants"] || [])}

      ## Admin Interface
      #{format_admin_ui(concept["admin_ui"])}

      ## Task
      [Describe your task here related to #{concept["name"]}]

      Please ensure you follow all conventions and invariants defined above.
      """
    else
      "Concept not found: #{concept_id}"
    end
  end

  defp format_invariants([]), do: "No specific invariants defined."

  defp format_invariants(invariants) do
    invariants
    |> Enum.map(fn inv -> "- #{inv["description"]}" end)
    |> Enum.join("\n")
  end

  defp format_admin_ui(nil), do: "No admin interface defined."

  defp format_admin_ui(admin_ui) do
    "Route: `#{admin_ui["route"]}`"
  end
end
