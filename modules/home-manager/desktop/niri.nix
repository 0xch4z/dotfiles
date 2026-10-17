{
  self,
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.x.home.desktop.niri;

  inherit (self.lib) types mkOption;

  vicinae = lib.getExe pkgs.vicinae;
  wtype = lib.getExe pkgs.wtype;
  whichKey = lib.getExe pkgs.wlr-which-key;

  locked =
    action:
    {
      _props.allow-when-locked = true;
    }
    // action;

  volume =
    arg:
    locked {
      spawn = [
        "ashell"
        "msg"
        arg
      ];
    };

  ctrlKey = key: {
    spawn = [
      wtype
      "-M"
      "ctrl"
      "-k"
      key
      "-m"
      "ctrl"
    ];
  };

  workspaceBinds = lib.listToAttrs (
    lib.concatMap (n: [
      (lib.nameValuePair "Alt+${toString n}" { focus-workspace = n; })
      (lib.nameValuePair "Alt+Shift+${toString n}" { move-column-to-workspace = n; })
    ]) (lib.range 1 9)
  );

  outputNodes = map (output: {
    output = {
      _args = [ output.name ];
    }
    // lib.optionalAttrs (output.mode != null) { mode = output.mode; }
    // lib.optionalAttrs (output.scale != null) { scale = output.scale; }
    // {
      position._props = {
        inherit (output) x y;
      };
    };
  }) cfg.outputs;
in
{
  options.x.home.desktop.niri = {
    render.device = mkOption {
      type = types.str;
      default = "";
    };

    outputs = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            name = mkOption { type = types.str; };
            mode = mkOption {
              type = types.nullOr types.str;
              default = null;
            };
            scale = mkOption {
              type = types.nullOr types.number;
              default = null;
            };
            x = mkOption {
              type = types.int;
              default = 0;
            };
            y = mkOption {
              type = types.int;
              default = 0;
            };
          };
        }
      );
      default = [ ];
    };

    rounding = mkOption {
      type = types.int;
      default = 12;
      description = "Window corner radius; niri rounds the focus ring to match.";
    };

    gaps = mkOption {
      type = types.int;
      default = 8;
      description = "Gaps between windows.";
    };

    struts = {
      top = mkOption {
        type = types.int;
        default = 8;
      };
      bottom = mkOption {
        type = types.int;
        default = 8;
      };
      left = mkOption {
        type = types.int;
        default = 8;
      };
      right = mkOption {
        type = types.int;
        default = 8;
      };
    };

    theme = {
      activeBorderColor = mkOption {
        type = types.str;
        default = "#ff69b4";
      };

      inactiveBorderColor = mkOption {
        type = types.str;
        default = "#dddddd";
      };
    };
  };

  config = lib.mkIf (config.x.home.desktop.backend == "niri") {
    x.home.desktop.wayland = {
      dpmsCommand = {
        off = "niri msg action power-off-monitors";
        on = "niri msg action do-screen-transition";
      };
      exitCommand = "niri msg action quit --skip-confirmation";
    };

    wayland.windowManager.niri = {
      enable = true;
      package = pkgs.niri;
      systemd.enable = true;

      settings = {
        input = {
          keyboard.xkb.layout = "us";
          keyboard.repeat-rate = 50;
          keyboard.repeat-delay = 200;
          focus-follows-mouse._props.max-scroll-amount = "0%";
        };

        prefer-no-csd = { };
        screenshot-path = "~/Pictures/Screenshots/Screenshot-%Y-%m-%d_%H-%M-%S.png";

        layout = {
          gaps = cfg.gaps;
          struts = {
            inherit (cfg.struts)
              top
              bottom
              left
              right
              ;
          };
          center-focused-column = "never";
          focus-ring = {
            width = 2;
            active-color = cfg.theme.activeBorderColor;
            inactive-color = cfg.theme.inactiveBorderColor;
          };
          default-column-width.proportion = 0.5;
        };

        hotkey-overlay.skip-at-startup = { };

        binds = {
          "Super+Space".spawn = [
            vicinae
            "toggle"
          ];
          "Super+P".spawn = [
            vicinae
            "vicinae://launch/@bl4zee1g/store.vicinae.bitwarden/browse-vault?toggle=true"
          ];
          "Super+Return".spawn = [ "alacritty" ];
          "Ctrl+grave".spawn = [ whichKey ];

          "Super+Q".close-window = { };
          "Super+W" = ctrlKey "w";
          "Super+A" = ctrlKey "a";
          "Super+X" = ctrlKey "x";
          "Super+Z" = ctrlKey "z";

          "Alt+F".toggle-window-floating = { };
          "Alt+H".focus-column-left = { };
          "Alt+L".focus-column-right = { };
          "Alt+Shift+P".move-column-left = { };
          "Alt+Shift+N".move-column-right = { };

          "Super+F".fullscreen-window = { };
          "Alt+Shift+F".maximize-column = { };
          "Alt+R".switch-preset-column-width = { };
          "Alt+Minus".set-column-width = "-10%";
          "Alt+Equal".set-column-width = "+10%";
          "Alt+Shift+Minus".set-window-height = "-10%";
          "Alt+Shift+Equal".set-window-height = "+10%";

          "Super+Shift+3".screenshot-screen = { };
          "Super+Shift+4".screenshot = { };
          "Super+Shift+Delete".power-off-monitors = { };
          "Super+Shift+E".quit = { };

          "XF86AudioMute" = volume "volume-toggle-mute";
          "XF86AudioRaiseVolume" = volume "volume-up";
          "XF86AudioLowerVolume" = volume "volume-down";
        }
        // workspaceBinds;

        _children = outputNodes ++ [
          {
            window-rule = {
              geometry-corner-radius = cfg.rounding;
              clip-to-geometry = true;
            };
          }
        ];
      }
      // lib.optionalAttrs (cfg.render.device != "") {
        debug.render-drm-device = cfg.render.device;
      };
    };
  };
}
