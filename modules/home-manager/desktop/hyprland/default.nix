{ self, config, pkgs, lib, ... }:
let
  cfg = config.x.home.desktop.hyprland;

  inherit (lib.lists) map range;

  nStrRange = lower: upper: map(n: toString n)
    (range lower upper);
in {
  options.x.home.desktop.hyprland = {
    enable = lib.mkEnableOption "Enable hyprland module.";

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
    ./hyprpaper.nix
    ./cursor.nix
  ];

  config = lib.mkIf cfg.enable {
    # start hyprland on boot

    # https://wiki.hyprland.org/Hypr-Ecosystem/hypridle
    services.hypridle = {
      enable = true;

      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";      # enter hyprlock
          before_sleep_cmd = "loginctl lock-session";   # lock before suspend
          after_sleep_cmd = "hyprctl dispatch dpms on"; # turn screen on after key press
        };

        listener = [
          {
            timeout = 60;                           # 1min
            on-timeout = "brightnessctl -s set 10"; # set monitor backlight to min
            on-resume = "brightnessctl -r";         # restore monitor brightness
          }
          {
            timeout = 300;                        # 5min
            on-timeout = "loginctl lock-session"; # log out
          }
          {
            timeout = 330;                            # 5.5min
            on-timeout = "hyprctl dispatch dpms off"; # 5.5min
            on-resume = "hyprctl dispatch dpms on";   # screen off
          }
          {
            timeout = 1800;                   # 30min
            on-timeout = "systemctl suspend"; # suspend
          }
        ];
      };
    };

    wayland.windowManager.hyprland = {
      enable = true;
      systemd = {
        enable = true;
        variables = ["all"];
      };

      xwayland.enable = true;

      settings = {
        general = {
          "col.active_border" = "rgb(${cfg.theme.activeBorderColor})";
          "col.inactive_border" = "rgb(${cfg.theme.inactiveBorderColor})";
        };

        exec-once = [
          "hyprpaper"
          "mako"
          "waybar"
        ];

        monitor = [
          "HDMI-A-2,3840x2160@144,0x0,1" # Samsung Odyssey G8 32"
          "DP-4,3840x2160@144,0x-2160,1" # Samsung Odyssey G5 27"
        ];

        bind = [
          "SUPER,SPACE,exec,wofi --show drun"                    # launcher
          "SUPER,RETURN,exec,alacritty"                          # terminal
          "SUPER,Q,killactive"                                   # app: quit
          "SUPER,W,killactive"                                   # window: close
          "SUPER,BACKSPACE,exec,wtype -k ctrl+shift+left ctrl+x" # Delete to beginning of line
          "SUPER,DELETE,exec,wtype -k ctrl+shift+left ctrl+x"    # Delete to beginning of line
          "SUPER,C,exec,wl-copy"                                 # copy
          "SUPER,V,exec,wl-paste | wl-copy"                      # paste
          "SUPER,V,exec,wl-paste | wl-copy && wl-pase --clear"   # cut
          "SUPER SHIFT,E,exit,"                                  # exit to tty
          "ALT,F,fullscreen,1"                                   # fullscreen
          "SUPER SHIFT,DELETE,exec,hyprctl dispatch dpms off"    # sleep
          "ALT,N,cyclenext"                                      # go to next
          "ALT,P,cyclenext,prev"                                 # go to prev
          "ALT SHIFT,N,swapnext"                                 # swap to next
          "ALT SHIFT,P,swapnext,prev"                            # swap to prev
        ] ++ map(n: "ALT,${n},workspace,${n}") (nStrRange 0 9)   # goto workspace N
          ++ map(n: "ALT SHIFT,${n},movetoworkspacesilent,${n}") (nStrRange 0 9); # move to workspace N

        workspace = map(n: "${n},monitor:HDMI-A-2") (nStrRange 0 2)
          ++ map(n: "${n},monitor:DP-4") (nStrRange 3 9);

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

        misc = {
          # disable stupid default background
          disable_hyprland_logo = true;
          force_default_wallpaper = 0;
        };
      };
    };
  };
}
