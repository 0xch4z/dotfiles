local Aerospace = require("config.core.aerospace")
local Rift = require("config.core.rift")

local PROBE_ATTEMPTS = 20
local PROBE_DELAY = "0.25"

local clients = {
	rift = Rift,
	aerospace = Aerospace,
}

local fallback_order = { "rift", "aerospace" }

local Wm = {}

local function order(preferred)
	if not preferred then
		return fallback_order
	end

	if not clients[preferred] then
		print("[wm] unknown backend", preferred)
		return fallback_order
	end

	local names = { preferred }
	for _, name in ipairs(fallback_order) do
		if name ~= preferred then
			names[#names + 1] = name
		end
	end
	return names
end

local function try_connect(preferred)
	for _, name in ipairs(order(preferred)) do
		local ok, client = pcall(clients[name].new)
		if ok and client then
			return client
		end
	end
	return nil
end

function Wm.connect(preferred)
	for attempt = 1, PROBE_ATTEMPTS do
		local client = try_connect(preferred)
		if client then
			print("[wm] using", client.backend)
			return client
		end
		if attempt < PROBE_ATTEMPTS then
			os.execute("sleep " .. PROBE_DELAY)
		end
	end

	print("[wm] no window manager found, workspace items disabled")
	return nil
end

return Wm
