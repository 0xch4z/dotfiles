{ lib, ... }:
let
  inherit (builtins) attrValues;
  inherit (lib) lists recursiveUpdate;
  inherit (lists) flatten foldl';

  allCPUArchs = [ "aarch64" "x86_64" ];

  allOSes = [ "darwin" "nixos" ];

  # platformStr builds a platform string (e.g. "x86_64-darwin").
  platformStr = os: arch: "${arch}-${os}";

  # platformStrs returns all platform strings for the given os.
  platformStrs = os: map (platformStr os) allCPUArchs;

  platforms = foldl' (acc: os: recursiveUpdate acc {"${os}" = (platformStrs os);}) {} allOSes;
in
rec {
  inherit allCPUArchs allOSes platforms;

  defaultUser = "char";

  defaultArch = "aarch64";

  defaultNixpkgsConfig = {
    allowUnfree = true;
    allowUnsupportedSystem = true;
    overlays = (import ./overlays.nix).all;
  };

  allPlatforms = flatten (map attrValues platforms);
}
