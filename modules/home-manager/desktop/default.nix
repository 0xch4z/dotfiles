{
  self,
  config,
  pkgs,
  ...
}:
let
  inherit (self.lib)
    mkEnabledOption
    mkIf
    mkOption
    types
    ;
in
{
  options.x.home.desktop = {
    enable = mkEnabledOption "enable desktop";

    backend = mkOption {
      type = types.enum [
        "hyprland"
        "niri"
        "aerospace"
        "rift"
        "none"
      ];
      default = "none";
    };
  };

  imports = [
    ./aerospace.nix
    ./niri.nix
    ./rift.nix
    ./hyprland
    ./wayland
  ];

  config = mkIf config.x.home.desktop.enable {
    home.packages = with pkgs; [
      xdg-utils
    ];
  };
}
