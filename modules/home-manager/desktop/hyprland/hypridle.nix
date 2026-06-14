{
  config,
  pkgs,
  lib,
  self,
  ...
}:
let
  inherit (lib)
    literalExpression
    mkIf
    mkOption
    types
    ;

  suspendTimeout = 3600;
  cfg = config.x.home.desktop.hyprland.hypridle;
  hyprlandEnabled = config.x.home.desktop.backend == "hyprland";

  suspendGuard = pkgs.writeShellApplication {
    name = "hypridle-suspend-guard";
    runtimeInputs = with pkgs; [
      coreutils
      systemd
    ];
    text = builtins.readFile ./hypridle-suspend-guard.sh;
  };

  idleCtl = pkgs.writeShellApplication {
    name = "idle-ctl";
    runtimeInputs = with pkgs; [ coreutils ];
    text = self.lib.templateFile {
      file = ./idle-ctl.sh;
      data = {
        IDLE_SECONDS = toString suspendTimeout;
      };
    };
  };
in
{
  options.x.home.desktop.hyprland.hypridle = {
    enable = mkOption {
      type = types.bool;
      default = hyprlandEnabled;
      defaultText = literalExpression "x.desktop.backend";
      description = "enable hypridle home-manager module";
    };
  };

  config = lib.mkIf (hyprlandEnabled && cfg.enable) {
    home.packages = [ idleCtl ];

    # See: https://wiki.hyprland.org/Hypr-Ecosystem/hypridle
    services.hypridle = {
      enable = true;

      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock"; # enter hyprlock
          before_sleep_cmd = "loginctl lock-session"; # lock before suspend
          after_sleep_cmd = "hyprctl dispatch dpms on"; # turn screen on after key press
        };

        listener = [
          {
            timeout = 60; # 1min
            on-timeout = "brightnessctl -s set 10"; # set monitor backlight to min
            on-resume = "brightnessctl -r"; # restore monitor brightness
          }
          {
            timeout = 300; # 5min
            on-timeout = "loginctl lock-session"; # log out
          }
          {
            timeout = 330; # 5.5min
            on-timeout = "hyprctl dispatch dpms off"; # 5.5min
            on-resume = "hyprctl dispatch dpms on"; # screen off
          }
          {
            timeout = 3600; # 60min
            on-timeout = "${suspendGuard}/bin/hypridle-suspend-guard"; # guarded by idle-ctl
          }
        ];
      };
    };
  };
}
