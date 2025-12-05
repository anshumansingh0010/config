#!/bin/bash
paths=(".config",".scripts")

for path in "${paths[@]}"; do
 rm -rf ~/tmptasks/gitsave/config/$path
 echo ~/tmptasks/gitsave/config/$path
#  cp -r ~/.$path ~/tmptasks/gitsave/config/$path
done
