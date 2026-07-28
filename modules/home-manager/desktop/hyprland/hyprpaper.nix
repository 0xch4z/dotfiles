{
  config,
  lib,
  pkgs,
  homeDir,
  ...
}:
let
  inherit (lib) mkIf mkOption types;

  wallpaper = "${homeDir}/.dotfiles/assets/philly-dark.jpg";

  hyprlandCfg = config.x.home.desktop.hyprland;
  cfg = hyprlandCfg.hyprpaper;
  hyprlandEnabled = config.x.home.desktop.backend == "hyprland";
in
{
  options.x.home.desktop.hyprland.hyprpaper = {
    enable = mkOption {
      type = types.bool;
      default = hyprlandEnabled;
      defaultText = lib.literalExpression "config.desktop.hyprland.enable";
      description = "enable hyprpaper wallpaper daemon";
    };
  };

  config = mkIf (hyprlandEnabled && cfg.enable) {
    services.hyprpaper = {
      enable = true;
      package = config.x.home.graphics.wrapPackage pkgs.hyprpaper;

      settings = {
        ipc = "on";
        splash = false;

        preload = [ wallpaper ];
        wallpaper = [ "${hyprlandCfg.wallpaperMonitor},${wallpaper}" ];
      };
    };
  };
}
