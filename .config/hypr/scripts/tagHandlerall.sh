#!/usr/bin/env bash

tag_all_windows() {
    local tag_name="$1"
    local target="$2"
    
    local clients
    clients=$(hyprctl -j clients)
    
    local addresses
    addresses=$(echo "$clients" | jq -r '.[].address')
    
    local prefix="+"
    if [ "$target" = "false" ]; then
        prefix="-"
    fi
    
    local batch_commands=""
    local count=0
    
    while read -r addr; do
        if [ -n "$addr" ]; then
            if [ -n "$batch_commands" ]; then
                batch_commands="$batch_commands ; "
            fi
            batch_commands="${batch_commands}dispatch tagwindow ${prefix}${tag_name} address:${addr}"
            ((count++))
        fi
    done <<< "$addresses"
    
    hyprctl --batch "$batch_commands"
}

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
        tag_all_windows "$key" "true"
    else
        tag_all_windows "$key" "false"
    fi
done
