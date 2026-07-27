local vars = require("variables")
local fn   = require("utils.functions")

hl.on("hyprland.start", function()
    -- Ensure portals and systemd know we are in Wayland
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

    -- Keyring and auth
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")

    -- Clipboard history
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- Cursors (Syncing Hyprland and GTK)
    hl.exec_cmd("hyprctl setcursor " .. vars.cursorTheme .. " " .. vars.cursorSize)
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme " .. vars.cursorTheme)
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-size " .. vars.cursorSize)

    -- Background services
    hl.exec_cmd("mpris-proxy")
    hl.exec_cmd("ydotoold --socket-path /tmp/.ydotool_socket")
    hl.exec_cmd("xsettingsd")
    hl.exec_cmd(os.getenv("HOME") .. "/.scripts/organise.sh")

    -- UI and Shell Components
    hl.exec_cmd("hyprpm reload")
    hl.exec_cmd("caelestia shell -d")
    hl.exec_cmd("quickshell -p /home/jay/.config/quickshell/shell.qml")
    hl.exec_cmd("sleep 1 && awww-daemon")
    hl.exec_cmd("sleep 1 && gammastep")
end)

-- Resizer listeners
local function apply_resizer_rules(win)
    local float_center = {
        hl.dsp.window.float({ action = "on", window = win }),
        hl.dsp.window.center({ window = win }),
    }
    local pip_actions = fn.move_actions(win) or {}

    -- Bitwarden
    fn.resizer(win, "Bitwarden", 20, 54, float_center, true, "class")                                       -- Native app
    fn.resizer(win, "^Extension: %(Bitwarden Password Manager%) %- Bitwarden", 20, 54, float_center, false) -- Firefox
    fn.resizer(win, "nngceckbapebfimnlniiiahkandclblb", 20, 54, float_center, true, "class")                -- Chromium

    -- Picture in picture
    fn.resizer(win, "Picture[- ]in[- ][Pp]icture", 0, 0, pip_actions, false)
end

hl.on("window.title", apply_resizer_rules)
hl.on("window.open", apply_resizer_rules)
