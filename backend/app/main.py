from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from .config_store import read_config, update_flag, update_config_variable
import asyncio
import json

app = FastAPI(title="Feature Flag Engine")

# Keep track of all active Flutter client connections
active_connections: list[WebSocket] = []

async def broadcast_config():
    """Broadcasts the latest config.json state to all connected Flutter clients."""
    if not active_connections:
        return
        
    current_config = read_config()
    # Convert payload to clean JSON string
    payload = json.dumps(current_config)
    
    # Send to every connected device concurrently
    await asyncio.gather(
        *[connection.send_text(payload) for connection in active_connections]
    )

@app.get("/config")
def get_current_config():
    """Rest API endpoint to fetch the current config state anytime."""
    return read_config()

@app.post("/toggle-flag")
async def toggle_feature_flag(name: str, status: bool):
    """Endpoint called by the TUI dashboard to change a flag's status."""
    success = update_flag(name, status)
    if success:
        # Alert all connected Flutter apps immediately!
        await broadcast_config()
        return {"status": "success", "message": f"Flag '{name}' set to {status}"}
    return {"status": "error", "message": "Flag not found"}

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    """The live pipeline channel that Flutter clients connect to."""
    await websocket.accept()
    active_connections.append(websocket)
    print(f"📱 Client connected! Total active clients: {len(active_connections)}")
    
    # Immediately send the current state right upon connecting
    try:
        initial_config = read_config()
        await websocket.send_text(json.dumps(initial_config))
        
        # Keep the connection alive; listen for incoming client data if any
        while True:
            # Flutter doesn't need to talk back often, but this keeps the line open
            await websocket.receive_text()
            
    except WebSocketDisconnect:
        active_connections.remove(websocket)
        print(f"🔌 Client disconnected. Total active clients: {len(active_connections)}")