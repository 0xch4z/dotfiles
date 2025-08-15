{ self, config, pkgs, lib, ... }:
let
  cfg = config.x.home.desktop.aerospace;

  inherit (self.lib) types mkEnabledOption mkOption;

  findWindowScript = pkgs.writeScriptBin "aerospace-find-window.sh" ''
    #!${lib.getExe pkgs.python3}
    import subprocess
    import json
    import sys

    def run_cmd(args, stdin=None):
      return subprocess.run(args, capture_output=True, text=True, input=stdin).stdout

    aerospace_windows = json.loads(run_cmd([
      "aerospace", 
      "list-windows",
      "--format",
      "%{app-name}%{window-id}%{window-title}%{workspace}%{monitor-name}",
      "--all",
      "--json",
    ]))

    windows = dict()

    for window in aerospace_windows:
      window_id = window["window-id"]
      option = f"{window['app-name']:<15} {window['window-title']:<40} {window['monitor-name']:<5}"

      windows[option] = window_id

    selected_window = run_cmd(["${lib.getExe pkgs.choose-gui}"], stdin="\n".join(windows.keys()))

    if selected_window not in windows:
      print("couldn't find window", selected_window)
      sys.exit(1)

    run_cmd(["aerospace", "focus", "--window-id", str(windows[selected_window])])
  '';
in {
  options.x.home.desktop.aerospace = {
    jankyborders.enable = mkEnabledOption "enable jankyborders";

    workspaceMap = mkOption {
      type = with types; attrsOf (oneOf [ int str (listOf str) ]);
      default = { };
    };

    extraBindings = {
      normal = mkOption {
        type = types.attrsOf types.str;
        default = { };
      };
      service = mkOption {
        type = types.attrsOf types.str;
        default = { };
      };
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "extra configuration for aerospace";
    };
  };

  config = lib.mkIf (config.x.home.desktop.backend == "aerospace") {
    programs.aerospace = {
      package = pkgs.unstable.aerospace;

      enable = true;
      userSettings = {
        start-at-login = true;

        after-startup-command = [
          "exec-and-forget ${lib.getExe pkgs.jankyborders}"
          "exec-and-forget ${lib.getExe pkgs.sketchybar}"
        ];

        on-window-detected = [{ run = [ "layout floating" ]; }];

        exec-on-workspace-change = [
          "${lib.getExe pkgs.bash}"
          "-c"
          "${
            lib.getExe pkgs.sketchybar
          } --trigger aerospace_workspace_changed FOCUSED=$AEROSPACE_FOCUSED_WORKSPACE"
        ];

        gaps = {
          inner.horizontal = 8;
          inner.vertical = 8;
          outer.top = 8;
          outer.bottom = 45; # for sketchybar
          outer.left = 8;
          outer.right = 8;
        };

        workspace-to-monitor-force-assignment = cfg.workspaceMap;

        mode.service.binding = {
          esc = [ "reload-config" "mode main" ];

          r = [ "flatten-workspace-tree" "mode main" ]; # reset

          backspace = [ "close-all-windows-but-current" "mode main" ];
        } // cfg.extraBindings.service;

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

          alt-space = "exec-and-forget ${lib.getExe findWindowScript}";

          alt-shift-minus = "resize smart -10";
          alt-shift-equal = "resize smart +10";
        } // cfg.extraBindings.normal;
      };
    };

    services.skhd = {
      enable = true;
      config = ''
        cmd - return : open --new -a ${lib.getExe pkgs.alacritty}
        alt - space : ${lib.getExe findWindowScript}
        alt + shift - s : ${lib.getExe pkgs.sketchybar} --reload
        alt + shift - r : ${lib.getExe pkgs.aerospace} --reload-config
      '';
    };

    services.jankyborders = lib.mkIf cfg.jankyborders.enable {
      enable = true;
      settings = {
        hidpi = "on";
        active_color = "0xff69b4ff";
        inactive_color = "0x00ffffff";
      };
    };
  };
}
