#!/usr/bin/env python3
import json
import subprocess

def execute(command):
    return subprocess.run(['bash', '-c', command], capture_output=True, text=True)

def eval_lua(code):
    """Run a Lua snippet via hyprctl eval."""
    return subprocess.run(['hyprctl', 'eval', code], capture_output=True, text=True)

# 1. Get the current active window JSON data safely
window_data_raw = execute('hyprctl -j activewindow')
if not window_data_raw.stdout.strip():
    print("No active window found.")
    exit(1)

window_data = json.loads(window_data_raw.stdout)
window_address = window_data.get("address")
active_tags = window_data.get("tags", [])

# 2. Build the targeted tracking dictionary
all_tags = ["noborder", "noshadow", "noblur"]
current_tagset = {tag: (1 if tag in active_tags else 0) for tag in all_tags}

# 3. Simulate binary step increment (ordered alphabetically)
sorted_keys = sorted(current_tagset.keys())
for key in sorted_keys:
    if current_tagset[key] == 1:
        current_tagset[key] = 0
    else:
        current_tagset[key] = 1
        break  # Move to next state and break out of binary increment

# 4. Build and run eval calls for each tag using the Lua hl.dsp.window.tag API
for key in sorted_keys:
    sign = "+" if current_tagset[key] == 1 else "-"
    lua_code = f"hl.dispatch(hl.dsp.window.tag({{ tag = '{sign}{key}', window = 'address:{window_address}' }}))"
    eval_lua(lua_code)

print("Window tags updated successfully.")
