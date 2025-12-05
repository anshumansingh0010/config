#!/bin/bash
paths=(".config",".scripts")
rm -rf ~/tmptasks/gitsave/config/.config
rm -rf ~/tmptasks/gitsave/config/.scripts
cp -r ~/.config ~/tmptasks/gitsave/config/.config
cp -r ~/.scripts ~/tmptasks/gitsave/config/.scripts