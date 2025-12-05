#!/bin/bash
paths=(".config" ".scripts")
mkdir -p  ~/tmptasks/gitsave/config/
for path in "${paths[@]}"; do
 rm -rf ~/tmptasks/gitsave/config/$path
 echo ~/tmptasks/gitsave/config/$path
 cp -r ~/$path ~/tmptasks/gitsave/config/$path
done
cd ~/tmptasks/gitsave/config
git add .
git add .
git commit -m "something"
git push