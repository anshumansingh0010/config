#!/bin/bash
PID_FILE="$HOME/.cache/auto-music.pid"
kill $(cat $PID_FILE)
pkill -f mpv