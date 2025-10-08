# ~/.bashrc
function editcity() {
read -p "city:" city
echo "$city" > "~/.scripts/city.txt"
}