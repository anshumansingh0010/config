function editcity
read -P "city:" city
echo "$city" > "$HOME/.scripts/city.txt"
return
end