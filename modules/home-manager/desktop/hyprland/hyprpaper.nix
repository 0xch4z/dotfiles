{ config, lib, homeDir, ... }:
let
  inherit (lib) mkIf mkOption types;

  wallpaper = "${homeDir}/.dotfiles/assets/philly-dark.jpg";

  cfg = config.x.home.desktop.hyprland.hyprpaper;
  hyprlandEnabled = config.x.home.desktop.backend == "hyprland";
in
{
  options.x.home.desktop.hyprland.hyprpaper = {
    enable = mkOption {
      type = types.bool;
      default = builtins.trace "hyprlandEnabled: ${builtins.toString hyprlandEnabled}" hyprlandEnabled;
      defaultText = lib.literalExpression "config.desktop.hyprland.enable";
      description = "enable hyprpaper wallpaper daemon";
    };
  };

  config = mkIf cfg.enable {
    services.hyprpaper = {
      enable = true;
      settings = {
        ipc = "on";
        splash = false;
        splash_offset = 2.0;

        preload = [ wallpaper ];
        wallpaper = [ "HDMI-A-2, ${wallpaper}" ];
      };
    };
  };
}
