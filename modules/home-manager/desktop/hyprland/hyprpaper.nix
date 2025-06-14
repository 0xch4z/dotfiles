{ config, lib, homeDir, ... }:
let
  cfg = config.x.home.desktop.hyprland.hyprpaper;
  wallpaper = "${homeDir}/.dotfiles/assets/philly-dark.jpg";
in {
  options.x.home.desktop.hyprland.hyprpaper = {
    enable = lib.mkEnableOption "Enable hyprland module.";
  };

  config = lib.mkIf cfg.enable {
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
