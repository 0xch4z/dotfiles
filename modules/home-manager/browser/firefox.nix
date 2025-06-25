args@{ config, lib, self, pkgs, ... }:
let
  inherit (self.lib) mkIf mkDesktopEnabledOption;

  cfg = config.x.home.browser.firefox;
in {
  options.x.home.browser.firefox = {
    enable = mkDesktopEnabledOption config "Enable Firefox home-manager module.";
  };

  config = mkIf cfg.enable {
      programs.firefox = {
        enable = true;

        policies = import ./firefox_policies.nix;
        profiles = import ./firefox_profile.nix args;
     };
  };
}
