{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.x.home.applications.launcher;
in
{
  options.x.home.applications.launcher.enable = lib.mkEnableOption "Vicinae application launcher";

  config = lib.mkIf (cfg.enable && pkgs.stdenv.hostPlatform.isLinux) {
    programs.vicinae = {
      enable = true;
      package = config.x.home.graphics.wrapPackage pkgs.vicinae;
      useLayerShell = true;
      systemd = {
        enable = true;
        autoStart = true;
      };
    };
  };
}
