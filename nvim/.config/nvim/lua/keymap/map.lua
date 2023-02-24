local map = {}

--- Mapping represents a key mapping
local Mapping = {}

--- Creates a new Mapping
-- @param action string or function: The action to perform
-- @returns a Mapping instance
function Mapping:new(action)
    local instance = {
        cmd = "",
        options = {
            noremap = false,
            silent = true,
            desc = "",
            callback = nil,
        },
    }

    local action_type = type(action)
    if action_type == "function" then
        instance.options.callback = action
    elseif action_type == "string" then
        instance.cmd = action
    else
        error("Binding must be created with a function or a string command")
    end

    setmetatable(instance, self)
    self.__index = self
    return instance
end

function Mapping:get()
    return self
end

function Mapping:noremap()
    self.options.noremap = true
    return self
end

function Mapping:buffer(n)
    self.buffer = n
    return self
end

function Mapping:silent()
    self.options.silent = true
    return self
end

function Mapping:loud()
    self.options.silent = false
    return self
end

function Mapping:desc(desc)
    self.options.desc = desc
    return self
end

function Mapping:call(...)
    -- Call the function or run the command associated with the binding
    if self.func then
        self.func(...)
    elseif self.cmd then
        os.execute(self.cmd)
    end
end

function map.cmd(cmd)
    cmd = (":%s<CR>"):format(cmd)
    return Mapping:new(cmd)
end

function map.key(cmd)
    cmd = (":%s"):format(cmd)
    return Mapping:new(cmd)
end

function map.func(cb)
    return Mapping:new(cb)
end

function map.register_keys(mapping)
    for key, value in pairs(mapping) do
        local mode, seq = key:match("([^|]*)|?(.*)")
        if type(value) == "table" and getmetatable(value) == Mapping then
            local action = value.cmd
            local options = value.options
            local buf = value.buffer
            if buf and type(buf) == "number" then
                vim.api.nvim_buf_set_keymap(buf, mode, seq, action, options)
            else
                vim.api.nvim_set_keymap(mode, seq, action, options)
            end
        end
    end
end

return map
