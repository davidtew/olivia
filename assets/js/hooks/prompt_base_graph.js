import cytoscape from 'cytoscape';

/**
 * PromptBase Graph Hook
 *
 * Renders and manages the Cytoscape.js knowledge graph visualization
 * for the PromptBase system.
 */
export const PromptBaseGraph = {
  mounted() {
    this.initializeGraph();
    this.setupEventListeners();
  },

  updated() {
    // Reload graph if data changes
    if (this.cy) {
      this.cy.destroy();
    }
    this.initializeGraph();
  },

  destroyed() {
    if (this.cy) {
      this.cy.destroy();
    }
  },

  initializeGraph() {
    const graphData = JSON.parse(this.el.dataset.graph);

    this.cy = cytoscape({
      container: this.el,

      elements: {
        nodes: graphData.nodes,
        edges: graphData.edges
      },

      style: [
        // Concept nodes (domain models)
        {
          selector: 'node[type="concept"]',
          style: {
            'background-color': '#4A90E2',
            'label': 'data(label)',
            'width': 100,
            'height': 100,
            'text-valign': 'center',
            'text-halign': 'center',
            'font-size': 14,
            'font-weight': 'bold',
            'color': '#fff',
            'text-outline-width': 2,
            'text-outline-color': '#4A90E2',
            'border-width': 3,
            'border-color': '#2E5C8A',
            'shape': 'ellipse'
          }
        },

        // ADR nodes (architectural decisions)
        {
          selector: 'node[type="adr"]',
          style: {
            'background-color': '#F5A623',
            'label': 'data(label)',
            'shape': 'rectangle',
            'width': 120,
            'height': 70,
            'text-valign': 'center',
            'text-halign': 'center',
            'font-size': 12,
            'font-weight': 'bold',
            'color': '#fff',
            'text-outline-width': 2,
            'text-outline-color': '#F5A623',
            'border-width': 3,
            'border-color': '#C47F1A',
            'text-wrap': 'wrap',
            'text-max-width': 110
          }
        },

        // Pattern nodes
        {
          selector: 'node[type="pattern"]',
          style: {
            'background-color': '#7ED321',
            'label': 'data(label)',
            'shape': 'diamond',
            'width': 120,
            'height': 120,
            'text-valign': 'center',
            'text-halign': 'center',
            'font-size': 12,
            'font-weight': 'bold',
            'color': '#fff',
            'text-outline-width': 2,
            'text-outline-color': '#7ED321',
            'border-width': 3,
            'border-color': '#5BA218',
            'text-wrap': 'wrap',
            'text-max-width': 100
          }
        },

        // Selected node
        {
          selector: 'node:selected',
          style: {
            'border-width': 5,
            'border-color': '#FF6B6B',
            'overlay-opacity': 0.3,
            'overlay-color': '#FF6B6B'
          }
        },

        // has_many edges
        {
          selector: 'edge[type="has_many"]',
          style: {
            'width': 3,
            'line-color': '#2ECC71',
            'target-arrow-color': '#2ECC71',
            'target-arrow-shape': 'triangle',
            'curve-style': 'bezier',
            'label': 'data(label)',
            'font-size': 10,
            'text-rotation': 'autorotate',
            'text-background-opacity': 1,
            'text-background-color': '#fff',
            'text-background-padding': 3,
            'color': '#2ECC71'
          }
        },

        // belongs_to edges
        {
          selector: 'edge[type="belongs_to"]',
          style: {
            'width': 3,
            'line-color': '#3498DB',
            'target-arrow-color': '#3498DB',
            'target-arrow-shape': 'triangle',
            'curve-style': 'bezier',
            'label': 'data(label)',
            'font-size': 10,
            'text-rotation': 'autorotate',
            'text-background-opacity': 1,
            'text-background-color': '#fff',
            'text-background-padding': 3,
            'color': '#3498DB'
          }
        },

        // constrains edges (from ADRs to concepts)
        {
          selector: 'edge[type="constrains"]',
          style: {
            'width': 2,
            'line-color': '#E74C3C',
            'line-style': 'dashed',
            'target-arrow-color': '#E74C3C',
            'target-arrow-shape': 'triangle',
            'curve-style': 'bezier',
            'label': 'data(label)',
            'font-size': 9,
            'text-rotation': 'autorotate',
            'color': '#E74C3C'
          }
        },

        // applies_to edges (from patterns to concepts)
        {
          selector: 'edge[type="applies_to"]',
          style: {
            'width': 2,
            'line-color': '#9B59B6',
            'line-style': 'dotted',
            'target-arrow-color': '#9B59B6',
            'target-arrow-shape': 'triangle',
            'curve-style': 'bezier',
            'label': 'data(label)',
            'font-size': 9,
            'text-rotation': 'autorotate',
            'color': '#9B59B6'
          }
        }
      ],

      layout: {
        name: 'cose',
        animate: true,
        animationDuration: 500,
        nodeRepulsion: 8000,
        idealEdgeLength: 100,
        edgeElasticity: 100,
        nestingFactor: 1.2,
        gravity: 80,
        numIter: 1000,
        initialTemp: 200,
        coolingFactor: 0.95,
        minTemp: 1.0
      },

      minZoom: 0.3,
      maxZoom: 3,
      wheelSensitivity: 0.2
    });

    // Setup node click handler
    this.cy.on('tap', 'node', (evt) => {
      const node = evt.target;
      const nodeData = node.data();

      // Push event to LiveView
      this.pushEvent('node-selected', {
        id: nodeData.id,
        type: nodeData.type,
        data: nodeData
      });
    });

    // Setup background click (deselect)
    this.cy.on('tap', (evt) => {
      if (evt.target === this.cy) {
        this.pushEvent('node-deselected', {});
      }
    });
  },

  setupEventListeners() {
    // Listen for filter events from LiveView
    this.handleEvent('filter-graph', ({ filterType }) => {
      if (!this.cy) return;

      this.cy.elements().hide();

      switch (filterType) {
        case 'concepts':
          this.cy.nodes('[type="concept"]').show();
          this.cy.edges().filter((edge) => {
            const source = edge.source();
            const target = edge.target();
            return source.visible() && target.visible();
          }).show();
          break;

        case 'adrs':
          this.cy.nodes('[type="adr"]').show();
          this.cy.nodes('[type="concept"]').show(); // Show concepts connected to ADRs
          this.cy.edges('[type="constrains"]').show();
          break;

        case 'patterns':
          this.cy.nodes('[type="pattern"]').show();
          this.cy.nodes('[type="concept"]').show(); // Show concepts connected to patterns
          this.cy.edges('[type="applies_to"]').show();
          break;

        case 'relationships':
          this.cy.nodes('[type="concept"]').show();
          this.cy.edges('[type="has_many"], edge[type="belongs_to"]').show();
          break;

        case 'all':
        default:
          this.cy.elements().show();
          break;
      }

      // Re-run layout for visible elements
      this.cy.elements().layout({
        name: 'cose',
        animate: true,
        animationDuration: 300
      }).run();
    });

    // Listen for layout change events
    this.handleEvent('change-layout', ({ layoutName }) => {
      if (!this.cy) return;

      this.cy.elements().layout({
        name: layoutName,
        animate: true,
        animationDuration: 500
      }).run();
    });
  }
};
