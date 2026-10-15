local Wm = require("config.core.wm")

sbar.wm = Wm.connect(os.getenv("SKETCHYBAR_WM_BACKEND"))
