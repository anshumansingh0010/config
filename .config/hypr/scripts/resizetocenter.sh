width=$(hyprctl activewindow -j | jq ".size[0]")
height=$(hyprctl activewindow -j | jq ".size[1]")
mxheight=922
mxwidth=1504
ystart=55
xstart=73
xmove=0
ymove=16

if (( height > mxheight && width > mxwidth )); then
hyprctl dispatch resizeactive exact $mxwidth $mxheight
hyprctl dispatch centerwindow 1
hyprctl dispatch moveactive  $xmove $ymove
elif (( height > mxheight )); then
hyprctl dispatch resizeactive exact $width $mxheight
ypos=$(($ystart - $(hyprctl activewindow -j | jq ".at[1]")))
hyprctl dispatch moveactive 0 $ypos
elif (( width > mxwidth )); then
hyprctl dispatch resizeactive exact $mxwidth $height
xpos=$(($xstart - $(hyprctl activewindow -j | jq ".at[0]")))
hyprctl dispatch moveactive $xpos 0
fi