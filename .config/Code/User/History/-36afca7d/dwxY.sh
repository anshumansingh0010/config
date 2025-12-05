ws="$(hyprctl -j activewindow | jq -r '.workspace.name')"

if [[ "$ws" == special* ]]; then
   hyprctl
else
  
fi

# hyprctl dispatch movetoworkspace e+0