-- Rift module implements a client for rift-cli.
-- @module Rift
local json = require("cjson")

local Rift = {}
Rift.__index = Rift

Rift.backend = "rift"
Rift.events = { "rift_workspace_changed", "rift_windows_changed" }

function Rift.new(cli)
	local self = setmetatable({}, Rift)
	self.cli = cli or "rift-cli"

	if not self:displays() then
		error("rift is not reachable via " .. self.cli)
	end

	return self
end

function Rift:run(args)
	local pipe = io.popen(string.format("%s %s 2>/dev/null", self.cli, args))
	if not pipe then
		return nil
	end

	local out = pipe:read("a")

	pipe:close()

	if not out or out == "" then
		return nil
	end

	local decoded, result = pcall(json.decode, out)
	if not decoded then
		print("[rift] failed to decode response for", args, result)
		return nil
	end

	return result
end

function Rift:is_initialized()
	return self.cli ~= nil
end

function Rift:displays()
	return self:run("query displays")
end

function Rift:workspaces(display_uuid)
	return self:run(string.format("query workspaces --display '%s'", display_uuid))
end

function Rift:switch_workspace(index)
	return self:run(string.format("execute workspace switch %d", index))
end

function Rift:reconnect() end

function Rift:list()
	local displays = self:displays()
	if not displays then
		return {}
	end

	local workspaces = {}
	for display_index, display in ipairs(displays) do
		for _, workspace in ipairs(self:workspaces(display.uuid) or {}) do
			local apps = {}
			for _, window in ipairs(workspace.windows or {}) do
				apps[#apps + 1] = window.app_name
			end

			workspaces[#workspaces + 1] = {
				id = string.format("%d.%d", display_index, workspace.index),
				name = workspace.name,
				index = workspace.index,
				display = display_index,
				visible = workspace.is_active,
				focused = workspace.is_active and display.is_active_context,
				apps = apps,
			}
		end
	end
	return workspaces
end

function Rift:focus(workspace)
	self:switch_workspace(workspace.index)
end

return Rift
