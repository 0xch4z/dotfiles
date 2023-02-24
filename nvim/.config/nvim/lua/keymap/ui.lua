local map = require("keymap.map")
local cmd = map.cmd

local mappings = {
    -- TODO: search on current line <leader>\\, get line number, run :/%LINE

    -- Disable stupid fucking recording mode
    ["n|q"] = cmd("<Nop>"),

    -- Window navigation
    ["n|<leader>wH"] = cmd("<c-w>H"):noremap():desc("window: move left"),
    ["n|<leader>wJ"] = cmd("<c-w>J"):noremap():desc("window: move up"),
    ["n|<leader>wK"] = cmd("<c-w>K"):noremap():desc("window: move down"),
    ["n|<leader>wL"] = cmd("<c-w>L"):noremap():desc("window: move right"),
    ["n|<leader>wh"] = cmd("<c-w>h"):noremap():desc("window: go left"),
    ["n|<leader>wj"] = cmd("<c-w>j"):noremap():desc("window: go up"),
    ["n|<leader>wk"] = cmd("<c-w>k"):noremap():desc("window: go down"),
    ["n|<leader>wl"] = cmd("<c-w>l"):noremap():desc("window: go right"),

    -- Buffer lifecycle/navigation
    ["n|<leader>q"] = cmd("q"):noremap():desc("buffer: quit"),
    ["n|<leader>qa"] = cmd("qa"):noremap():desc("buffer: quit all"),
    ["n|<leader>k"] = cmd("q!"):noremap():desc("buffer: kill"),
    ["n|<leader>ka"] = cmd("xa!"):noremap():desc("buffer: kill all"),
    ["n|,"] = cmd("bprevious"):noremap():desc("buffer: prev"),
    ["n|."] = cmd("bnext"):noremap():desc("buffer: prev"),

    -- Misc
    ["n|<leader>nh"] = cmd("noh"):noremap():desc("search: clear highlight"),
}

map.register_keys(mappings)
