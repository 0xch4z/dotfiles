{ config, lib, ... }:
let
  inherit (lib) mkIf mkOption types;

  cfg = config.x.role;
in {
  options.x.role = mkOption {
    type = types.enum ["workstation" "nix-workstation" "mac-workstation" "none"];
    default = "none";
  };

  imports = [
    #(mkIf (cfg != "none") "./${cfg}.nix")
    ./nix-workstation.nix
  ];
}
