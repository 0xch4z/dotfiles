local target_line = tonumber(vim.env.KITTY_SCROLLBACK_LINE) or 1
local output_lines = {}

vim.keymap.set("n", "q", "<Cmd>quit!<CR>", { silent = true })
vim.keymap.set("n", "<Esc>", "<Cmd>quit!<CR>", { silent = true })
vim.keymap.set("n", "<CR>", "<Cmd>quit!<CR>", { silent = true })
vim.opt.clipboard = "unnamedplus"
vim.cmd("highlight Normal guibg=NONE ctermbg=NONE")
vim.cmd("highlight Visual guibg=#ff79c6 guifg=#000000")

vim.api.nvim_create_autocmd("TermRequest", {
  callback = function(event)
    if event.data.sequence:match("^\027%]133;C") then
      output_lines[#output_lines + 1] = event.data.cursor[1]
    end
  end,
})

vim.api.nvim_open_term(0, {})
vim.opt_local.modified = false
vim.opt_local.list = false
vim.cmd.stopinsert()

vim.defer_fn(function()
  local line = target_line
  local distance = math.huge

  for _, candidate in ipairs(output_lines) do
    local candidate_distance = math.abs(candidate - target_line)
    if candidate_distance < distance then
      line = candidate
      distance = candidate_distance
    end
  end

  line = math.max(1, math.min(line, vim.api.nvim_buf_line_count(0)))
  vim.api.nvim_win_set_cursor(0, { line, 0 })
  vim.cmd("normal! zt")
end, 50)
