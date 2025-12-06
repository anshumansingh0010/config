#!/bin/bash

WAKEFILE="/tmp/hypridle_expected_wake"

# shutdown after 1 hour = 3600 sec
WAKE_TIME=$(($(date +%s) + 3600))

# store expected wake time (for systemd)
echo "$WAKE_TIME" > "$WAKEFILE"

# clear previous alarm
echo 0 | sudo tee /sys/class/rtc/rtc0/wakealarm >/dev/null

# set new alarm
echo "$WAKE_TIME" | sudo tee /sys/class/rtc/rtc0/wakealarm >/dev/null

# suspend system
systemctl suspend
