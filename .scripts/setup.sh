yay -S awww
yay -S xdg-desktop-portal-hyprland
yay -S polkitagenthyprland
yay -S inotifytools
mkdir -p /home/jay/.config/variety/pluginconfig/CustomRedditDownloader/
touch /home/jay/.config/variety/pluginconfig/CustomRedditDownloader/credentials.conf
read -p "username=" username
read -p "password=" password
echo "username=$username\npassword=$password" >  /home/jay/.config/variety/pluginconfig/CustomRedditDownloader/credentials.conf