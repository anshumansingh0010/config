#!/bin/bash

# Ensure working directory is the script's directory
cd "$(dirname "$0")"

echo "Starting Sidecar Shell..."

# Run quickshell pointing to our local qml file
quickshell -p ./shell.qml

echo "Sidecar exited."

