{
  self,
  config,
  pkgs,
  lib,
  homeDir,
  ...
}:
let
  cfg = config.x.home.desktop.rift;

  inherit (self.lib) mkEnabledOption mkOption types;

  tomlFormat = pkgs.formats.toml { };

  terminal = lib.getExe pkgs.alacritty;

  withSketchybar = config.x.home.taskbar.sketchybar.enable;

  # the event payload is appended to argv, so the subscription runs through a
  # shell to keep it out of sketchybar's arguments
  sketchybarTrigger =
    event: rift_event:
    "${cfg.package}/bin/rift-cli subscribe cli --event ${rift_event}"
    + " --command ${lib.getExe pkgs.bash} --args -c"
    + " '${lib.getExe pkgs.sketchybar} --trigger ${event}'";

  unmanagedScript = pkgs.writeScriptBin "rift-unmanaged" ''
    #!${lib.getExe pkgs.python3}
    import json
    import subprocess
    import sys
    import time

    RIFT = "${cfg.package}/bin/rift-cli"
    OSASCRIPT = "/usr/bin/osascript"

    ADOPT_TIMEOUT = 2.0
    ADOPT_POLL = 0.1


    def rift(*args):
      result = subprocess.run([RIFT, *args], capture_output=True, text=True)
      if result.returncode != 0 or not result.stdout.strip():
        return None
      return json.loads(result.stdout)


    def placed():
      """{(pid, idx): workspace index} for every window rift has assigned."""
      windows = {}
      for display in rift("query", "displays") or []:
        workspaces = rift("query", "workspaces", "--display", display["uuid"]) or []
        for workspace in workspaces:
          for window in workspace["windows"] or []:
            key = (window["id"]["pid"], window["id"]["idx"])
            windows[key] = workspace["index"]
      return windows


    def gaps(assigned):
      """Apps with more windows in rift's store than it has placed.

      window_count comes from the raw window store, which keeps a window after
      is_manageable goes false. Windows rejected during discovery (no window
      server id, no visible CG peer) never enter the store, so they cannot be
      reported here at all.
      """
      counted = {}
      for pid, _ in assigned:
        counted[pid] = counted.get(pid, 0) + 1

      found = []
      for app in rift("query", "applications") or []:
        missing = app["window_count"] - counted.get(app["pid"], 0)
        if missing > 0:
          found.append((app, missing))
      return found


    def unminimize(pid):
      script = f"""
        tell application "System Events"
          repeat with proc in (every process whose unix id is {pid})
            repeat with win in (every window of proc)
              try
                if value of attribute "AXMinimized" of win is true then
                  set value of attribute "AXMinimized" of win to false
                end if
              end try
            end repeat
          end repeat
        end tell
      """
      result = subprocess.run([OSASCRIPT, "-e", script], capture_output=True, text=True)
      if result.returncode != 0:
        print(f"  could not un-minimize pid {pid}: {result.stderr.strip()}")


    def adopted(before):
      """Windows rift assigned since `before`, waiting for it to notice."""
      deadline = time.monotonic() + ADOPT_TIMEOUT
      while time.monotonic() < deadline:
        current = placed()
        new = {key: ws for key, ws in current.items() if key not in before}
        if new:
          return new
        time.sleep(ADOPT_POLL)
      return {}


    def describe(app, missing):
      bundle = app["bundle_id"] or "?"
      plural = "window" if missing == 1 else "windows"
      return f"{app['name']} ({bundle}): {missing} unplaced {plural}"


    def report(assigned):
      found = gaps(assigned)
      if not found:
        print("rift has placed every window it knows about")
        return found

      for app, missing in found:
        print(describe(app, missing))
      return found


    def sweep():
      before = placed()
      found = gaps(before)
      if not found:
        print("nothing to sweep")
        return

      for app, missing in found:
        print(describe(app, missing))
        unminimize(app["pid"])

      moved = 0
      for (_, idx), workspace in adopted(before).items():
        if workspace == 0:
          continue
        if rift("execute", "workspace", "move-window", "0", str(idx)) is not None:
          moved += 1
      print(f"moved {moved} to workspace 0")

      for app, missing in gaps(placed()):
        bundle = app["bundle_id"]
        print(f"still unplaced: {describe(app, missing)}")
        if bundle:
          print(
            "  rift cannot move these; to force management add:\n"
            f'    {{ app_id = "{bundle}"; manage = true; workspace = 0; }}'
          )


    if __name__ == "__main__":
      if "--sweep" in sys.argv[1:]:
        sweep()
      else:
        report(placed())
  '';

  defaultSettings = {
    settings = {
      animate = true;
      animation_duration = 0.2;
      animation_fps = 120.0;

      # spaces are managed as soon as rift sees them, like aerospace
      default_disable = false;

      focus_follows_mouse = false;
      mouse_follows_focus = false;

      hot_reload = true;

      run_on_start = lib.optionals withSketchybar [
        (sketchybarTrigger "rift_workspace_changed" "workspace_changed")
        (sketchybarTrigger "rift_windows_changed" "windows_changed")
      ];

      layout = {
        mode = "traditional";
        window_insertion_point = "next_to_selection";

        gaps = {
          inner = {
            horizontal = 8;
            vertical = 8;
          };
          outer = {
            top = 8;
            left = 8;
            right = 8;
            bottom = 45; # for sketchybar
          };
        };
      };

      # sketchybar already draws workspace indicators
      ui.menu_bar = {
        enabled = !withSketchybar;
        display_style = "label";
        active_label = "index";
      };
    };

    virtual_workspaces = {
      enabled = true;
      default_workspace_count = 10;
      preserve_focus_per_workspace = true;
      workspace_auto_back_and_forth = false;

      # keeps the bar labels and `switch_to_workspace` bindings lined up
      workspace_names = map toString (lib.range 0 9);
    };

    keys = {
      "Alt + Z" = "toggle_space_activated";
      "Alt + Shift + R" = "reload_config";

      "Alt + H" = {
        move_focus = "left";
      };
      "Alt + J" = {
        move_focus = "down";
      };
      "Alt + K" = {
        move_focus = "up";
      };
      "Alt + L" = {
        move_focus = "right";
      };
      "Alt + N" = {
        move_focus = "right";
      };
      "Alt + P" = {
        move_focus = "left";
      };

      "Alt + Shift + H" = {
        move_node = "left";
      };
      "Alt + Shift + J" = {
        move_node = "down";
      };
      "Alt + Shift + K" = {
        move_node = "up";
      };
      "Alt + Shift + L" = {
        move_node = "right";
      };
      "Alt + Shift + N" = {
        move_node = "right";
      };
      "Alt + Shift + P" = {
        move_node = "left";
      };

      "Alt + T" = {
        set_workspace_layout.mode = "traditional";
      };
      "Alt + B" = {
        set_workspace_layout.mode = "bsp";
      };
      "Alt + A" = {
        set_workspace_layout.mode = "master_stack";
      };
      "Alt + S" = {
        set_workspace_layout.mode = "scrolling";
      };

      "Alt + F" = "toggle_window_floating";
      "Alt + Shift + F" = "toggle_fullscreen";
      "Alt + Comma" = "toggle_stack";
      "Alt + Slash" = "toggle_orientation";

      "Alt + Shift + Equal" = "resize_window_grow";
      "Alt + Shift + Minus" = "resize_window_shrink";

      "Alt + Tab" = "switch_to_last_workspace";
      "Alt + Shift + Tab" = {
        move_workspace_to_display = {
          selector = "right";
          wrap_around = true;
        };
      };

      "Alt + Shift + G" = {
        exec = [
          "${lib.getExe unmanagedScript}"
          "--sweep"
        ];
      };

      "Meta + Enter" = {
        exec = [
          "${lib.getExe pkgs.bash}"
          "-c"
          "open --new -a ${terminal}"
        ];
      };
    }
    // lib.listToAttrs (
      lib.concatMap (n: [
        (lib.nameValuePair "Alt + ${toString n}" { switch_to_workspace = n; })
        (lib.nameValuePair "Alt + Shift + ${toString n}" { move_window_to_workspace = n; })
      ]) (lib.range 0 9)
    )
    // cfg.extraBindings;
  };
