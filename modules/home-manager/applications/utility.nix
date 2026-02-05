{ config, self, pkgs, ... }:
let
  inherit (self.lib) mkIf mkEnableOption;

  cfg = config.x.home.applications.utility;
in {
  options.x.home.applications.utility = {
    caffeine.enable = mkEnableOption "Enable caffeine app";
  };

  options.x.home.applications.utility = {
    gitify.enable = mkEnableOption "Enable gitify app";
  };

  config = {
    home.packages = with pkgs;
      [
        #(mkIf cfg.caffeine.enable x.caffeine-bin)
        gitify
      ];
  };
}
