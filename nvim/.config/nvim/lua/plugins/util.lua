local util = {}

--- Load returns a function to load and excute the given module
-- @param module string: the module to load
function util.load(module)
    return function()
        require(module)
    end
end

return util
