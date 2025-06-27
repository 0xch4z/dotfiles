{ config, lib, pkgs, ... }:
let
  cfg = config.x.home.taskbar.waybar;
in {
  options.x.home.taskbar.waybar = {
    enable = lib.mkEnableOption "Enable zen home-manager module.";
  };

  config = lib.mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      package = pkgs.waybar;

      settings = [{
        height = 30;
        layer = "top";
        position = "top";

        modules-left = [
          "hyprland/workspaces"
          "cpu"
          "memory"
        ];

        modules-center = [
          "hyprland/window"
        ];

        modules-right = [
          # "custom/hyprbindings"
          # "custom/notification"
          "clock"
        ];

        "hyprland/workspaces" = {
          format = "{name}";
        };
        "cpu" = {
          interval = 5;
          format = " {usage:2}%";
          tooltip = true;
        };
        "memory" = {
          interval = 5;
          format = " {}%";
          tooltip = true;
        };

        "clock" = {
          format = " {:L%H:%M}";
          tooltip = true;
          tooltip-format = "<big>{:%A, %d.%B %Y }</big>\n<tt><small>{calendar}</small></tt>";
        };
      }];
    };
  };
}
