{
  config,
  lib,
  homeDir,
  ...
}:
let
  inherit (lib) mkIf mkOption types;

  wallpaper = "${homeDir}/.dotfiles/assets/philly-dark.jpg";

  g8 = "desc:Samsung Electric Company Odyssey G80SD H1AK500000";

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

  config = mkIf (hyprlandEnabled && cfg.enable) {
    services.hyprpaper = {
      enable = true;
      settings = {
        ipc = "on";
        splash = false;

        preload = [ wallpaper ];
        wallpaper = [ "${g8},${wallpaper}" ];
      };
    };
  };
}
