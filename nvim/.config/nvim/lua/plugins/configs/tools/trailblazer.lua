local trailblazer = require('trailblazer')

trailblazer.setup({
  lang = "en",
  auto_save_trailblazer_state_on_exit = true,
  auto_load_trailblazer_state_on_enter = true, -- experimental
  custom_session_storage_dir = "~/.trailblazer-sessions",

  trail_options = {
    -- Priorty needs to be higher than other symbols in the gutter.
    -- Treesitter has a default priority of 100 for instance.
    trail_mark_priority = 10001,
    available_trail_mark_modes = {
      "global_chron",
      "global_buf_line_sorted",
      "global_fpath_line_sorted",
      "global_chron_buf_line_sorted",
      "global_chron_fpath_line_sorted",
      "global_chron_buf_switch_group_chron",
      "global_chron_buf_switch_group_line_sorted",
      "buffer_local_chron",
      "buffer_local_line_sorted"
    },

    -- The current / initially selected trail mark selection mode. Choose from one of the
    -- available modes: global_chron, global_buf_line_sorted, global_chron_buf_line_sorted,
    -- global_chron_buf_switch_group_chron, global_chron_buf_switch_group_line_sorted,
    -- buffer_local_chron, buffer_local_line_sorted
    current_trail_mark_mode = "global_chron",
    current_trail_mark_list_type = "quickfix", -- currently only quickfix lists are supported
    trail_mark_list_rows = 10, -- number of rows to show in the trail mark list
    verbose_trail_mark_select = true, -- print current mode notification on mode change
    mark_symbol = "•", --  will only be used if trail_mark_symbol_line_indicators_enabled = true
    newest_mark_symbol = "⬤", -- disable this mark symbol by setting its value to ""
    cursor_mark_symbol = "⬤", -- disable this mark symbol by setting its value to ""
    next_mark_symbol = "⬤", -- disable this mark symbol by setting its value to ""
    previous_mark_symbol = "⬤", -- disable this mark symbol by setting its value to ""
    multiple_mark_symbol_counters_enabled = true,
    number_line_color_enabled = true,
    trail_mark_in_text_highlights_enabled = true,
    trail_mark_symbol_line_indicators_enabled = false, -- show indicators for all trail marks in symbol column
    symbol_line_enabled = true,
    default_trail_mark_stacks = {
      -- this is the list of trail mark stacks that will be created by default. Add as many
      -- as you like to this list. You can always create new ones in Neovim by using either
      -- `:TrailBlazerSwitchTrailMarkStack <name>` or `:TrailBlazerAddTrailMarkStack <name>`
      "default" -- , "stack_2", ...
    },
    available_trail_mark_stack_sort_modes = {
      "alpha_asc", -- alphabetical ascending
      "alpha_dsc", -- alphabetical descending
      "chron_asc", -- chronological ascending
      "chron_dsc", -- chronological descending
    },
    -- The current / initially selected trail mark stack sort mode. Choose from one of the
    -- available modes: alpha_asc, alpha_dsc, chron_asc, chron_dsc
    current_trail_mark_stack_sort_mode = "alpha_asc"
  },
  mappings = {
    nv = {
      motions = {
        new_trail_mark = 'mn',
        track_back = 'mb',
        peek_move_next_down = 'mj',
        peek_move_previous_up = 'mk',
        move_to_nearest = 'mm',
        toggle_trail_mark_list = 'ml',
      },
      actions = {
        delete_all_trail_marks = 'md',
        paste_at_last_trail_mark = 'mp',
        paste_at_all_trail_marks = 'mP',
        set_trail_mark_select_mode = 'mt',
        switch_to_next_trail_mark_stack = '<A-.>',
        switch_to_previous_trail_mark_stack = '<A-,>',
        set_trail_mark_stack_sort_mode = '<A-s>',
      },
    },
      -- You can also add/move any motion or action to mode specific mappings i.e.:
      -- i = {
      --     motions = {
      --         new_trail_mark = '<C-l>',
      --         ...
      --     },
      --     ...
      -- },
  },
  quickfix_mappings = { -- rename this to "force_quickfix_mappings" to completely override default mappings and not merge with them
    nv = {
      motions = {
        qf_motion_move_trail_mark_stack_cursor = "<CR>",
      },
      actions = {
        qf_action_delete_trail_mark_selection = "d",
        qf_action_save_visual_selection_start_line = "v",
      },
      alt_actions = {
        qf_action_save_visual_selection_start_line = "V",
      }
    },
    v = {
      actions = {
        qf_action_move_selected_trail_marks_down = "<C-j>",
        qf_action_move_selected_trail_marks_up = "<C-k>",
      },
    },
  },
})
