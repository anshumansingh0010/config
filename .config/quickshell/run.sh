#!/bin/bash

# Kill any existing instances of this specific test if needed (optional)
# pkill -f "quickshell.*newsomething/shell.qml" 

echo "Starting Sidecar Shell..."

# Run quickshell pointing to our local qml file
# specific command might vary based on installation, usually 'quickshell'
quickshell -p ./shell.qml

echo "Sidecar exited."
