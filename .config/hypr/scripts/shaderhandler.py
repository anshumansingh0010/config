#!/usr/bin/env python3
import subprocess
import sys

def execute(command):
    return subprocess.run(['bash', '-c', command], capture_output=True, text=True)

def arg(i: int):
    return sys.argv[i]

def getshadernames():
    """Get available shader names from hyprshade ls."""
    result = subprocess.run(['hyprshade', 'ls'], capture_output=True, text=True)
    if result.returncode != 0:
        return []
    # Strip leading '* ' active-marker that hyprshade ls may print
    shaders = [s.strip().lstrip('* ').strip() for s in result.stdout.strip().split('\n') if s.strip()]
    # Deduplicate while preserving order
    seen = set()
    unique = []
    for s in shaders:
        if s not in seen:
            seen.add(s)
            unique.append(s)
    return unique

def get_current_shader():
    """Return the currently active shader name, or empty string if none."""
    result = subprocess.run(['hyprshade', 'current'], capture_output=True, text=True)
    return result.stdout.strip()

def main():
    shaders = getshadernames()
    if not shaders:
        print("No shaders available.")
        return

    print(shaders)
    current = get_current_shader()

    if len(sys.argv) > 1 and arg(1) == 'toggle':
        # Toggle vibrance on/off
        if current:
            execute("hyprshade off")
        else:
            execute("hyprshade on vibrance")
    else:
        # Cycle to the next shader
        if current and current in shaders:
            idx = (shaders.index(current) + 1) % len(shaders)
        else:
            idx = 0
        execute(f"hyprshade on {shaders[idx]}")

if __name__ == "__main__":
    main()