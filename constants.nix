{ lib, ... }:
let
  inherit (builtins) attrValues;
  inherit (lib) lists recursiveUpdate;
  inherit (lists) flatten foldl';

  allCPUArchs = [
    "aarch64"
    "x86_64"
  ];

  allOSes = [
    "darwin"
    "linux"
  ];

  # platformStr builds a platform string (e.g. "x86_64-darwin").
  platformStr = os: arch: "${arch}-${os}";

  # platformStrs returns all platform strings for the given os.
  platformStrs = os: map (platformStr os) allCPUArchs;

  platforms = foldl' (acc: os: recursiveUpdate acc { "${os}" = (platformStrs os); }) { } allOSes;
in
rec {
  inherit allCPUArchs allOSes platforms;

  defaultUser = "char";

  defaultArch = "aarch64";

  nixCaches = {
    substituters = [
      "https://hyprland.cachix.org"
      "https://cache.numtide.com"
    ];
    trustedPublicKeys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    ];
  };

  defaultNixpkgsConfig = {
    allowUnfree = true;
    allowBroken = true;
    allowUnsupportedSystem = true;
    overlays = (import ./overlays.nix).all;
  };

  allPlatforms = flatten (attrValues platforms);
}
