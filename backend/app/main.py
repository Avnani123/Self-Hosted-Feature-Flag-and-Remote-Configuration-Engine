import os
import sys
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# Force path recognition for modules
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
from backend.app.config_store import read_config, write_config

app = FastAPI(title="Feature Flag Engine Backend")

# Enable CORS so your local dashboard can talk to it seamlessly
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/api/config")
def get_config():
    return read_config()

@app.post("/api/config")
def update_config(new_config: dict):
    write_config(new_config)
    return {"status": "success", "data": read_config()}

# FIX: Added the exact route your TUI dashboard is hitting to handle live toggles
@app.post("/toggle-flag")
def toggle_flag(name: str, status: str):
    # Convert query parameter status string to native boolean
    bool_status = status.lower() == "true"
    
    current_config = read_config()
    
    # Safely modify the flag item's status while keeping description/rules intact
    if "flags" in current_config and name in current_config["flags"]:
        current_config["flags"][name]["status"] = bool_status
        write_config(current_config)
        return {"status": "success", "message": f"Updated {name} to {bool_status}"}
        
    return {"status": "error", "message": "Flag not found in configuration system"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("backend.app.main:app", host="127.0.0.1", port=8000, reload=True)