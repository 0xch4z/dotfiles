local g = vim.g
local fn = vim.fn

g.startify_files_number = 10
g.startify_change_to_dir = 0

g.startify_lists = {
  {type = "dir", header = {"  💾 MRU: " .. fn.getcwd()}},
  {type = "bookmarks", header = {"  📖 Bookmarks"}},
  {type = "commands", header = {"  💻 Commands"}},
}

g.startify_bookmarks = {
  {c = "~/.dotfiles/nvim/.config/nvim"},
  {d = "~/.dotfiles"},
}

g.startify_commands = {
  {up = {"Update Plugins", ":Lazy update"}},
  {ug = {"Debug Plugins", ":Lazy debug"}},
  {ts = {"Update Treesitter", "TSUpdate"}},
  {ch = {"Check Health", "checkhealth"}}
}

