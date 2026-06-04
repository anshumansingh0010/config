win_json=$(hyprctl activewindow -j)
if [[ -z "$win_json" || "$win_json" == "null" ]]; then
    exit 0
fi
width=$(jq -r '.size[0]' <<< "$win_json")
height=$(jq -r '.size[1]' <<< "$win_json")
addr=$(jq -r '.address' <<< "$win_json")
mxheight=928
mxwidth=1513
ystart=50
xstart=67
xmove=0
ymove=16
if (( height > mxheight && width > mxwidth )); then
    hyprctl --batch "dispatch resizeactive exact $mxwidth $mxheight ; dispatch centerwindow 1 ; dispatch moveactive $xmove $ymove"
elif (( height > mxheight )); then
    hyprctl dispatch resizeactive exact "$width" "$mxheight"
    current_x=$(hyprctl activewindow -j | jq -r '.at[0]')
    hyprctl dispatch movewindowpixel exact "$current_x" "$ystart",address:"$addr"
elif (( width > mxwidth )); then
    hyprctl dispatch resizeactive exact "$mxwidth" "$height"
    current_y=$(hyprctl activewindow -j | jq -r '.at[1]')
    hyprctl dispatch movewindowpixel exact "$xstart" "$current_y",address:"$addr"
else
    hyprctl --batch "dispatch centerwindow 1 ; dispatch moveactive $xmove $ymove"
fi
