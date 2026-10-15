local colors = require("colors")
local sbar = require("sketchybar")
local app_icons = require("config.helpers.app_icons")

local wm = sbar.wm

local function create_focused_app_icon()
	return sbar.add("item", {
		icon = {
			background = {
				height = 40,
				color = colors.transparent,
				drawing = true,
				image = {
					scale = 0.9,
					y_offset = 0,
				},
			},
		},
		label = {
			padding_left = 5,
		},
	})
end

local function init_workspace(spaces, workspace)
	local space = sbar.add("space", workspace.id, {
		position = "left",
		background = { color = colors.black, corner_radius = 6 },
		icon = {
			string = workspace.name,
			padding_left = 5,
			padding_right = 5,
			color = colors.white,
			highlight_color = colors.blue,
		},
		padding_right = 2,
		padding_left = 2,
		label = {
			font = "sketchybar-app-font:Regular:16.0",
			string = "<>",
			padding_right = 10,
			color = colors.unselected.foreground,
			highlight_color = colors.selected.foreground,
			y_offset = -1,
			drawing = true,
		},
		drawing = true,
		display = workspace.display,
	})
	space:subscribe("mouse.clicked", function()
		wm:focus(workspace)
	end)
	spaces[workspace.id] = space
end

local function update_focused_app(focused_app_icon, env)
	if env.INFO == "Spotify" then
		return
	end

	focused_app_icon:set({
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
	})
end

local function icon_strip(apps)
	local seen = {}
	local ids = {}
	for _, app in ipairs(apps) do
		local id = app_icons[app or "Default"] or ":default:"
		if not seen[id] then
			seen[id] = true
			ids[#ids + 1] = id
		end
	end

	if #ids == 0 then
		return "—"
	end
	return table.concat(ids, " ")
end

local function colors_for(workspace)
	if workspace.visible then
		if workspace.focused then
			return colors.hotpink, colors.white
		end
		return colors.hotpink2, colors.offwhite
	end
	if workspace.focused then
		return colors.cyan, colors.offwhite
	end
	return colors.cyan2, colors.offwhite
end

local function update_workspaces(spaces)
	local ok, workspaces = pcall(wm.list, wm)
	if not ok then
		print("[spaces] workspace query failed", workspaces)
		return
	end

	local seen = {}

	for _, workspace in ipairs(workspaces) do
		local space = spaces[workspace.id]
		if space then
			seen[workspace.id] = true

			local bg_color, fg_color = colors_for(workspace)

			space:set({
				icon = { highlight = workspace.visible, highlight_color = fg_color },
				label = {
					string = icon_strip(workspace.apps),
					highlight = true,
					highlight_color = fg_color,
				},
				background = {
					color = colors.with_alpha(bg_color, 0.85),
				},
				drawing = #workspace.apps > 0 or workspace.visible,
				display = workspace.display,
			})
		end
	end

	for id, space in pairs(spaces) do
		if not seen[id] then
			space:set({ drawing = false })
		end
	end
end

local function create_observer(focused_app_icon, spaces)
	local observer = sbar.add("item", { drawing = false, updates = true })

	for _, event in ipairs(wm.events) do
		sbar.add("event", event)
	end

	observer:subscribe(wm.events, function()
		update_workspaces(spaces)
	end)

	observer:subscribe("refresh_workspaces", function(env)
		update_workspaces(spaces)
		update_focused_app(focused_app_icon, env)
	end)

	observer:subscribe("front_app_switched", function(env)
		update_workspaces(spaces)
		update_focused_app(focused_app_icon, env)
	end)

	observer:subscribe({ "system_woke", "display_change" }, function()
		wm:reconnect()
		update_workspaces(spaces)
	end)
end

local function initialize()
	local focused_app_icon = create_focused_app_icon()

	if not wm then
		local observer = sbar.add("item", { drawing = false, updates = true })
		observer:subscribe("front_app_switched", function(env)
			update_focused_app(focused_app_icon, env)
		end)
		return
	end

	-- Items are created from the first listing, so a display added later needs a
	-- sketchybar reload to get its own workspace items.
	local spaces = {}
	for _, workspace in ipairs(wm:list()) do
		init_workspace(spaces, workspace)
	end

	update_workspaces(spaces)
	create_observer(focused_app_icon, spaces)
end

initialize()
