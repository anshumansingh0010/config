#!/bin/bash
paths=(".config",".scripts")

for path in "${paths[@]}"; do
 rm -rf ~/tmptasks/gitsave/config/$path
 
done
rm -rf ~/tmptasks/gitsave/config/.config
rm -rf ~/tmptasks/gitsave/config/.scripts
cp -r ~/.config ~/tmptasks/gitsave/config/.config
cp -r ~/.scripts ~/tmptasks/gitsave/config/.scripts