ws="$(hyprctl -j activewindow | jq -r '.workspace.name')"

if [[ "$ws" == special* ]]; then
   
else
    echo "Not on special"
fi

# hyprctl dispatch movetoworkspace e+0