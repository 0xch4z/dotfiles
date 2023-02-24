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
