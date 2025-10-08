function fish_greeting
    echo -ne '\x1b[38;5;16m'  # Set colour to primary
    echo "
    ___  ________      ___    ___ 
   |\  \|\   __  \    |\  \  /  /|
   \ \  \ \  \|\  \   \ \  \/  / /
 __ \ \  \ \   __  \   \ \    / / 
|\   \\_\  \ \  \ \  \   \/  /  /  
\ \________\ \__\ \__\__/  / /    
 \|________|\|__|\|__|\___/ /     
                     \|___|/      
                                  
                                  
    "
    set_color normal
    fastfetch --key-padding-left 5
end
