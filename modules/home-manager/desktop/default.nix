{ self, ... }:
let
  inherit (self.lib) mkEnabledOption mkOption types;
in {
  options.x.home.desktop = {
    enable = mkEnabledOption "enable desktop";

    backend = mkOption {
      type = types.enum [ "hyprland" "aerospace" "none" ];
      default = "none";
    };
  };

  imports = [
    ./aerospace.nix
    ./hyprland
  ];
}
