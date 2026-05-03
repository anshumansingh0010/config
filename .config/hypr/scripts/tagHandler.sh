#!/usr/bin/env bash

result=$(hyprctl -j activewindow | jq -r '.tags')
declare -A current_tagset

if [ "$result" != "null" ]; then
    while IFS= read -r i; do
        if [ -n "$i" ]; then
            current_tagset["$i"]=1
        fi
    done <<< "$(echo "$result" | jq -r '.[]')"
fi

alltagarray=("nobar" "noborder" "noshadow" "noblur")

for i in "${alltagarray[@]}"; do
    if [[ -z "${current_tagset[$i]}" ]]; then
        current_tagset["$i"]=0
    fi
done

while IFS= read -r key; do
    if [ "${current_tagset[$key]}" -eq 1 ]; then
        current_tagset["$key"]=0
    else
        current_tagset["$key"]=1
        break
    fi
done <<< "$(for k in "${!current_tagset[@]}"; do echo "$k"; done | sort)"

for key in "${!current_tagset[@]}"; do
    if [ "${current_tagset[$key]}" -eq 1 ]; then
        hyprctl dispatch tagwindow "+$key"
    else
        hyprctl dispatch tagwindow -- "-$key"
    fi
done
