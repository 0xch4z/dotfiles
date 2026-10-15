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

  config = lib.mkIf (cfg.enable) {
    programs.vicinae = {
      enable = true;
      package = config.x.home.graphics.wrapPackage pkgs.unstable.vicinae;
      service = {
        enable = true;
        autoStart = true;
      };
    };
  };
}
