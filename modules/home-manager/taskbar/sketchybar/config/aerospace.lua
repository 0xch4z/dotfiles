local aerospace = require("config.core.aerospace").new()
while not aerospace:is_initialized() do
    os.execute("sleep 0.1")
end
sbar.aerospace = aerospace
