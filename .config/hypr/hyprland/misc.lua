local scheme = require("scheme.current")

hl.config({
    misc = {
        vrr                          = 1,
        animate_manual_resizes       = false,
        animate_mouse_windowdragging = false,

        disable_hyprland_logo        = true,
        force_default_wallpaper      = 0,
        disable_splash_rendering     = true,

        on_focus_under_fullscreen    = 2,
        allow_session_lock_restore   = true,
        middle_click_paste           = false,
        focus_on_activate            = true,
        session_lock_xray            = true,

        mouse_move_enables_dpms      = true,
        key_press_enables_dpms       = true,

        background_color             = "rgb(" .. scheme.surfaceContainer .. ")",

        enable_swallow               = true,
        swallow_regex                = "^(foot|kitty|Alacritty)$",

        always_follow_on_dnd         = true,
        layers_hog_keyboard_focus    = true,
    },

    debug = {
        vfr              = true,
        error_position   = 1,
        damage_tracking  = 2,
        overlay          = false,
    },

    cursor = {
        no_hardware_cursors = false,
        inactive_timeout    = 10,
    },
})
