args@{ config, lib, self, pkgs, ... }:
let
  cfg = config.x.home.browser.firefox;
in {
  options.x.home.browser.firefox = {
    enable = lib.mkEnableOption "Enable Firefox home-manager module.";
  };

  config = lib.mkIf cfg.enable {
      programs.firefox = {
        enable = true;

        policies = import ./firefox_policies.nix;
        profiles = import ./firefox_profile.nix args;
     };
  };
}
