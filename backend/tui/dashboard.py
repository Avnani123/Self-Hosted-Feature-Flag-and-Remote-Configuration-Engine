import sys
import os
import httpx
from textual.app import App, ComposeResult
from textual.widgets import Header, Footer, ListItem, ListView, Static
from textual.binding import Binding

# Ensure the backend directory is in the Python path so we can import config_store
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from app.config_store import read_config

SERVER_URL = "http://localhost:8000"

class FlagItem(ListItem):
    """A custom interactive row item for each feature flag."""
    def __init__(self, flag_name: str, status: bool, rule: str) -> None:
        super().__init__()
        self.flag_name = flag_name
        self.status = status
        self.rule = rule
        self.update_text()

    def update_text(self) -> None:
        """Refreshes the row label text visually."""
        status_str = "[ON] " if self.status else "[OFF]"
        # Style the ON/OFF text using Textual markup syntax
        color = "green" if self.status else "red"
        self.update(f"[{color}] {status_str} [/{color}]  [b]{self.flag_name:<22}[/b] : ({self.rule})")

    async def toggle(self) -> None:
        """Toggles the state locally and hits the FastAPI backend to broadcast it."""
        new_status = not self.status
        try:
            async with httpx.AsyncClient() as client:
                response = await client.post(
                    f"{SERVER_URL}/toggle-flag",
                    params={"name": self.flag_name, "status": str(new_status).lower()}
                )
                if response.status_code == 200:
                    self.status = new_status
                    self.update_text()
        except httpx.RequestError:
            # If server isn't running, show error in the item console
            self.update(f"[red][ERR] Could not reach FastAPI server at {SERVER_URL}[/red]")

class FeatureFlagApp(App):
    """The main interactive Terminal User Interface (TUI) Application."""
    TITLE = "🚀 FEATURE FLAG & CONFIG MANAGER"
    CSS = """
    Screen {
        background: #1e1e1e;
        align: center middle;
    }
    ListView {
        width: 80%;
        height: auto;
        margin: 2;
        border: solid #333333;
        background: #121212;
    }
    ListItem {
        padding: 1 2;
    }
    ListItem:focus {
        background: #2b2b2b;
        color: #ffffff;
    }
    Static {
        width: 80%;
        margin-left: 4;
    }
    """

    # Register convenient global keyboard shortcuts
    BINDINGS = [
        Binding("space", "toggle_flag", "Toggle Selected Flag"),
        Binding("q", "quit", "Quit Dashboard"),
    ]

    def compose(self) -> ComposeResult:
        yield Header(show_clock=True)
        yield Static("\n[b][yellow]ACTIVE FLAGS (Use arrow keys to navigate, Space to flip switch):[/yellow][/b]")
        
        # Pull the initial data configurations from our config.json
        config_data = read_config()
        
        self.flag_list = ListView()
        for name, details in config_data.get("flags", {}).items():
            self.flag_list.append(FlagItem(name, details["status"], details["rule"]))
            
        yield self.flag_list
        
        # Render static text fields for remote config variables
        yield Static("\n[b][yellow]CONFIG VARIABLES (Static properties):[/yellow][/b]")
        for key, val in config_data.get("configs", {}).items():
            yield Static(f" - {key:<20} : [cyan]\"{val}\"[/cyan]")
            
        yield Footer()

    async def action_toggle_flag(self) -> None:
        """Triggers the toggle event on whichever row item is currently focused."""
        selected_item = self.flag_list.highlighted_child
        if isinstance(selected_item, FlagItem):
            await selected_item.toggle()

if __name__ == "__main__":
    app = FeatureFlagApp()
    app.run()