local sbar = require("sketchybar")
local Aerospace = require("config.core.aerospace")

local aerospace = Aerospace.new()
while not aerospace:is_initialized() do
    os.execute("sleep 0.1")
end

sbar.aerospace = aerospace

sbar.begin_config()
sbar.hotload(true)

sbar.bar {
    height = 42,
    shadow = "on",
    position = "bottom",
    sticky = "on",
    padding_right = 10,
    padding_left = 10,
    corner_radius = 10,
    y_offset = 0,
    margin = 10,
    blur_radius = 40,
    notch_width = 200,
    color = "0x00ffffff" -- transparent
}

sbar.default {
    updates = "when_shown",
    icon = {
        font = {
            family = "Terminess Nerd Font",
            size = 14.0,
        },
        -- color = "0xff" .. palette.text,
        color = "0xffffffff",
        y_offset = -4,
    },
    label = {
        font = {
            -- family = fromNix.fonts.text,
            style = "Semibold",
            size = 13.0,
        },
        -- color = "0xff" .. palette.text,
        y_offset = -4,
    },
    background = {
        height = 26,
        corner_radius = 9,
        border_width = 2,
    },
    popup = {
        background = {
            border_width = 0,
            corner_radius = 9,
            -- color = "0xaa" .. palette.base,
            shadow = { drawing = true },
        },
        blur_radius = 20,
    },
    padding_left = 5,
    padding_right = 5,
}

require("items.focused")
require("items.spaces")

sbar.end_config()
sbar.event_loop()
