import { useState, useCallback, useRef } from "react";
import ReactFlow, {
  MiniMap,
  Controls,
  Background,
  useNodesState,
  useEdgesState,
  addEdge,
  Panel,
  MarkerType,
} from "reactflow";
import "reactflow/dist/style.css";
import { initialNodes, initialEdges } from "./flowData";
import "./App.css";

function App() {
  const [nodes, setNodes, onNodesChange] = useNodesState(initialNodes);
  const [edges, setEdges, onEdgesChange] = useEdgesState(
    initialEdges.map((edge) => ({
      ...edge,
      markerEnd: { type: MarkerType.ArrowClosed },
    }))
  );
  const [selectedNode, setSelectedNode] = useState(null);
  const reactFlowWrapper = useRef(null);

  const onConnect = useCallback(
    (params) =>
      setEdges((eds) =>
        addEdge({ ...params, markerEnd: { type: MarkerType.ArrowClosed } }, eds)
      ),
    [setEdges]
  );

  const onNodeClick = useCallback((event, node) => {
    setSelectedNode(node);
  }, []);

  const updateNodeLabel = useCallback(
    (nodeId, newLabel) => {
      setNodes((nds) =>
        nds.map((node) => {
          if (node.id === nodeId) {
            return {
              ...node,
              data: { ...node.data, label: newLabel },
            };
          }
          return node;
        })
      );
    },
    [setNodes]
  );

  const addNewNode = useCallback(() => {
    const newNode = {
      id: `node_${Date.now()}`,
      type: "default",
      position: { x: 250, y: 100 },
      data: { label: "New Node" },
    };
    setNodes((nds) => [...nds, newNode]);
  }, [setNodes]);

  const deleteNode = useCallback(
    (nodeId) => {
      setNodes((nds) => nds.filter((node) => node.id !== nodeId));
      setEdges((eds) =>
        eds.filter((edge) => edge.source !== nodeId && edge.target !== nodeId)
      );
      setSelectedNode(null);
    },
    [setNodes, setEdges]
  );

  const exportToJSON = useCallback(() => {
    const flowData = {
      nodes: nodes,
      edges: edges,
    };
    const dataStr = JSON.stringify(flowData, null, 2);
    const dataBlob = new Blob([dataStr], { type: "application/json" });
    const url = URL.createObjectURL(dataBlob);
    const link = document.createElement("a");
    link.href = url;
    link.download = "sop-flowchart.json";
    link.click();
    URL.revokeObjectURL(url);
  }, [nodes, edges]);

  const exportToMermaid = useCallback(() => {
    let mermaidCode = "flowchart TD\n";

    nodes.forEach((node) => {
      const label = node.data.label.replace(/\n/g, "<br/>");
      const nodeType =
        node.type === "input" || node.type === "output"
          ? `([${label}])`
          : `[${label}]`;
      mermaidCode += `    ${node.id}${nodeType}\n`;
    });

    mermaidCode += "\n";

    edges.forEach((edge) => {
      const label = edge.label ? `|${edge.label}|` : "";
      mermaidCode += `    ${edge.source} -->${label} ${edge.target}\n`;
    });

    const dataBlob = new Blob([mermaidCode], { type: "text/plain" });
    const url = URL.createObjectURL(dataBlob);
    const link = document.createElement("a");
    link.href = url;
    link.download = "sop-flowchart.mmd";
    link.click();
    URL.revokeObjectURL(url);
  }, [nodes, edges]);

  return (
    <div style={{ width: "100vw", height: "100vh", display: "flex" }}>
      {/* Sidebar */}
      <div className="sidebar">
        <h2>SOP Flow Editor</h2>

        <div className="controls-section">
          <h3>🔧 Controls</h3>
          <button onClick={addNewNode} className="btn btn-primary">
            ➕ Add Node
          </button>
          <button onClick={exportToJSON} className="btn btn-success">
            💾 Export JSON
          </button>
          <button onClick={exportToMermaid} className="btn btn-success">
            📄 Export Mermaid
          </button>
        </div>

        {selectedNode && (
          <div className="node-editor">
            <h3>✏️ Edit Node</h3>
            <div className="form-group">
              <label>Node ID:</label>
              <input type="text" value={selectedNode.id} disabled />
            </div>
            <div className="form-group">
              <label>Label:</label>
              <textarea
                value={selectedNode.data.label}
                onChange={(e) =>
                  updateNodeLabel(selectedNode.id, e.target.value)
                }
                rows={3}
              />
            </div>
            <div className="form-group">
              <label>Position:</label>
              <div className="position-inputs">
                <input
                  type="number"
                  placeholder="X"
                  value={Math.round(selectedNode.position.x)}
                  disabled
                />
                <input
                  type="number"
                  placeholder="Y"
                  value={Math.round(selectedNode.position.y)}
                  disabled
                />
              </div>
            </div>
            <button
              onClick={() => deleteNode(selectedNode.id)}
              className="btn btn-danger"
            >
              🗑️ Delete Node
            </button>
          </div>
        )}

        <div className="legend">
          <h3>📖 Legend</h3>
          <div className="legend-item">
            <div
              className="legend-color"
              style={{ background: "#90EE90" }}
            ></div>
            <span>Start Point</span>
          </div>
          <div className="legend-item">
            <div
              className="legend-color"
              style={{ background: "#FFB6C1" }}
            ></div>
            <span>End Point</span>
          </div>
          <div className="legend-item">
            <div
              className="legend-color"
              style={{ background: "#FFE4B5" }}
            ></div>
            <span>Decision</span>
          </div>
          <div className="legend-item">
            <div
              className="legend-color"
              style={{ background: "#87CEEB" }}
            ></div>
            <span>Review/Complete</span>
          </div>
          <div className="legend-item">
            <div
              className="legend-color"
              style={{ background: "#DDA0DD" }}
            ></div>
            <span>Validation</span>
          </div>
          <div className="legend-item">
            <div
              className="legend-color"
              style={{ background: "#FFA500" }}
            ></div>
            <span>DNQ Process</span>
          </div>
        </div>

        <div className="instructions">
          <h3>ℹ️ Instructions</h3>
          <ul>
            <li>Click and drag nodes to reposition</li>
            <li>Click a node to edit its label</li>
            <li>Connect nodes by dragging from handles</li>
            <li>Use mouse wheel to zoom</li>
            <li>Export JSON for data structure</li>
            <li>Export Mermaid for diagram code</li>
          </ul>
        </div>
      </div>

      {/* Flow Canvas */}
      <div ref={reactFlowWrapper} style={{ flexGrow: 1 }}>
        <ReactFlow
          nodes={nodes}
          edges={edges}
          onNodesChange={onNodesChange}
          onEdgesChange={onEdgesChange}
          onConnect={onConnect}
          onNodeClick={onNodeClick}
          fitView
          attributionPosition="bottom-right"
        >
          <Controls />
          <MiniMap
            nodeColor={(node) => {
              if (node.style?.background) return node.style.background;
              return "#ffffff";
            }}
            nodeStrokeWidth={3}
            zoomable
            pannable
          />
          <Background variant="dots" gap={12} size={1} />
          <Panel position="top-right" className="info-panel">
            <div>
              <strong>Nodes:</strong> {nodes.length} | <strong>Edges:</strong>{" "}
              {edges.length}
            </div>
          </Panel>
        </ReactFlow>
      </div>
    </div>
  );
}

export default App;
