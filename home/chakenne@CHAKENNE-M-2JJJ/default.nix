{ homeDir, config, pkgs, lib, user, ... }: {
  x.role = "mac-workstation";
  x.home.applications.passwords._1pass.enable = true;
  x.home.editor.neovim.nightly = true;
  x.home.secrets.enable = true;
  x.home.taskbar.sketchybar.enable = true;

  home.stateVersion = lib.mkForce "22.11";
  home.homeDirectory = "/Users/${user}";

  home.packages = with pkgs; [
    gh
  ];


### SKETCHYBAR

  # entrypoint for config
  xdg.configFile."sketchybar/sketchybarrc" = {
    text =
      # lua
      ''
        #! ${pkgs.lua5_4_compat}/bin/lua
        package.cpath = package.cpath
          .. ";${pkgs.lua54Packages.cjson}/lib/lua/5.4/?.so"
          .. ";${pkgs.lua54Packages.luaposix}/lib/lua/5.4/?.so"
          .. ";${pkgs.x.sbarlua}/lib/?.so"

        package.path = package.path
          .. ";${config.xdg.configHome}/sketchybar/?/init.lua"
          .. ";${config.xdg.configHome}/sketchybar/config/?.lua"

        require("config")
      '';
    executable = true;
  };

  xdg.configFile."sketchybar/nix_bridge.lua".text = ''
    return {
      cmds = {
        is-macbook-display-only = "${pkgs.x.is-macbook-display-only}/bin/is-macbook-display-only"
      }
    }
  '';

  xdg.configFile.sketchybar = {
    enable = true;
    recursive = true;
    source = config.lib.file.mkOutOfStoreSymlink
      "${homeDir}/.dotfiles/home/chakenne@CHAKENNE-M-2JJJ/config/";
    target = "sketchybar/config";
  };

### AEROSPACE

  services.jankyborders = {
    enable = true;
    settings = {
      hidpi = "on";
      active_color = "0xff69b4ff";
      inactive_color = "0x00ffffff";
    };
  };

  programs.aerospace = {
    enable = true;
    userSettings = {
      start-at-login = true;

      after-startup-command = [
        "exec-and-forget ${lib.getExe pkgs.jankyborders}"
      ];

      on-window-detected = [
        {
          run = [ "layout floating" ];
        }
      ];

      gaps = {
        inner.horizontal = 8;
        inner.vertical = 8;
        outer.top = 30;
        outer.bottom = 45; # for sketchybar
        outer.left = 8;
        outer.right = 8;
      };

      workspace-to-monitor-force-assignment = {
        # Monitor 1 (first in sorted order): workspaces 0-5 (0 for floating)
        "0" = 2; "1" = 2; "2" = 2; "3" = 2; "4" = 2; "5" = 2;

        # Monitor 2 (second in sorted order): workspaces 4-9 (9 for floating)
        "6" = 1; "7" = 1; "8" = 1; "9" = 1;
      };

      mode.service.binding = {
        esc = [
          "reload-config"
          "mode main"
        ];

        r = [
          "flatten-workspace-tree"
          "mode main"
        ]; # reset

        backspace = [
          "close-all-windows-but-current"
          "mode main"
        ];
      };

      mode.main.binding = {
        # All possible keys:
        # - Letters         a-Z
        # - Numbers         0-9
        # - Keypad numbers  keypad0-keypad9
        # - F-keys          f1-f20
        # - Special keys    minus, equal, period, comma, slash, backslash, quote, semicolon,
        #                   backtick, leftSquareBracket, rightSquareBracket, space, enter, esc,
        #                   backspace, tab, pageUp, pageDown, home, end, forwardDelete,
        #                   sectionSign (ISO keyboards only, european keyboards only)
        # - Keypad special  keypadClear, keypadDecimalMark, keypadDivide, keypadEnter, keypadEqual,
        #                   keypadMinus, keypadMultiply, keypadPlus
        # - Arrows          left, down, up, right
        #
        # All possible modifiers: cmd, alt, ctrl, shift
        #
        # All possible commands: https://nikitabobko.github.io/AeroSpace/commands

        alt-shift-s = "mode service";

        alt-t = "layout tiles horizontal vertical";
        alt-a = "layout accordion horizontal vertical";
        alt-f = "layout floating tiling";

        alt-n = "focus right";
        alt-p = "focus left";

        alt-h = "focus left";
        alt-j = "focus down";
        alt-k = "focus up";
        alt-l = "focus right";

        alt-shift-n = "move right";
        alt-shift-p = "move left";

        alt-shift-h = "move left";
        alt-shift-j = "move down";
        alt-shift-k = "move up";
        alt-shift-l = "move right";

        alt-0 = "workspace 0";
        alt-1 = "workspace 1";
        alt-2 = "workspace 2";
        alt-3 = "workspace 3";
        alt-4 = "workspace 4";
        alt-5 = "workspace 5";
        alt-6 = "workspace 6";
        alt-7 = "workspace 7";
        alt-8 = "workspace 8";
        alt-9 = "workspace 9";

        alt-shift-0 = "move-node-to-workspace 0";
        alt-shift-1 = "move-node-to-workspace 1";
        alt-shift-2 = "move-node-to-workspace 2";
        alt-shift-3 = "move-node-to-workspace 3";
        alt-shift-4 = "move-node-to-workspace 4";
        alt-shift-5 = "move-node-to-workspace 5";
        alt-shift-6 = "move-node-to-workspace 6";
        alt-shift-7 = "move-node-to-workspace 7";
        alt-shift-8 = "move-node-to-workspace 8";
        alt-shift-9 = "move-node-to-workspace 9";

        alt-tab = "workspace-back-and-forth";
        alt-shift-tab = "move-workspace-to-monitor --wrap-around next";

        alt-slash = "layout tiles horizontal vertical";
        alt-minus = "layout accordion horizontal vertical";

        alt-shift-minus = "resize smart -10";
        alt-shift-equal = "resize smart +10";
      };
    };
  };
}
