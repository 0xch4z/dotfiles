{ lib, user, ... }: {
  imports = [
    ../../roles/work-macos
    ../../profiles/work-macos
  ];

  home.stateVersion = lib.mkForce "22.11";
  home.homeDirectory = "/Users/${user}";

  programs.firefox.enable = true;

  programs.aerospace = {
    enable = true;
    userSettings = {
      start-at-login = true;

      on-window-detected = [
        {
          run = [ "layout floating" ];
        }
      ];

      gaps = {
        inner.horizontal = 8;
        inner.vertical = 8;
        outer.top = 8;
        outer.bottom = 8;
        outer.left = 8;
        outer.right = 8;
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

        alt-1 = "workspace 1";
        alt-2 = "workspace 2";
        alt-3 = "workspace 3";
        alt-4 = "workspace 4";
        alt-5 = "workspace 5";
        alt-6 = "workspace 6";
        alt-7 = "workspace 7";
        alt-8 = "workspace 8";
        alt-9 = "workspace 9";
        alt-0 = "workspace 10";

        alt-shift-1 = "move-node-to-workspace 1";
        alt-shift-2 = "move-node-to-workspace 2";
        alt-shift-3 = "move-node-to-workspace 3";
        alt-shift-4 = "move-node-to-workspace 4";
        alt-shift-5 = "move-node-to-workspace 5";
        alt-shift-6 = "move-node-to-workspace 6";
        alt-shift-7 = "move-node-to-workspace 7";
        alt-shift-8 = "move-node-to-workspace 8";
        alt-shift-9 = "move-node-to-workspace 9";
        alt-shift-0 = "move-node-to-workspace 10";

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

