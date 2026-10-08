{
  config,
  pkgs,
  self,
  ...
}:
let
  inherit (self.lib) mkEnabledOption mkIf;
  cfg = config.x.home.shell.tuios;
  configPath =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "Library/Application Support/tuios/config.toml"
    else
      ".config/tuios/config.toml";
  newWorkspace = pkgs.writeShellApplication {
    name = "tuios-new-workspace";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.jq
      pkgs.x.tuios
    ];
    text = ''
      workspace="$(
        tuios list-workspaces --json |
          jq -r '.workspaces[] | select(.window_count == 0) | .workspace' |
          head -n 1
      )"
      test -n "$workspace"

      tuios new-window --workspace "$workspace" >/dev/null
      tuios select-workspace "$workspace"
    '';
  };
  newSession = pkgs.writeShellApplication {
    name = "tuios-new-session";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.fzf
      pkgs.x.tuios
      pkgs.zoxide
    ];
    text = ''
      directory="$(zoxide query -l | fzf --layout=reverse --prompt='directory> ')"
      test -n "$directory"

      default_name="$(basename "$directory")"
      printf 'session name [%s]: ' "$default_name"
      IFS= read -r session_name
      session_name="''${session_name:-$default_name}"

      tuios switch-session --create --cwd "$directory" "$session_name"
    '';
  };
in
{
  options.x.home.shell.tuios.enable = mkEnabledOption "Enable TUIOS home-manager module.";

  config = mkIf cfg.enable {
    home.packages = [ pkgs.x.tuios ];

    home.file.${configPath} = {
      force = true;
      text = ''
          [appearance]
          background = "off"
          border_style = "normal"
          border_focused_color = "#ff79c6"
          border_unfocused_color = "#666666"
          shared_borders = true
          gap = 0
          dockbar_position = "top"
          dock_compact = true
          window_title_position = "hidden"
          hide_window_buttons = true
          nvim_navigation = true
          scrollback_lines = 100000
          preferred_shell = "${pkgs.fish}/bin/fish"
          new_window_inherit_cwd = true
          whichkey_enabled = true
          whichkey_position = "bottom-right"

          [appearance.selection]
          bg = "#ff79c6"
          fg = "#000000"
          copy_entry = "cursor"
          osc52_write = "focused"

          [appearance.sidebar]
          position = "hidden"

          [daemon]
          persist_scrollback = true
          persist_scrollback_lines = 10000
          persist_scrollback_kb = 16384
          resume_agents = "ask"
          window_size = "latest"

          [startup]
          daemon = true
          tiled = true
          layout = "bsp"
          open_default_window = true
          start_in_terminal_mode = true

          [keybindings]
          leader_key = "ctrl+a"

          [keybindings.prefix_mode]
          prefix_new_window = []
          prefix_close_window = ["x"]
          prefix_next_window = ["tab"]
          prefix_prev_window = ["P", "shift+tab"]
          next_workspace = ["n"]
          terminal_focus_left = ["h", "left"]
          terminal_focus_down = ["j", "down"]
          terminal_focus_up = ["k", "up"]
          terminal_focus_right = ["l", "right"]
          prefix_split_horizontal = ["-"]
          prefix_split_vertical = ["|", "\\"]
          prefix_scrollback = []
          copy_mode_search_backward = ["/"]
          choose_tree = []
          prefix_selection = ["a", "["]
          prefix_session_switcher = ["s"]
          toggle_scratch = ["p", "g"]
          hints = ["f"]
          toggle_multifocus_all = ["`"]
          resize_master_shrink = ["L"]
          resize_master_grow = ["R"]
          resize_height_shrink = ["U"]
          resize_height_grow = ["D"]
          prefix_detach = ["d"]
          prefix_close_session = ["X"]
          prefix_quit = ["q"]
        prefix_next_attention = []
        prefix_next_finished = []
        prefix_jump_notif = []
        prefix_keybinds = []
        prefix_file_search = []
        prefix_debug = []
        prefix_layout = []
        prefix_rotate_split = []
        launcher = []

          [[keybindings.command]]
          key = "prefix+c"
          type = "shell"
          command = "${newWorkspace}/bin/tuios-new-workspace"
          description = "Create a tmux-style window"

          [[keybindings.command]]
          key = "prefix+o"
          type = "popup"
          command = "${newSession}/bin/tuios-new-session"
          description = "Create a named session from zoxide"
          width = "80%"
          height = "80%"
      '';
    };

  };
}
