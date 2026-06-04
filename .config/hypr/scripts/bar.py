#!/usr/bin/env python3
import subprocess
import json

def toggle_nobar_tag():
    try:
        # 1. Fetch the active window data safely
        result = subprocess.run(['hyprctl', '-j', 'activewindow'], capture_output=True, text=True)
        if result.returncode != 0 or not result.stdout.strip():
            return

        window_data = json.loads(result.stdout)
        window_address = window_data.get("address")

        if not window_address:
            return

        # 2. Toggle the 'nobar' tag natively
        # Leaving out '+' or '-' tells Hyprland to automatically handle the toggle state.
        # We pass it as a single explicit command string so the shell processes the space correctly.
        subprocess.run(f"hyprctl dispatch tagwindow nobar address:{window_address}", shell=True)

    except (json.JSONDecodeError, FileNotFoundError):
        pass

if __name__ == "__main__":
    toggle_nobar_tag()
