local aerospace = require("config.core.aerospace").new()
while not aerospace:is_initialized() do
	os.execute("sleep 0.1")
end

sbar.aerospace = aerospace

-- Execute the event provider binary which provides the event "cpu_update" for
-- the cpu load data, which is fired every 2.0 seconds.
sbar.exec("killall cpu_load >/dev/null; $CONFIG_DIR/config/helpers/event_providers/aerospace/bin/cpu_load aerospace")
