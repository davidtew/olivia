import cytoscape from 'cytoscape'

export const SpatialCanvas = {
  mounted() {
    // Add visible DOM feedback
    this.el.style.borderColor = 'red'
    this.el.setAttribute('data-hook-status', 'mounting')

    try {
      this.initializeCytoscape()
      this.setupEventHandlers()
      this.setupDropZone()
      this.el.setAttribute('data-hook-status', 'ready')
      this.el.style.borderColor = '#4F46E5'
    } catch (error) {
      this.el.setAttribute('data-hook-status', 'error: ' + error.message)
      this.el.style.borderColor = 'orange'
      console.error('Error initializing SpatialCanvas:', error)
    }
  },

  initializeCytoscape() {
    this.cy = cytoscape({
      container: this.el,

      style: [
        {
          selector: 'node',
          style: {
            'background-image': 'data(image)',
            'background-fit': 'cover',
            'background-clip': 'none',
            'width': 150,
            'height': 150,
            'border-width': 3,
            'border-color': '#4F46E5',
            'border-opacity': 0.5
          }
        },
        {
          selector: 'node:selected',
          style: {
            'border-color': '#4F46E5',
            'border-opacity': 1,
            'border-width': 4
          }
        },
        {
          selector: 'edge',
          style: {
            'width': 3,
            'line-color': '#94A3B8',
            'target-arrow-color': '#94A3B8',
            'target-arrow-shape': 'triangle',
            'curve-style': 'bezier'
          }
        },
        {
          selector: 'edge:selected',
          style: {
            'line-color': '#4F46E5',
            'target-arrow-color': '#4F46E5',
            'width': 4
          }
        }
      ],

      layout: {
        name: 'preset'
      },

      minZoom: 0.3,
      maxZoom: 2
    })

    // Expose for debugging in console if needed
    window.debugCy = this.cy

    // Load initial data if provided
    const initialData = this.el.dataset.initialData
    if (initialData) {
      try {
        const data = JSON.parse(initialData)
        this.loadGraphData(data)
      } catch (e) {
        console.error('SpatialCanvas: Failed to load initial data:', e)
      }
    }
  },

  setupEventHandlers() {
    // Update export button whenever graph changes
    this.updateExportButton()

    // Node drag end - update positions
    this.cy.on('dragfree', 'node', (evt) => {
      const node = evt.target
      this.pushEvent('node_moved', {
        id: node.id(),
        position: node.position()
      })
      this.updateExportButton()
    })

    // Node selection
    this.cy.on('select', 'node', (evt) => {
      const node = evt.target
      this.pushEvent('node_selected', {
        id: node.id(),
        media_id: node.data('media_id')
      })
    })

    // Edge creation (Ctrl+Click on node, then Ctrl+Click on target)
    let edgeSourceNode = null
    this.cy.on('cxttap', 'node', (evt) => {
      const node = evt.target

      if (edgeSourceNode === null) {
        // First node - mark as source
        edgeSourceNode = node
        node.style('border-color', '#10B981')
        node.style('border-width', 5)
      } else {
        // Second node - create edge
        this.pushEvent('create_edge', {
          source_id: edgeSourceNode.id(),
          target_id: node.id()
        })

        // Reset source node styling
        edgeSourceNode.style('border-color', '#4F46E5')
        edgeSourceNode.style('border-width', 3)
        edgeSourceNode = null
      }
    })

    // Cancel edge creation on background click
    this.cy.on('tap', (evt) => {
      if (evt.target === this.cy && edgeSourceNode) {
        edgeSourceNode.style('border-color', '#4F46E5')
        edgeSourceNode.style('border-width', 3)
        edgeSourceNode = null
      }
    })

    // Delete selected elements on Delete/Backspace key
    document.addEventListener('keydown', (e) => {
      if ((e.key === 'Delete' || e.key === 'Backspace') && !this.isInputFocused()) {
        const selectedNodes = this.cy.$('node:selected')
        const selectedEdges = this.cy.$('edge:selected')

        if (selectedNodes.length > 0) {
          const nodeIds = selectedNodes.map(n => n.id())
          this.pushEvent('delete_nodes', { node_ids: nodeIds })
        } else if (selectedEdges.length > 0) {
          const edgeIds = selectedEdges.map(e => e.id())
          this.pushEvent('delete_edges', { edge_ids: edgeIds })
        }
      }
    })

    // Handle events from server
    this.handleEvent('add_node', (data) => {
      this.addNode(data)
      this.updateExportButton()
    })

    this.handleEvent('add_edge', (data) => {
      this.addEdge(data)
      this.updateExportButton()
    })

    this.handleEvent('remove_nodes', (data) => {
      data.node_ids.forEach(id => {
        this.cy.getElementById(id).remove()
      })
      this.updateExportButton()
    })

    this.handleEvent('remove_edges', (data) => {
      data.edge_ids.forEach(id => {
        this.cy.getElementById(id).remove()
      })
      this.updateExportButton()
    })

    this.handleEvent('clear_canvas', () => {
      this.cy.elements().remove()
      this.updateExportButton()
    })

    this.handleEvent('load_graph', (data) => {
      this.loadGraphData(data)
      this.updateExportButton()
    })

    this.handleEvent('apply_layout', (data) => {
      const layout = this.cy.layout({
        name: data.layout_type || 'grid',
        animate: true,
        animationDuration: 500
      })
      layout.run()
    })
  },

  setupDropZone() {
    const handleDragOver = (e) => {
      e.preventDefault()
      e.stopPropagation()
      this.el.classList.add('drag-over')
    }

    const handleDragLeave = (e) => {
      e.preventDefault()
      e.stopPropagation()
      this.el.classList.remove('drag-over')
    }

    const handleDrop = (e) => {
      e.preventDefault()
      e.stopPropagation()
      this.el.classList.remove('drag-over')

      const mediaId = e.dataTransfer.getData('media-id')
      const imageUrl = e.dataTransfer.getData('image-url')

      if (mediaId && imageUrl) {
        const canvasPos = this.getCanvasPosition(e.clientX, e.clientY)

        this.pushEvent('add_node_from_palette', {
          media_id: parseInt(mediaId),
          image_url: imageUrl,
          position: canvasPos
        })
      } else {
        console.error('SpatialCanvas: Missing data - mediaId or imageUrl is empty')
      }
    }

    this.el.addEventListener('dragover', handleDragOver)
    this.el.addEventListener('dragleave', handleDragLeave)
    this.el.addEventListener('drop', handleDrop)

    const cyContainer = this.cy.container()
    if (cyContainer && cyContainer !== this.el) {
      cyContainer.addEventListener('dragover', handleDragOver)
      cyContainer.addEventListener('dragleave', handleDragLeave)
      cyContainer.addEventListener('drop', handleDrop)
    }
  },

  getCanvasPosition(clientX, clientY) {
    const rect = this.el.getBoundingClientRect()
    const x = clientX - rect.left
    const y = clientY - rect.top

    // Convert viewport coordinates to canvas coordinates
    const pan = this.cy.pan()
    const zoom = this.cy.zoom()

    return {
      x: (x - pan.x) / zoom,
      y: (y - pan.y) / zoom
    }
  },

  addNode(data) {
    this.cy.add({
      group: 'nodes',
      data: {
        id: data.id,
        media_id: data.media_id,
        image: data.image_url
      },
      position: data.position
    })
  },

  addEdge(data) {
    this.cy.add({
      group: 'edges',
      data: {
        id: data.id,
        source: data.source_id,
        target: data.target_id
      }
    })
  },

  loadGraphData(data) {
    this.cy.elements().remove()

    // Add nodes
    if (data.nodes) {
      data.nodes.forEach(node => {
        this.cy.add({
          group: 'nodes',
          data: {
            id: node.id,
            media_id: node.media_id,
            image: node.image_url
          },
          position: { x: node.position_x, y: node.position_y }
        })
      })
    }

    // Add edges
    if (data.edges) {
      data.edges.forEach(edge => {
        this.cy.add({
          group: 'edges',
          data: {
            id: edge.id,
            source: edge.source_id,
            target: edge.target_id
          }
        })
      })
    }

    // Fit to viewport
    if (this.cy.elements().length > 0) {
      this.cy.fit(null, 50)
    }
  },

  isInputFocused() {
    const active = document.activeElement
    return active && (active.tagName === 'INPUT' || active.tagName === 'TEXTAREA')
  },

  updateExportButton() {
    const exportBtn = document.getElementById('export-spatial-data-btn')
    if (!exportBtn) return

    const nodes = this.cy.nodes().map(n => ({
      id: n.id(),
      media_id: n.data('media_id'),
      position: n.position(),
      image_url: n.data('image')
    }))

    const edges = this.cy.edges().map(e => ({
      id: e.id(),
      source_id: e.data('source'),
      target_id: e.data('target')
    }))

    const exportData = {
      timestamp: new Date().toISOString(),
      node_count: nodes.length,
      edge_count: edges.length,
      nodes: nodes,
      edges: edges
    }

    exportBtn.setAttribute('data-copy-text', JSON.stringify(exportData, null, 2))
  },

  destroyed() {
    if (this.cy) {
      this.cy.destroy()
    }
  }
}
