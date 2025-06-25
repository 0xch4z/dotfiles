{ config, self, ... }:
let
  inherit (self.lib) mkEnabledOption mkIf mkOption types;

  cfg = config.x.home.desktop;
in {
  options.x.home.desktop = {
    enable = mkEnabledOption "enable desktop";

    backend = mkOption {
      type = types.enum [ "hyprland" "x11" "none" ];
      default = "none";
    };
  };

  imports = [
    ./hyprland
  ];
}
