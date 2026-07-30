{
  self,
  config,
  pkgs,
  lib,
  homeDir,
  ...
}:
let
  cfg = config.x.home.desktop.hyprland;

  inherit (self.lib)
    lists
    types
    mkEnabledOption
    mkOption
    ;
  inherit (lists) map range;

  nStrRange = lower: upper: map (n: toString n) (range lower upper);

  wallpaper = "${homeDir}/.dotfiles/assets/philly-dark.jpg";

  workspaceAnimation =
    let
      workspace = cfg.animations.workspace;
    in
    if workspace.enabled == false then
      "workspaces, 0"
    else
      "workspaces, 1, ${toString workspace.speed}, ${workspace.curve}"
      + lib.optionalString (workspace.style != null) ", ${workspace.style}";

  animationRules =
    cfg.animations.rules
    ++ lib.optionals (cfg.animations.workspace.enabled != null) [
      workspaceAnimation
    ];

  applyWallpaper = pkgs.writeShellApplication {
    name = "hyprpaper-apply-wallpaper";
    runtimeInputs = [
      pkgs.hyprland
      pkgs.coreutils
      pkgs.gnugrep
    ];
    text = ''
      for _ in $(seq 1 60); do
        hyprctl hyprpaper wallpaper "${cfg.wallpaperMonitor},${wallpaper}" 2>/dev/null || true
        if hyprctl hyprpaper listactive 2>/dev/null | grep -qF "${wallpaper}"; then
          exit 0
        fi
        sleep 0.5
      done
    '';
  };

  handleLidSwitch = pkgs.writeShellApplication {
    name = "hyprland-lid-switch";
    runtimeInputs = [
      pkgs.hyprland
      pkgs.coreutils
      pkgs.gnugrep
      pkgs.jq
    ];
    text = self.lib.templateFile {
      file = ./lid-switch.sh;
      data = {
        INTERNAL_MONITOR = lib.escapeShellArg cfg.lidSwitch.internalMonitor;
        INTERNAL_MONITOR_RULE = lib.escapeShellArg cfg.lidSwitch.internalMonitorRule;
        PREFERRED_EXTERNAL_MONITOR = lib.escapeShellArg cfg.lidSwitch.preferredExternalMonitor;
      };
    };
  };
