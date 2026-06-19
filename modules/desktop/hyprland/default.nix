{ den, ... }:
{
  den.aspects.hyprland = {
    includes = [
      den.aspects.hypr-cursor
      den.aspects.hypr-greetd
      den.aspects.hypr-idle
      den.aspects.hypr-paper
    ];

    homeManager =
      {
        config,
        pkgs,
        lib,
        ...
      }:
      let
        cfg = config.x.home.desktop.hyprland;

        inherit (lib)
          lists
          types
          mkOption
          ;
        inherit (lists) map range;

        nStrRange = lower: upper: map (n: toString n) (range lower upper);

        g8 = "desc:Samsung Electric Company Odyssey G80SD H1AK500000";

        wallpaper = "${config.home.homeDirectory}/.dotfiles/assets/philly-dark.jpg";

        applyWallpaper = pkgs.writeShellApplication {
          name = "hyprpaper-apply-wallpaper";
          runtimeInputs = [
            pkgs.hyprland
            pkgs.coreutils
            pkgs.gnugrep
          ];
          text = ''
            for _ in $(seq 1 60); do
              hyprctl hyprpaper wallpaper "${g8},${wallpaper}" 2>/dev/null || true
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
          xwayland.enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "enable Hyprland xwayland support.";
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

        config = {
          wayland.windowManager.hyprland = {
            enable = true;

            configType = "hyprlang";

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
              };

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

              # was using IDs (e.g. HDMI-A-1) but found this to be non-determistic.
              # on boot, if amdgpu (igpu) kernel module loads before nvidia, it gets
              # addressed first (-A-1/-A-2). using desc to filter for the correct
              # monitor instead of disabling igpu on boot in case its needed in the
              # future.
              monitor = [
                "${g8},3840x2160@240,0x0,1" # Samsung Odyssey G8 32"
                "DP-4,3840x2160@144,0x-2160,1" # Samsung Odyssey G5 27"
              ];

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

              workspace = [
                "1,monitor:${g8},default:true"
              ]
              ++ map (n: "${n},monitor:${g8}") (nStrRange 2 3)
              ++ [ "4,monitor:DP-4,default:true" ]
              ++ map (n: "${n},monitor:DP-4") (nStrRange 5 9);

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
                disable_splash_rendering = true;
                force_default_wallpaper = 0;
              };
            };
          };
        };
      };
  };
}
