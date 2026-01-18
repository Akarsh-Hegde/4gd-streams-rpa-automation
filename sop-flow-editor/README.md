# SOP Flow Editor - Interactive Flowchart Editor

An interactive flowchart editor built with ReactFlow for visualizing and editing the RISCOM New Insured Process SOP.

## 🚀 Features

- **Interactive Editing**: Click and drag nodes to reposition them
- **Visual Node Editing**: Click any node to edit its label in the sidebar
- **Connect Nodes**: Drag from node handles to create connections
- **Add/Delete Nodes**: Add new nodes or delete selected ones
- **Export to JSON**: Save your flowchart data structure as JSON
- **Export to Mermaid**: Generate Mermaid diagram code from your flowchart
- **Zoom & Pan**: Use mouse wheel to zoom, drag to pan
- **MiniMap**: Overview of the entire flowchart
- **Color-Coded**: Different node types have different colors

## 📋 Prerequisites

- Node.js 20.9.0 or higher
- npm 10.1.0 or higher

## 🛠️ Installation

Already installed! The project is ready to use.

## 🎮 Usage

### Start the Development Server

The server is already running at: **http://localhost:5173/**

If you need to restart it:

```bash
cd sop-flow-editor
npm run dev
```

### Editing the Flowchart

1. **Move Nodes**: Click and drag any node to reposition it
2. **Edit Node Label**: Click a node to select it, then edit its label in the sidebar
3. **Create Connections**: Hover over a node, drag from the circular handle to another node
4. **Add New Node**: Click "➕ Add Node" button in the sidebar
5. **Delete Node**: Select a node and click "🗑️ Delete Node"
6. **Zoom**: Use mouse wheel to zoom in/out
7. **Pan**: Click and drag on empty canvas area

### Export Your Changes

#### Export as JSON

Click "💾 Export JSON" to download the current flowchart structure as a JSON file. This includes:

- All node positions, labels, and types
- All edge connections
- Node styling information

#### Export as Mermaid

Click "📄 Export Mermaid" to download the flowchart as Mermaid diagram code (.mmd file). You can:

- Use this code in documentation
- View it in the Mermaid HTML viewer
- Share it with others

## 📊 Node Color Legend

- 🟢 **Green** (#90EE90): Start Point
- 🩷 **Pink** (#FFB6C1): End Point / DNQ
- 🔵 **Sky Blue** (#87CEEB): Review/Complete
- 🟡 **Moccasin** (#FFE4B5): Decision Points
- 🟣 **Plum** (#DDA0DD): Validation
- 🟠 **Orange** (#FFA500): DNQ Process

## 🗂️ Project Structure

```
sop-flow-editor/
├── src/
│   ├── App.jsx          # Main React component with editor
│   ├── App.css          # Styling
│   ├── flowData.js      # SOP flowchart data (nodes & edges)
│   └── main.jsx         # Entry point
├── package.json         # Dependencies
└── README.md           # This file
```

## 🔄 Workflow

1. **Edit Visually**: Make changes in the interactive editor
2. **Export JSON**: Save the updated structure
3. **Export Mermaid**: Generate new diagram code
4. **Update Documentation**: Use exported code in your docs

## 💡 Tips

- **Select Multiple Nodes**: Hold Shift and drag to select multiple nodes
- **Delete Edge**: Click on an edge and press Delete/Backspace
- **Fit View**: Use the fit view button (□) in the controls panel
- **Lock Node**: Use the lock button to prevent accidental moves

## 🐛 Troubleshooting

### Server won't start

```bash
cd sop-flow-editor
npm install
npm run dev
```

### Changes not saving

- Changes are in-memory only
- Use Export buttons to save your work
- Refresh the page to reload original data

## 📝 Data Format

### Node Structure

```javascript
{
  id: 'uniqueId',
  type: 'default', // 'input', 'output', or 'default'
  position: { x: 100, y: 200 },
  data: { label: 'Node Label' },
  style: { background: '#color' } // optional
}
```

### Edge Structure

```javascript
{
  id: 'e-source-target',
  source: 'sourceNodeId',
  target: 'targetNodeId',
  label: 'Edge Label', // optional
  markerEnd: { type: MarkerType.ArrowClosed }
}
```

---

**Happy Editing! 🎨**
