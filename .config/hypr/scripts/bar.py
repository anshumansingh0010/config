#!/usr/bin/env python3
import subprocess
import json

def eval_lua(code):
    """Run a Lua snippet via hyprctl eval."""
    return subprocess.run(['hyprctl', 'eval', code], capture_output=True, text=True)

def toggle_hyprbars():
    try:
        # 1. Fetch the active window data safely
        result = subprocess.run(['hyprctl', '-j', 'activewindow'], capture_output=True, text=True)
        if result.returncode != 0 or not result.stdout.strip():
            return

        window_data = json.loads(result.stdout)
        window_address = window_data.get("address")

        if not window_address:
            return

        # 2. Use the Hyprland Lua API to toggle the hyprbars dynamic rule for this specific window address.
        #    This tells the compositor to inject the rule dynamically to toggle the visibility of the titlebar.
        lua_code = f"hl.dispatch(hl.dsp.exec_cmd('windowrule plugin:hyprbars:nobar, address:{window_address}'))"
        eval_lua(lua_code)

    except (json.JSONDecodeError, FileNotFoundError):
        pass

if __name__ == "__main__":
    toggle_hyprbars()
