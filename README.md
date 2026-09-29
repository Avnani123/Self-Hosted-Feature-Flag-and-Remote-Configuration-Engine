Here is the complete, single-copyable README markdown specifically updated to match your exact repository folder structure (`backend/`, `frontend/`, `flags.json`, `tunnel.py`).

```markdown
# ⚡ Self-Hosted Feature Flag & Remote Configuration Engine

A multi-threaded, enterprise-grade Remote Configuration and Feature Flag control plane designed for real-time app experimentation, dynamic runtime variable tweaks, and user segmentation.

This project connects a low-latency Python backend dashboard with a cross-platform Flutter client application through a secure proxy interface with live CORS handling.

---

## 🌟 Key Features

* **Multi-threaded Asynchronous Backend:** Powered by Python's `http.server` and `threading` modules for concurrent client request processing.
* **Interrupt-Driven Control Panel:** Operates via non-blocking, native keyboard listeners (`msvcrt`) for instant, single-key toggles without pressing `Enter`.
* **Dynamic Frontend UI Overrides:** Flawlessly mutates the Flutter UI layout, themes, features, and security thresholds at runtime without requiring app redeployments.
* **Security & Segmentation Policies:** Supports canary deployments, targeted beta tester profiles, and real-time security parameter tweaks (e.g., locking down `max_login_attempts` under brute-force attacks).
* **Robust Networking Pipeline:** Includes pre-flight (`OPTIONS`) handshakes and CORS header injection to bypass browser cross-origin blocks across remote proxies.

---

## 🏗️ Architecture & System Design


```

+-----------------------------------+             +-----------------------+             +---------------------------+
|        PYTHON CONTROL PLANE       |             |   LOCAL TUNNEL PROXY  |             |      FLUTTER CLIENT       |
|            (backend/)             |  =======>   | (Bypass / CORS Layer) |  =======>   |        (frontend/)        |
| - Interrupt-Driven Keyboard I/O   |             | - Public URL Stream   |             | - Live Polling Loop       |
| - State Management (flags.json)   |             | - Custom Pass Headers |             | - Dynamic UI & Logic Swap |
+-----------------------------------+             +-----------------------+             +---------------------------+

```

---

## 🛠️ Tech Stack

* **Backend:** Python 3.x (`http.server`, `threading`, `json`, `msvcrt`)
* **Frontend:** Flutter / Dart
* **Networking & Proxying:** Localtunnel, HTTP REST, CORS Handshakes

---

## 🚀 Getting Started

### 1. Prerequisites
* [Python 3.8+](https://www.python.org/downloads/)
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (or an online Flutter environment like FlutLab)
* Node.js & npm (for `localtunnel`)

### 2. Installation & Setup

1. **Clone the Repository**
   ```bash
   git clone [https://github.com/Avnani123/Self-Hosted-Feature-Flag-and-Remote-Configuration-Engine.git](https://github.com/Avnani123/Self-Hosted-Feature-Flag-and-Remote-Configuration-Engine.git)
   cd Self-Hosted-Feature-Flag-and-Remote-Configuration-Engine

```

2. **Start the Python Control Plane**
Navigate to your backend directory and run:
```bash
python backend/dashboard.py

```


3. **Expose the Local Server via Tunnel**
In a second terminal window, run your tunnel setup:
```bash
python tunnel.py
# OR run directly via npx:
npx localtunnel --port 5000

```


*Copy the generated tunnel URL (e.g., `https://your-domain.loca.lt`).*
4. **Configure & Launch the Flutter App**
* Open `frontend/lib/main.dart` (or your FlutLab project).
* Update the `backendStreamUrl` variable with your active localtunnel URL appended with `/flags`:
```dart
final String backendStreamUrl = "[https://your-domain.loca.lt/flags](https://your-domain.loca.lt/flags)";

```


* Run the Flutter client:
```bash
cd frontend
flutter pub get
flutter run

```





---

## 🎮 Live Terminal Control Plane Bindings

When the backend server is active, use the following instant keyboard shortcuts directly in your terminal to mutate application states on the fly:

| Key Press | Feature Flag / Target State | System Effect |
| --- | --- | --- |
| **`1`** | `dark_mode_beta` | Instantly toggles app theme between Dark and Light mode |
| **`2`** | `new_checkout_flow` | Switches payment gateway CTA from Legacy to New Checkout Flow |
| **`3`** | `ai_recommendations` | Dynamically injects or strips the AI Recommendation banner |
| **`4`** | `max_login_attempts` | Alters security threshold between `5` (Standard) and `3` (Strict Lockout) |
| **`5`** | `ab_experiment` | Enables or disables running A/B experiment modules |
| **`q`** | Safe Shutdown | Persists state to `flags.json` and closes backend server |

---

## 📁 Repository Structure

```text
├── backend/          # Multi-threaded Python server & dashboard engine
├── frontend/         # Flutter client project and Dart source code
├── flags.json        # Live persistent state configuration map
├── tunnel.py         # Proxy tunnel runner script
└── .gitignore        # Version control exclusions

```

```

```
