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

  cfg = config.x.home.desktop.wallpaper;
  waylandEnabled = config.x.home.desktop.wayland.enable;
in
{
  options.x.home.desktop.wallpaper = {
    enable = mkOption {
      type = types.bool;
      default = waylandEnabled;
      defaultText = lib.literalExpression "config.x.home.desktop.wayland.enable";
      description = "enable hyprpaper wallpaper daemon";
    };

    monitor = mkOption {
      type = types.str;
      default = "";
      description = "Monitor selector the wallpaper is applied to.";
    };
  };

  config = mkIf (waylandEnabled && cfg.enable) {
    services.hyprpaper = {
      enable = true;
      package = pkgs.hyprpaper;

      settings = {
        ipc = "on";
        splash = false;

        preload = [ wallpaper ];
        wallpaper = [
          {
            monitor = cfg.monitor;
            path = wallpaper;
          }
        ];
      };
    };
  };
}
