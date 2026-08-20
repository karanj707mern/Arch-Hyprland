-- /* ---- 💫 https://github.com/karanj707mern 💫 ---- */  --
# JaKooLit-Arch-Dots-Luafied-by-Karran-Patel
-- Default settings
-- This is where you put your own settings as this will not be touched during update
-- if the upgrade.sh is used.

local scriptsDir = os.getenv("HOME") .. "/.config/hypr/scripts"

hl.config({
    dwindle = {
        pseudotile = true,
        preserve_split = true,
        special_scale_factor = 0.8,
    },
})

hl.config({
    master = {
        new_status = "master",
        new_on_top = 1,
        mfact = 0.5,
    },
})

hl.config({
    general = {
        resize_on_border = true,
        layout = "dwindle",
    },
})

hl.config({
    input = {
        kb_layout = "us",
        kb_variant = "",
        kb_model = "",
        kb_options = "",
        kb_rules = "",
        repeat_rate = 50,
        repeat_delay = 300,
        sensitivity = 0,
        numlock_by_default = true,
        left_handed = false,
        follow_mouse = 1,
        float_switch_override_focus = false,
        touchpad = {
            disable_while_typing = true,
            natural_scroll = true,
            clickfinger_behavior = false,
            middle_button_emulation = false,
            tap_to_click = true,
            drag_lock = false,
        },
        touchdevice = {
            enabled = true,
        },
        tablet = {
            transform = 0,
            left_handed = 0,
        },
    },
})

hl.config({
    gestures = {
        workspace_swipe_distance = 500,
        workspace_swipe_invert = true,
        workspace_swipe_min_speed_to_force = 30,
        workspace_swipe_cancel_ratio = 0.5,
        workspace_swipe_create_new = true,
        workspace_swipe_forever = true,
    },
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 4, direction = "up", action = function()
    local factor = 1.5
    hl.dispatch(hl.dsp.exec_cmd("hyprctl keyword cursor:zoom_factor \"$(hyprctl getoption cursor:zoom_factor | awk 'NR==1 {f=$2; if(f<1){f=1}; print f*" .. factor .. "}')\""))
end })
hl.gesture({ fingers = 4, direction = "down", action = function()
    local factor = 1.5
    hl.dispatch(hl.dsp.exec_cmd("hyprctl keyword cursor:zoom_factor \"$(hyprctl getoption cursor:zoom_factor | awk 'NR==1 {f=$2; if(f<1){f=1}; print f/" .. factor .. "}')\""))
end })
hl.gesture({ fingers = 3, direction = "up", action = function() hl.dispatch(hl.dsp.exec_cmd(scriptsDir .. "/OverviewToggle.sh")) end })

hl.config({
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        vfr = true,
        vrr = 2,
        mouse_move_enables_dpms = true,
        enable_swallow = "off",
        swallow_regex = "^(kitty)$",
        focus_on_activate = false,
        initial_workspace_tracking = 0,
        middle_click_paste = false,
        enable_anr_dialog = true,
        anr_missed_pings = 15,
        allow_session_lock_restore = true,
        on_focus_under_fullscreen = 1,
    },
})

hl.config({
    binds = {
        workspace_back_and_forth = true,
        allow_workspace_cycles = true,
        pass_mouse_when_bound = false,
    },
})

hl.config({
    xwayland = {
        enabled = true,
        force_zero_scaling = true,
    },
})

hl.config({
    render = {
        direct_scanout = 0,
    },
})

hl.config({
    cursor = {
        sync_gsettings_theme = true,
        no_hardware_cursors = 2,
        enable_hyprcursor = true,
        warp_on_change_workspace = 2,
        no_warps = true,
    },
})
