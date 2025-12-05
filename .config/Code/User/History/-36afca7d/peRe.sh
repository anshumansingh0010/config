ws="$(hyprctl -j activewindow | jq -r '.workspace.name')"

if [[ "$ws" == special* ]]; then

    hyprctl dispatch movetoworkspace e+0

else

  hyprctl dispatch movetoworkspacesilent special
  
fi

