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

    # TODO: hookup
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

        bindl = [
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
          rounding = 3;
          active_opacity = 1.0;
          inactive_opacity = 1.0;
          fullscreen_opacity = 1.0;

          blur = {
            enabled = true;
            passes = 3;
            size = 16;
          };
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
      };

      extraConfig = cfg.extraConfig;
    };
  };
}
