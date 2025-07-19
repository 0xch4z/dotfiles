args@{ config, self, pkgs, ... }:
let
  inherit (self.lib) mkIf mkDesktopEnabledOption;

  cfg = config.x.home.applications.passwords;
in {
  options.x.home.applications.passwords = {
    _1pass.enable = mkDesktopEnabledOption config "Enable 1Pass application";
    bitwarden.enable = mkDesktopEnabledOption config "Enable Bitwaden application";
  };

  config = {
    home.packages = with pkgs; [
      (mkIf cfg._1pass.enable _1password-gui)
      (mkIf cfg.bitwarden.enable bitwarden)
    ];
  };
}
