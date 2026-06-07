import json
import os
from pathlib import Path

# Build the path relative to this file's directory:
# config_store.py is in backend/app/ -> parent is backend/ -> data/config.json
CONFIG_PATH = Path(__file__).resolve().parent.parent / "data" / "config.json"

# Your existing path config setup remains above this line...

def read_config():
    """Reads the current feature flags and configurations from the JSON file securely."""
    try:
        # Changing encoding to 'utf-8-sig' strips away the 'ï»¿' mark automatically!
        with open(CONFIG_PATH, "r", encoding="utf-8-sig") as file:
            return json.load(file)
    except FileNotFoundError:
        return {"flags": {}, "configs": {}}
    except json.JSONDecodeError:
        # Fallback if the json is temporarily malformed or blank
        return {"flags": {}, "configs": {}}