in
{
  options.x.home.desktop.hyprland = {
    xwayland.enable = mkEnabledOption "enable Hyprland xwayland support.";

    wallpaperMonitor = mkOption {
      type = types.str;
      default = "";
      description = "Monitor selector used when applying the Hyprpaper wallpaper.";
    };

    scale = mkOption {
      type = types.ints.u8;
      default = 1;
      description = "GDK scaling factor.";
    };

    keyboardOptions = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "ctrl:nocaps" ];
      description = "XKB options for all Hyprland keyboard input devices.";
    };

    keyboardOptionsByDevice = mkOption {
      type = types.attrsOf (types.listOf types.str);
      default = { };
      example = {
        "at-translated-set-2-keyboard" = [
          "ctrl:nocaps"
          "altwin:swap_lalt_lwin"
        ];
      };
      description = "XKB options keyed by Hyprland keyboard device name.";
    };

    monitors = mkOption {
      type = types.listOf types.str;
      default = [ ",preferred,auto,1" ];
      description = "Hyprland monitor rules.";
    };

    workspaces = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Hyprland workspace rules.";
    };

    decoration = {
      rounding = mkOption {
        type = types.int;
        default = 3;
        description = "Window corner rounding radius.";
      };

      activeOpacity = mkOption {
        type = types.number;
        default = 1.0;
        description = "Opacity for active windows.";
      };

      inactiveOpacity = mkOption {
        type = types.number;
        default = 1.0;
        description = "Opacity for inactive windows.";
      };

      fullscreenOpacity = mkOption {
        type = types.number;
        default = 1.0;
        description = "Opacity for fullscreen windows.";
      };

      blur = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable Hyprland window background blur.";
        };

        size = mkOption {
          type = types.int;
          default = 16;
          description = "Hyprland blur size.";
        };

        passes = mkOption {
          type = types.int;
          default = 3;
          description = "Hyprland blur pass count.";
        };

        newOptimizations = mkOption {
          type = types.bool;
          default = true;
          description = "Enable Hyprland's optimized blur path.";
        };

        xray = mkOption {
          type = types.bool;
          default = false;
          description = "Allow floating window blur to ignore tiled windows.";
        };
      };
    };

    render.newRenderScheduling = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Hyprland's new render scheduling path.";
    };

    animations = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Hyprland animations.";
      };

      workspaceWraparound = mkOption {
        type = types.bool;
        default = false;
        description = "Enable wraparound behavior for directional workspace animations.";
      };

      bezier = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Custom Hyprland animation bezier definitions.";
      };

      rules = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Additional raw Hyprland animation rules.";
      };

      workspace = {
        enabled = mkOption {
          type = types.nullOr types.bool;
          default = null;
          description = "Workspace animation state; null leaves Hyprland's default rule in place.";
        };

        speed = mkOption {
          type = types.int;
          default = 8;
          description = "Workspace animation duration in deciseconds.";
        };

        curve = mkOption {
          type = types.str;
          default = "default";
          description = "Workspace animation bezier curve name.";
        };

        style = mkOption {
          type = types.nullOr (
            types.enum [
              "slide"
              "slidevert"
              "fade"
              "slidefade"
              "slidefadevert"
            ]
          );
          default = null;
          description = "Workspace animation style; null uses Hyprland's default style.";
        };
      };
    };

    lidSwitch = {
      enable = lib.mkEnableOption "external-monitor laptop lid handling";

      switchName = mkOption {
        type = types.str;
        default = "Lid Switch";
        description = "Hyprland switch device name for the laptop lid.";
      };

      internalMonitor = mkOption {
        type = types.str;
        default = "eDP-1";
        description = "Internal laptop monitor name.";
      };

      internalMonitorRule = mkOption {
        type = types.str;
        default = "eDP-1,preferred,auto,1";
        description = "Monitor rule used to re-enable the internal laptop panel.";
      };

      preferredExternalMonitor = mkOption {
        type = types.str;
        default = "";
        description = "External monitor to prefer when the lid closes; empty uses the first active external output.";
      };
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "extra configuration for Hyprland";
    };

    # TODO: move this higher up!
    theme = {
      activeBorderColor = lib.mkOption {
        type = lib.types.str;
        default = "ff69b4";
      };

      inactiveBorderColor = lib.mkOption {
        type = lib.types.str;
        default = "dddddd";
      };
    };
  };

  imports = [
    ./cursor.nix
    ./greetd.nix
    ./hypridle.nix
    ./hyprpaper.nix
  ];

  config = lib.mkIf (config.x.home.desktop.backend == "hyprland") {
    wayland.windowManager.hyprland = {
      enable = true;

      configType = "hyprlang";
      package = config.x.home.graphics.wrapPackage pkgs.hyprland;

      systemd = {
        enable = true;
        variables = [ "all" ];
      };

      xwayland.enable = cfg.xwayland.enable;

      settings = {
        input = {
          kb_layout = "us";
          repeat_rate = 50;
          repeat_delay = 200;
        }
        // lib.optionalAttrs (cfg.keyboardOptions != [ ]) {
          kb_options = lib.concatStringsSep "," cfg.keyboardOptions;
        };

        device = lib.mapAttrsToList (name: keyboardOptions: {
          inherit name;
          kb_options = lib.concatStringsSep "," keyboardOptions;
        }) cfg.keyboardOptionsByDevice;

        general = {
          "col.active_border" = "rgb(${cfg.theme.activeBorderColor})";
          "col.inactive_border" = "rgb(${cfg.theme.inactiveBorderColor})";
        };

        exec-once = [
          "hyprpaper"
          "${lib.getExe applyWallpaper}"
          # ashell is started via its systemd user service (programs.ashell.
          # systemd.enable) so it auto-restarts after suspend/resume.
        ]
        ++ lib.optionals cfg.lidSwitch.enable [
          "${lib.getExe handleLidSwitch} reconcile"
        ];

        monitor = cfg.monitors;

        bind = [
          "SUPER,SPACE,exec,fuzzel" # launcher
          "SUPER,RETURN,exec,alacritty" # terminal
          "SUPER,Q,killactive" # app: quit
          "SUPER,W,exec,${lib.getExe pkgs.wtype} -M ctrl -k w -m ctrl" # window: close
          "SUPER,BACKSPACE,exec,${lib.getExe pkgs.wtype} -k ctrl+shift+left ctrl+x" # Delete to beginning of line
          "SUPER,DELETE,exec,${lib.getExe pkgs.wtype} -k ctrl+shift+left ctrl+x" # Delete to beginning of line
          "SUPER,A,exec,${lib.getExe pkgs.wtype} -M ctrl -k a -m ctrl" # select all
          "SUPER,X,exec,${lib.getExe pkgs.wtype} -M ctrl -k x -m ctrl" # cut
          "SUPER,Z,exec,${lib.getExe pkgs.wtype} -M ctrl -k z -m ctrl" # Undo
          "SUPER SHIFT,E,exit," # exit to tty
          "ALT,F,fullscreen,1" # fullscreen
          "SUPER SHIFT,DELETE,exec,hyprctl dispatch dpms off" # sleep
          "ALT,L,cyclenext" # go to next
          "ALT,H,cyclenext,prev" # go to prev
          "ALT SHIFT,N,swapnext" # swap to next
          "ALT SHIFT,P,swapnext,prev" # swap to prev
        ]
        ++ map (n: "ALT,${n},workspace,${n}") (nStrRange 1 9) # goto workspace N
        ++ map (n: "ALT SHIFT,${n},movetoworkspacesilent,${n}") (nStrRange 1 9); # move to workspace N

        bindl =
          lib.optionals cfg.lidSwitch.enable [
            ",switch:on:${cfg.lidSwitch.switchName},exec,${lib.getExe handleLidSwitch} closed"
            ",switch:off:${cfg.lidSwitch.switchName},exec,${lib.getExe handleLidSwitch} open"
          ]
          ++ [
            ",XF86AudioMute,exec,ashell msg volume-toggle-mute"
          ];

        bindle = [
          ",XF86AudioRaiseVolume,exec,ashell msg volume-up"
          ",XF86AudioLowerVolume,exec,ashell msg volume-down"
        ];

        # bindm = [
        #   "SUPER,C,pass"
        #   "SUPER,X,pass"
        #   "SUPER,V,pass"
        #   "SUPER,P,pass"
        # ];

        workspace = cfg.workspaces;

        decoration = {
          rounding = cfg.decoration.rounding;
          active_opacity = cfg.decoration.activeOpacity;
          inactive_opacity = cfg.decoration.inactiveOpacity;
          fullscreen_opacity = cfg.decoration.fullscreenOpacity;

          blur = {
            enabled = cfg.decoration.blur.enable;
            passes = cfg.decoration.blur.passes;
            size = cfg.decoration.blur.size;
            new_optimizations = cfg.decoration.blur.newOptimizations;
            xray = cfg.decoration.blur.xray;
          };
        };

        render = {
          new_render_scheduling = cfg.render.newRenderScheduling;
        };

        animations = {
          enabled = cfg.animations.enable;
          workspace_wraparound = cfg.animations.workspaceWraparound;
        };

        env = [
          "GDK_SCALE,${toString (cfg.scale)}"
          "XCURSOR_SIZE,${toString (cfg.scale * 24)}"
        ];

        misc = {
          # disable stupid default background
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          force_default_wallpaper = 0;
        };
      }
      // lib.optionalAttrs (cfg.animations.bezier != [ ]) {
        bezier = cfg.animations.bezier;
      }
      // lib.optionalAttrs (animationRules != [ ]) {
        animation = animationRules;
      };

      extraConfig = cfg.extraConfig;
    };
  };
}
