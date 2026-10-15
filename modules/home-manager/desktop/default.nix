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
        "aerospace"
        "rift"
        "none"
      ];
      default = "none";
    };
  };

  imports = [
    ./aerospace.nix
    ./rift.nix
    ./hyprland
  ];

  config = mkIf config.x.home.desktop.enable {
    home.packages = with pkgs; [
      xdg-utils
    ];
  };
}
