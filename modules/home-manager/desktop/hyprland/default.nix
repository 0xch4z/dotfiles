{ self, config, pkgs, lib, ... }:
let
  cfg = config.x.home.desktop.hyprland;

  inherit (self.lib) lists types mkEnabledOption mkEnableOption mkOption;
  inherit (lists) map range;

  nStrRange = lower: upper: map(n: toString n)
    (range lower upper);
in {
  options.x.home.desktop.hyprland = {
    xwayland.enable = mkEnabledOption "enable Hyprland xwayland support.";

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
      systemd = {
        enable = true;
        variables = ["all"];
      };

      xwayland.enable = cfg.xwayland.enable;

      settings = {
        input = {
          kb_layout = "us";
          repeat_rate = 50;
          repeat_delay = 200;
        };

        general = {
          "col.active_border" = "rgb(${cfg.theme.activeBorderColor})";
          "col.inactive_border" = "rgb(${cfg.theme.inactiveBorderColor})";
        };

        exec-once = [
          "hyprpaper"
          "mako"
          "ashell"
        ];

        monitor = [
          "HDMI-A-1,3840x2160@144,0x0,1" # Samsung Odyssey G8 32"
          "DP-4,3840x2160@144,0x-2160,1" # Samsung Odyssey G5 27"
        ];

        bind = [
          "SUPER,SPACE,exec,fuzzel"                               # launcher
          "SUPER,RETURN,exec,alacritty"                          # terminal
          "SUPER,Q,killactive"                                   # app: quit
          "SUPER,W,exec,${lib.getExe pkgs.wtype} -M ctrl -k w -m ctrl"              # window: close
          "SUPER,BACKSPACE,exec,${lib.getExe pkgs.wtype} -k ctrl+shift+left ctrl+x" # Delete to beginning of line
          "SUPER,DELETE,exec,${lib.getExe pkgs.wtype} -k ctrl+shift+left ctrl+x"    # Delete to beginning of line
          "SUPER,A,exec,${lib.getExe pkgs.wtype} -M ctrl -k a -m ctrl"              # select all
          "SUPER,X,exec,${lib.getExe pkgs.wtype} -M ctrl -k x -m ctrl"              # cut
          "SUPER,Z,exec,${lib.getExe pkgs.wtype} -M ctrl -k z -m ctrl"              # Undo
          "SUPER SHIFT,E,exit,"                                  # exit to tty
          "ALT,F,fullscreen,1"                                   # fullscreen
          "SUPER SHIFT,DELETE,exec,hyprctl dispatch dpms off"    # sleep
          "ALT,L,cyclenext"                                      # go to next
          "ALT,H,cyclenext,prev"                                 # go to prev
          "ALT SHIFT,N,swapnext"                                 # swap to next
          "ALT SHIFT,P,swapnext,prev"                            # swap to prev
        ] ++ map(n: "ALT,${n},workspace,${n}") (nStrRange 0 9)   # goto workspace N
          ++ map(n: "ALT SHIFT,${n},movetoworkspacesilent,${n}") (nStrRange 0 9); # move to workspace N

        # volume keys
        bindl = [
          ",XF86AudioMute,exec,pamixer -t && ${pkgs.libnotify}/bin/notify-send -t 1500 -h string:x-canonical-private-synchronous:volume -h int:value:$(pamixer --get-volume) \"$(if [ \"$(pamixer --get-mute)\" = 'true' ]; then echo '🔇 Muted'; else echo \"🔊 Volume $(pamixer --get-volume)%\"; fi)\""
        ];

        bindle = [
          ",XF86AudioRaiseVolume,exec,pamixer -i 5 && ${pkgs.libnotify}/bin/notify-send -t 1500 -h string:x-canonical-private-synchronous:volume -h int:value:$(pamixer --get-volume) \"🔊 Volume $(pamixer --get-volume)%\""
          ",XF86AudioLowerVolume,exec,pamixer -d 5 && ${pkgs.libnotify}/bin/notify-send -t 1500 -h string:x-canonical-private-synchronous:volume -h int:value:$(pamixer --get-volume) \"🔉 Volume $(pamixer --get-volume)%\""
        ];

        # bindm = [
        #   "SUPER,C,pass"
        #   "SUPER,X,pass"
        #   "SUPER,V,pass"
        #   "SUPER,P,pass"
        # ];

        workspace = map(n: "${n},monitor:HDMI-A-1") (nStrRange 0 2)
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