in
{
  options.x.home.desktop.rift = {
    package = mkOption {
      type = types.package;
      default = pkgs.x.rift;
    };

    jankyborders.enable = mkEnabledOption "enable jankyborders";

    extraBindings = mkOption {
      type = with types; attrsOf (either str attrs);
      default = { };
    };

    settings = mkOption {
      type = tomlFormat.type;
      default = { };
      description = "merged over the module defaults";
    };
  };

  config = lib.mkIf (config.x.home.desktop.backend == "rift") {
    home.packages = [
      cfg.package
      unmanagedScript
    ];

    xdg.configFile."rift/config.toml".source = tomlFormat.generate "rift-config.toml" (
      lib.recursiveUpdate defaultSettings cfg.settings
    );

    launchd.agents.rift = {
      enable = true;
      config = {
        ProgramArguments = [ "${cfg.package}/bin/rift" ];
        KeepAlive.Crashed = true;
        RunAtLoad = true;
        ProcessType = "Interactive";
        LimitLoadToSessionType = "Aqua";
        Nice = -20;
        EnvironmentVariables = {
          PATH = "${cfg.package}/bin:/usr/bin:/bin:/usr/sbin:/sbin";
          RUST_LOG = "error,warn,info";
        };
        StandardOutPath = "${homeDir}/Library/Logs/rift/stdout";
        StandardErrorPath = "${homeDir}/Library/Logs/rift/stderr";
      };
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
