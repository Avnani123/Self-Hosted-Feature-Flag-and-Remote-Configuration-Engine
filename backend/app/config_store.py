import os
import json

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CONFIG_PATH = os.path.join(BASE_DIR, "data", "config.json")

def read_config():
    """Reads the current configuration from config.json with BOM protection"""
    try:
        if not os.path.exists(CONFIG_PATH):
            default_config = {
                "flags": {
                    "new_checkout_flow": {"status": False},
                    "dark_mode_beta": {"status": False},
                    "ai_recommendations": {"status": True}
                },
                "configs": {
                    "welcome_message": "Welcome to the App!"
                }
            }
            write_config(default_config)
            return default_config
            
        # FIX: Changed encoding to 'utf-8-sig' to automatically strip the invisible BOM character marker
        with open(CONFIG_PATH, "r", encoding="utf-8-sig") as file:
            return json.load(file)
    except Exception as e:
        print(f"Error reading config: {e}")
        return {"flags": {}, "configs": {}}

def write_config(new_config):
    """Writes the updated configuration back to config.json"""
    try:
        os.makedirs(os.path.dirname(CONFIG_PATH), exist_ok=True)
        with open(CONFIG_PATH, "w", encoding="utf-8") as file:
            json.dump(new_config, file, indent=4)
        return True
    except Exception as e:
        print(f"Error writing config: {e}")
        return False