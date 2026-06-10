import json
import threading
from http.server import BaseHTTPRequestHandler, HTTPServer
import os
import msvcrt  # Windows-native library for instant key presses

# ==================================================
# 1. LIVE BACKEND STATE CONFIGURATION MAP
# ==================================================
config_data = {
    "new_checkout_flow": True,
    "dark_mode_beta": False,
    "ai_recommendations": True,
    "max_login_attempts": 5
}

# ==================================================
# 2. FILE STORAGE MANAGEMENT
# ==================================================
def save_config_to_disk():
    """Writes the current configuration matrix instantly to config.json"""
    with open("config.json", "w") as f:
        json.dump(config_data, f, indent=4)

# ==================================================
# 3. REAL-TIME HTTP STREAMING SERVER (FOR FLUTLAB)
# ==================================================
class ConfigApiServer(BaseHTTPRequestHandler):
    def do_GET(self):
        """Streams live configuration flags as a JSON payload safely"""
        if self.path == '/flags':
            try:
                self.send_response(200)
                
                # ✅ FIXED: Comprehensive CORS Access Headers to Unblock FlutLab
                self.send_header("Content-Type", "application/json")
                self.send_header("Access-Control-Allow-Origin", "*")
                self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
                self.send_header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept, Authorization")
                self.end_headers()
                
                response_json = json.dumps(config_data)
                self.wfile.write(response_json.encode('utf-8'))
            except Exception:
                # Quietly ignore broken connections or WinErrors without breaking the TUI
                pass
        else:
            try:
                self.send_response(404)
                self.end_headers()
            except Exception:
                pass

    def do_OPTIONS(self):
        """Grants automated browser permission requests instantly"""
        try:
            self.send_response(200)
            
            # ✅ FIXED: Mirroring matching CORS verification headers for pre-flight handshakes
            self.send_header("Access-Control-Allow-Origin", "*")
            self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
            self.send_header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept, Authorization")
            self.end_headers()
        except Exception:
            pass

    def log_message(self, format, *args):
        """Overrides logging to keep the terminal screen completely clean"""
        return

class RobustHTTPServer(HTTPServer):
    def handle_error(self, request, client_address):
        """Catches and suppresses background [WinError 10053/10054] traceback pollution"""
        pass

def run_api_background_server():
    """Spins up the robust web endpoint server on local port 5000"""
    server = RobustHTTPServer(('0.0.0.0', 5000), ConfigApiServer)
    server.serve_forever()

# ==================================================
# 4. TERMINAL INTERACTIVE INTERFACE RENDERER
# ==================================================
def clear_terminal():
    os.system('cls' if os.name == 'nt' else 'clear')

def render_terminal_ui():
    clear_terminal()
    print("==================================================")
    print(" 🚀 FEATURE FLAG & CONFIG MANAGER (VS CODE BACKEND)")
    print("==================================================")
    print("\nACTIVE FLAGS:")
    print(f" [1] new_checkout_flow  : [{'ON ' if config_data['new_checkout_flow'] else 'OFF'}] (Beta Users Only)")
    print(f" [2] dark_mode_beta     : [{'ON ' if config_data['dark_mode_beta'] else 'OFF'}] (Everyone)")
    print(f" [3] ai_recommendations : [{'ON ' if config_data['ai_recommendations'] else 'OFF'}] (Everyone)")
    print("\nCONFIG VARIABLES:")
    print(f" - max_login_attempts   : {config_data['max_login_attempts']}")
    print("==================================================")
    print(" Press [1, 2, 3, 4] to toggle instantly | [Q] Quit")
    print("==================================================")
    print("👇 CLICK HERE TO FOCUS TERMINAL BEFORE TYPING 👇")

def main():
    save_config_to_disk()
    
    # Run network listener inside a detached background worker thread
    api_thread = threading.Thread(target=run_api_background_server, daemon=True)
    api_thread.start()
    
    while True:
        render_terminal_ui()
        
        # Intercept raw keyboard hit immediately (no need to press Enter!)
        char = msvcrt.getch().decode('utf-8').lower()
        
        if char == '1':
            config_data["new_checkout_flow"] = not config_data["new_checkout_flow"]
        elif char == '2':
            config_data["dark_mode_beta"] = not config_data["dark_mode_beta"]
        elif char == '3':
            config_data["ai_recommendations"] = not config_data["ai_recommendations"]
        elif char == '4':
            config_data["max_login_attempts"] = 3 if config_data["max_login_attempts"] == 5 else 5
        elif char == 'q':
            print("\nShutting down control plane cleanly...")
            break
        
        save_config_to_disk()

if __name__ == "__main__":
    main()