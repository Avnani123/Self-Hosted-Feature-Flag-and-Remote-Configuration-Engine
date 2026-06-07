import json
import os

# Locate the config.json file relative to this script
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CONFIG_PATH = os.path.join(BASE_DIR, "data", "config.json")

def read_config():
    """Reads the current feature flags and configurations from the JSON file."""
    try:
        with open(CONFIG_PATH, "r") as file:
            return json.load(file)
    except FileNotFoundError:
        # Fallback dictionary if file doesn't exist
        return {"flags": {}, "configs": {}}

def update_flag(flag_name: str, status: bool):
    """Toggles a specific feature flag's status and saves it."""
    data = read_config()
    if flag_name in data["flags"]:
        data["flags"][flag_name]["status"] = status
        with open(CONFIG_PATH, "w") as file:
            json.dump(data, file, indent=2)
        return True
    return False

def update_config_variable(config_name: str, value):
    """Updates a remote configuration variable text/number value and saves it."""
    data = read_config()
    if config_name in data["configs"]:
        data["configs"][config_name] = value
        with open(CONFIG_PATH, "w") as file:
            json.dump(data, file, indent=2)
        return True
    return False