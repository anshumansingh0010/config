local vars = require("variables")

hl.config({
    decoration = {
        rounding         = vars.windowRounding,
        active_opacity   = vars.activeOpacity,
        inactive_opacity = vars.inactiveOpacity,
        dim_inactive     = vars.dimInactive,
        dim_strength     = vars.dimStrength,

        blur = {
            enabled           = vars.blurEnabled,
            xray              = vars.blurXray,
            special           = vars.blurSpecialWs,
            ignore_opacity    = true, -- Allows opacity blurring
            new_optimizations = true,
            popups            = vars.blurPopups,
            input_methods     = vars.blurInputMethods,
            size              = vars.blurSize,
            passes            = vars.blurPasses,
            vibrancy          = vars.blurVibrancy,
            brightness        = vars.blurBrightness,
            noise             = vars.blurNoise,
        },

        shadow = {
            enabled      = vars.shadowEnabled,
            range        = vars.shadowRange,
            render_power = vars.shadowRenderPower,
            color        = vars.shadowColour,
        },
    },
})
