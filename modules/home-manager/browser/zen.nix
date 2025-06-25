args@{ config, lib, self, pkgs, ... }:
let
  inherit (self.lib) mkIf mkDesktopEnabledOption;

  cfg = config.x.home.browser.zen;
in {
  imports = [ self.inputs.zen-browser.homeModules.beta ];

  options.x.home.browser.zen = {
    enable = mkDesktopEnabledOption config "Enable Zen home-manager module.";
  };

  config = mkIf cfg.enable {
      programs.zen-browser = {
        enable = true;

        policies = import ./firefox_policies.nix;
        profiles = import ./firefox_profile.nix args;
     };
  };
}
