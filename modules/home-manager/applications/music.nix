args@{ config, self, pkgs, ... }:
let
  inherit (self.lib) mkIf mkDesktopEnabledOption;

  cfg = config.x.home.applications.music;
in {
  options.x.home.applications.music = {
    spotify.enable = mkDesktopEnabledOption config "Enable Spotify home-manager module.";
  };

  config = {
    home.packages = with pkgs; [
      (mkIf cfg.spotify.enable spotify)
    ];
  };
}
