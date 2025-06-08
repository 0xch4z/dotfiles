{ self, ... }:
let
  inherit (self.lib) mkEnableOption;
in {
  options.x.home.tools.containers = {
    enable = mkEnableOption "enable container tools";
  };

  imports = [
    ./docker.nix
    ./colima.nix
    ./utility.nix
  ];
}
