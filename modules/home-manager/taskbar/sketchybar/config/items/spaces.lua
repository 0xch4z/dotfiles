local colors = require("colors")
local sbar = require("sketchybar")
local app_icons = require("config.helpers.app_icons")

local aerospace = sbar.aerospace
local spaces = {}

local function contains(list, value)
    for _, v in ipairs(list) do if v == value then return true end end
    return false
end

local function parse_workspace_listing(listing)
    local workspace_name = listing.workspace
    local monitor_id = math.floor(listing["monitor-appkit-nsscreen-screens-id"])
    return workspace_name, monitor_id
end

local function hide_workspace(workspace_name)
    if spaces[workspace_name] then
        sbar.set(spaces[workspace_name], {drawing = false})
    end
end

local function create_empty_workspace(workspace_name, monitor_id)
    local space = sbar.add("space", workspace_name, {
        position = "left",
        background = {color = colors.black, corner_radius = 6},
        icon = {
            string = workspace_name,
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
            drawing = true
        },
        drawing = true
    })
    space:subscribe("mouse.clicked",
                    function() aerospace:workspace(workspace_name) end)
    spaces[workspace_name] = space
end

local function update_workspaces()
    local relevant_spaces = {}
    aerospace:list_workspaces({"--all"}, function(listing)
        for _, entry in ipairs(listing) do
            workspace_name, monitor_id = parse_workspace_listing(entry)
            relevant_spaces[workspace_name] = monitor_id
        end
        for workspace_name in pairs(spaces) do
            if not relevant_spaces[workspace_name] then
                hide_workspace(workspace_name)
            end
        end
    end)

    local all_windows = aerospace:list_all_windows()
    local windows_by_workspace = {}
    for _, window in ipairs(all_windows) do
        local ws = window.workspace
        windows_by_workspace[ws] = windows_by_workspace[ws] or {}
        windows_by_workspace[ws][#windows_by_workspace[ws] + 1] = window
    end

    local focused_workspace = aerospace:focused_workspace()
    local visible_spaces = aerospace:list_workspace_names({
        "--monitor", "all", "--visible"
    })

    for workspace_name, entry in pairs(spaces) do
        local is_focused = workspace_name == focused_workspace
        local is_visible = contains(visible_spaces, workspace_name)
        local apps = windows_by_workspace[workspace_name] or {}

        local no_apps = (#apps == 0)

        -- get unique icons ids for all active windows
        local app_icons_set = {}
        for _, app in ipairs(apps) do
            app_name = app["app-name"] or "Default"
            icon_id = app_icons[app_name] or ":default:"
            app_icons_set[icon_id] = true
        end

        -- get keys from active app icon set
        local app_icon_ids = {}
        for id in pairs(app_icons_set) do
            table.insert(app_icon_ids, id)
        end

        local icon_strip = "—"
        if next(app_icon_ids) ~= nil then
            icon_strip = table.concat(app_icon_ids, " ")
        end

        print("icon_strip", icon_strip)

        local bg_color, fg_color
        if is_visible then
            if is_focused then
                bg_color = colors.hotpink
                fg_color = colors.white
            else
                bg_color = colors.hotpink2
                fg_color = colors.offwhite
            end
        else
            if is_focused then
                bg_color = colors.cyan
                fg_color = colors.offwhite
            else
                bg_color = colors.cyan2
                fg_color = colors.offwhite
            end
        end

        local should_draw = not no_apps or is_visible

        entry:set({
            icon = {highlight = is_visible, highlight_color = fg_color},
            label = {
                string = icon_strip,
                highlight = true,
                highlight_color = fg_color
            },
            background = {
                color = colors.with_alpha(bg_color, 0.85),
            },
            drawing = should_draw,
            display = relevant_spaces[workspace_name] or 1
        })
    end
end

local function create_observer()
    print("observer init")

    local space_window_observer = sbar.add("item", {drawing = false, updates = true})
    space_window_observer:subscribe("aerospace_workspace_changed", function(env)
        -- TODO: Probably can refine updating to just the new/previous workspaces.
        -- See https://nikitabobko.github.io/AeroSpace/guide#exec-on-workspace-change-callback.
        print("workspace changed")
        update_workspaces()
    end)
    space_window_observer:subscribe("refresh_workspaces",
                                    function(env) update_workspaces() end)
    space_window_observer:subscribe("front_app_switched",
                                    function(env) update_workspaces() end)
    space_window_observer:subscribe({"system_woke", "reload_aerospace"},
                                    function(env) sbar.aerospace:reconnect() end)
end

local function initialize()
    for i = 0, 9 do create_empty_workspace(tostring(i), 1) end
    update_workspaces()
    create_observer()
end

initialize()
