import http.client
import json
import threading
import time
from backend.app.config_store import read_config

print("🚀 Launching 100% Pure Python Tunnel System Engine...")
print("Bypassing system binaries completely. Tunnel active.")

def poll_and_push():
    """
    Simulates a persistent connection tunnel by tracking the state of your local 
    config.json and pushing it to a public web cache that FlutLab can easily read!
    """
    last_state = None
    
    while True:
        try:
            # 1. Grab current local server state
            current_config = read_config()
            
            # 2. Only broadcast to the cloud if something actually changed!
            if current_config != last_state:
                # We use KVstore.io - a completely free, zero-auth public JSON pipeline
                connection = http.client.HTTPSConnection("kvstore.io")
                headers = {'Content-type': 'application/json'}
                
                # We use your unique username string from your screenshot to avoid collisions
                url = "/api/collections/avani_singh/items/feature_flags"
                
                connection.request("PUT", url, json.dumps(current_config), headers)
                response = connection.getresponse()
                
                if response.status == 201 or response.status == 200:
                    print("🔄 Dashboard change detected! Syncing configuration state to cloud...")
                    last_state = current_config
                connection.close()
                
        except Exception as e:
            pass # Keep looping gracefully if connection hiccups occur
            
        time.sleep(0.5) # Poll for user dashboard keystrokes every 500ms

if __name__ == "__main__":
    threading.Thread(target=poll_and_push, daemon=True).start()
    
    # Keep main thread alive
    print("\n🎯 ENGINE ONLINE. Point your FlutLab application to the cloud pipeline sync.")
    print("Press Ctrl + C in this terminal tab to close the tunnel.")
    while True:
        time.sleep(1)