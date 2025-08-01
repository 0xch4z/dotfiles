local sbar = require("sketchybar")
local colors = require("colors")

local front_app = sbar.add("item", {
    icon = {
        width = 20,
    },
    label = {
        padding_left = 5,
    },
})

front_app:subscribe("front_app_switched", function(env)
    local app = env.INFO

    sbar.aerospace:focused_window(function (window)
        front_app:set {
            icon = {
                background = {
                    height = 40,
                    color = colors.transparent,
                    drawing = true,
                    image = {
                        string = "app." .. env.INFO,
                        scale = 0.9,
                        y_offset = 0,
                    },
                },
            },
        }
    end)

end)
