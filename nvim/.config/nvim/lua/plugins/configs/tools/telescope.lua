local telescope = require("telescope")
local actions = require("telescope.actions")
local previewers = require("telescope.previewers")

telescope.setup({
    defaults = {
        file_sorter = require("telescope.sorters").get_fzy_sorter,
        prompt_prefix = " >",
        color_devicons = true,
        file_previewer = previewers.vim_buffer_cat.new,
        grep_previewer = previewers.vim_buffer_vimgrep.new,
        qflist_previewer = previewers.vim_buffer_qflist.new,
        find_command = { "rg", "--files", "--hidden", "--glob", "'!*git*'" },
        file_ignore_patterns = { ".git/", "%.dll", ".cache", "%.class", "%.pdf", "%.o", "%.a", "%.tar", "%s.gz", "%.zip" },
        layout_strategy = "horizontal",path_display = { "absolute" },
        scroll_strategy = "limit",results_title = false,initial_mode = "insert",

        mappings = {
            i = {
                ["q"] = actions.close,
                ["<C-x>"] = false,
                ["<C-q>"] = actions.send_to_qflist,
                ["<CR>"] = actions.select_default,
            },
        },
    },
})
