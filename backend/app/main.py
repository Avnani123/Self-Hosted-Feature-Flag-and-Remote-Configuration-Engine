from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from .config_store import read_config, update_flag
import asyncio
import json
import hashlib

app = FastAPI(title="Feature Flag & Advanced Targeting Engine")

# Track active client connections along with their optional user context
# Format: { websocket_connection: "user_id" }
active_clients: dict[WebSocket, str] = {}

def evaluate_targeting(flag_details: dict, user_id: str) -> bool:
    """Evaluates if a user qualifies for a feature flag based on explicit rules."""
    if not flag_details.get("status", False):
        return False  # Globally OFF
        
    rule = flag_details.get("rule", "Everyone")
    
    if rule == "Everyone":
        return True
        
    if rule == "Beta Users Only":
        # Hardcoded beta list for prototype simplicity
        beta_users = ["beta_tester@email.com", "dev_user_1"]
        return user_id in beta_users
        
    if "Rollout" in rule:
        try:
            # Extract percentage integer from string like "10% Rollout"
            percentage = int(rule.split("%")[0].strip())
            
            # Deterministic hashing trick to calculate steady rollout distributions
            hash_object = hashlib.md5(f"{user_id}-{flag_details.get('name', '')}".encode())
            hash_score = int(hash_object.hexdigest(), 16) % 100
            
            return hash_score < percentage
        except ValueError:
            return False
            
    return False

async def broadcast_tailored_configs():
    """Broadcasts a unique customized payload to each individual client connection."""
    if not active_clients:
        return
        
    current_config = read_config()
    
    for websocket, user_id in active_clients.items():
        # Build custom flag dictionary evaluated specifically for this user
        tailored_flags = {}
        for flag_name, details in current_config.get("flags", {}).items():
            # Add flag name internally to ensure hash stability
            details['name'] = flag_name 
            tailored_flags[flag_name] = evaluate_targeting(details, user_id)
            
        payload = {
            "flags": tailored_flags,
            "configs": current_config.get("configs", {})
        }
        try:
            await websocket.send_text(json.dumps(payload))
        except Exception:
            pass # Handle dead sockets gracefully during iteration

@app.post("/toggle-flag")
async def toggle_feature_flag(name: str, status: bool, rule: str = "Everyone"):
    """Enhanced dashboard endpoint allowing managers to assign targeting constraints."""
    data = read_config()
    if name in data["flags"]:
        data["flags"][name]["status"] = status
        data["flags"][name]["rule"] = rule
        
        # Save changes to config.json
        import os
        base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        config_path = os.path.join(base_dir, "data", "config.json")
        with open(config_path, "w") as file:
            json.dump(data, file, indent=2)
            
        # Re-evaluate rules and blast updates out instantly!
        await broadcast_tailored_configs()
        return {"status": "success"}
    return {"status": "error", "message": "Flag not found"}

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket, user_id: str = "anonymous_user"):
    """Accepts incoming WebSocket connections and binds them to a specific user context."""
    await websocket.accept()
    active_clients[websocket] = user_id
    print(f"📱 Client Connected: {user_id} | Total lines active: {len(active_clients)}")
    
    try:
        # Trigger an immediate initial computed broadcast to the newly joined client
        await broadcast_tailored_configs()
        while True:
            await websocket.receive_text()
    except WebSocketDisconnect:
        del active_clients[websocket]
        print(f"🔌 Client Disconnected. Total channels: {len(active_clients)}")