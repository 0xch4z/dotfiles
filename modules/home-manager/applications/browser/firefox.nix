args@{ config, self, pkgs, ... }:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  inherit (self.lib) types mkIf mkDesktopEnabledOption mkOption;

  cfg = config.x.home.applications.browser.firefox;
in {
  options.x.home.applications.browser.firefox = {
    enable = mkDesktopEnabledOption config "Enable Firefox home-manager module.";

    devPixelsPerPx = mkOption {
      type = types.string;
      default = if isDarwin then "1.5" else "1.0"; # scaling
    };
  };

  config = mkIf cfg.enable {
      programs.firefox = {
        enable = true;

        package = if isDarwin then pkgs.firefox-bin else pkgs.firefox;

        policies = import ./firefox_policies.nix;
        profiles = import ./firefox_profile.nix args;
     };
  };
}
