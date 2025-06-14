args@{ config, lib, self, pkgs, ... }:
let
  cfg = config.x.home.browser.zen;
in {
  imports = [ self.inputs.zen-browser.homeModules.beta ];

  options.x.home.browser.zen = {
    enable = lib.mkEnableOption "Enable Zen home-manager module.";
  };

  config = lib.mkIf cfg.enable {
      programs.zen-browser = {
        enable = true;

        policies = import ./firefox_policies.nix;
        profiles = import ./firefox_profile.nix args;
     };
  };
}
