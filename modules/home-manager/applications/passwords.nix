args@{
  config,
  self,
  pkgs,
  ...
}:
let
  inherit (self.lib) mkIf mkDesktopEnabledOption;

  cfg = config.x.home.applications.passwords;
in
{
  options.x.home.applications.passwords = {
    _1pass.enable = mkDesktopEnabledOption config "Enable 1Pass application";
    bitwarden.enable = mkDesktopEnabledOption config "Enable Bitwaden application";
  };

  config = {
    home.packages = [
      (mkIf cfg._1pass.enable pkgs._1password-gui)
      # built on electron 39.8.10 (insecure)
      #(mkIf cfg.bitwarden.enable pkgs.unstable.bitwarden-desktop)
    ];
  };
}
