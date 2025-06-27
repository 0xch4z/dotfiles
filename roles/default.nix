{ config, lib, ... }:
let
  inherit (lib) mkIf mkOption types;

in {
  options.x.role = mkOption {
    type = types.enum ["workstation" "nix-workstation" "mac-workstation" "none"];
    default = "none";
  };

  imports = [
    ./mac-workstation.nix
    ./nix-workstation.nix
  ];
}
