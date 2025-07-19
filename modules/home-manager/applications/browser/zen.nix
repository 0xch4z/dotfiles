args@{ config, self, pkgs, ... }:
let
  inherit (self.lib) isDarwin mkIf mkEnableOption mkForce;
  inherit (self.inputs) zen-browser;

  cfg = config.x.home.applications.browser.zen;
in {
  imports = [ zen-browser.homeModules.beta ];

  options.x.home.applications.browser.zen = {
    enable = mkEnableOption "Enable Zen home-manager module.";
  };

  config = mkIf cfg.enable {
      programs.zen-browser = {
        enable = true;

        # can't install via home-manager on darwin yet :(
        package = mkIf pkgs.stdenv.hostPlatform.isDarwin (mkForce null);

        policies = import ./firefox_policies.nix;
        profiles = import ./firefox_profile.nix args;
     };
  };
}
