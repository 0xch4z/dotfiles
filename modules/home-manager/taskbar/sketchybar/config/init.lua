os.execute("(cd ./config/helpers && make)")

sbar = require("sketchybar")
sbar.hotload(true)

require("config.aerospace")

-- Bundle the entire configuration into a single message to sketchybar
sbar.begin_config()
require("config.bar")
require("config.default")
require("config.items")
sbar.end_config()

-- Run the event loop of the sketchybar module
sbar.event_loop()
print("sketchybar event loop exited")
