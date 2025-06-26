args@{ config, lib, self, pkgs, ... }:
let
  inherit (self.lib) mkIf mkEnableOption;

  cfg = config.x.home.browser.zen;
in {
  imports = [ self.inputs.zen-browser.homeModules.beta ];

  options.x.home.browser.zen = {
    enable = mkEnableOption "Enable Zen home-manager module.";
  };

  config = mkIf cfg.enable {
      programs.zen-browser = {
        enable = true;

        policies = import ./firefox_policies.nix;
        profiles = import ./firefox_profile.nix args;
     };
  };
}
