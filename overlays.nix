{ inputs, lib, ... }@args:
let
  isDirectory = name: type: type == "directory";
  #packages' = lib.filterAttrs isDirectory (builtins.readDir ./derivations/pkgs);
in
rec {
  all = lib.composeManyExtensions [
    unstable

    #packages
    kns-fork
    inputs.neovim-nightly-overlay.overlays.default
    inputs.nix-darwin-browsers.overlays.default
    inputs.nixpkgs-firefox-darwin.overlays.default

    # community
    inputs.nur.overlays.default
  ];

  kns-fork = final: prev: {
    kns-fork = inputs.nixpkgs-kns-fork.legacyPackages.${prev.system};
  };

  # packages = final: prev: lib.mapAttrs
  #   (name: _: lib.callPackageWith (final // args // { inherit prev; self = args; }) ./derivations/pkgs/${name} { })
  #   packages';

  unstable = final: _: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final) system overlays;
    };
  };
}
