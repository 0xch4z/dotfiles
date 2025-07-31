local colors = require("colors")

-- Equivalent to the --bar domain
sbar.bar({
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
})
