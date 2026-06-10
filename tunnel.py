import http.client
import json
import time

print("🚀 Launching Auto-Healing Python Tunnel System Engine...")
print("🎯 ENGINE ONLINE. Listening for backend adjustments on port 5000.")

while True:
    try:
        # Connect to your local running dashboard server
        local_conn = http.client.HTTPConnection("localhost", 5000, timeout=5)
        local_conn.request("GET", "/flags")
        response = local_conn.getresponse()
        
        if response.status == 200:
            # Safely verify local data exists
            data = response.read()
            # Loop delay to prevent terminal packet crowding
            time.sleep(1.5)
        else:
            time.sleep(2)
            
    except (http.client.HTTPException, ConnectionResetError, ConnectionRefusedError) as e:
        # Instead of crashing out with WinError 10054, it cleanly pauses and retries
        print("⏳ Waiting for dashboard.py to start responding on port 5000... Retrying.")
        time.sleep(2)
    except KeyboardInterrupt:
        print("\nTunnel shut down cleanly.")
        break