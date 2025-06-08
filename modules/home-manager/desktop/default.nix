{ self, ... }:
let
  inherit (self.lib) mkEnabledOption mkOption types;
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
