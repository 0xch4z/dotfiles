local sbar = require("sketchybar")

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

    local window = sbar.aerospace.focused_window()

    front_app:set {
        label = {
            string = window.window_title,
            font = {
            },
        },
        icon = {
            background = {
                height = 20,
                color = "0x00000000",
                drawing = true,
                image = {
                    string = "app." .. env.INFO,
                    scale = 0.7,
                    y_offset = -4,
                },
            },
        },
    }
end)
