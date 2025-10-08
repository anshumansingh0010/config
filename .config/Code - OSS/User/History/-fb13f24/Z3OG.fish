function editcity
read -P "city:" city
echo "$city" > "~/.scripts/city.txt"
return
end