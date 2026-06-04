#!/usr/bin/env python3
import json
import subprocess

def execute(command):
    return subprocess.run(['bash', '-c', command], capture_output=True, text=True)

def tag_all_windows(tag_names_with_targets, client_addresses):
    """
    Applies all tag changes to all windows in a single fast batch call.
    Expects a dictionary like: {"noborder": True, "noshadow": False}
    """
    batch_commands = []
    for tag_name, target in tag_names_with_targets.items():
        sign = "+" if target else "-"
        for addr in client_addresses:
            batch_commands.append(f"dispatch tagwindow {sign}{tag_name} address:{addr}")
    
    if batch_commands:
        full_command = " ; ".join(batch_commands)
        subprocess.run(['hyprctl', '--batch', full_command])
        print(f"Processed batch updates for {len(client_addresses)} windows.")

# 1. Fetch active window tags cleanly without relying on external jq
active_window_raw = execute('hyprctl -j activewindow')
if not active_window_raw.stdout.strip():
    print("No active window found.")
    exit(1)

window_data = json.loads(active_window_raw.stdout)
active_tags = window_data.get("tags", [])

# 2. Build the targeted tracking dictionary
alltagarray = ["noborder", "noshadow"]
current_tagset = {tag: (1 if tag in active_tags else 0) for tag in alltagarray}

# 3. Create a strictly ordered list of keys to completely prevent sorting bugs
sorted_keys = sorted(current_tagset.keys())

# 4. Simulate the binary step increment using the sorted sequence
for key in sorted_keys:
    if current_tagset[key] == 1:
        current_tagset[key] = 0   
    else:
        current_tagset[key] = 1
        break    

# 5. Get all client addresses ONCE instead of running it repeatedly inside a loop
clients_result = subprocess.run(['hyprctl', '-j', 'clients'], capture_output=True, text=True)
if clients_result.returncode != 0:
    print("Error fetching clients")
    exit(1)

clients = json.loads(clients_result.stdout)
addresses = [c['address'] for c in clients]

# 6. Map out the true/false intent while maintaining exact key order
actions_to_take = {key: (True if current_tagset[key] == 1 else False) for key in sorted_keys}

# 7. Execute everything in a single, high-performance batch call
tag_all_windows(actions_to_take, addresses)
