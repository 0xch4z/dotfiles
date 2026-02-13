self@{ inputs, lib, ... }:
let
  unstableOverlay = final: _: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final) system overlays config;
    };
  };

  knsOverlay = final: prev: {
    kns-fork = inputs.nixpkgs-kns-fork.legacyPackages.${prev.system};
  };

  lua54posixOverlay = final: prev: {
    lua54Packages = prev.lua54Packages // {
      luaposix = prev.lua54Packages.luaposix.overrideAttrs (old: {
        version = "36.3";
        knownRockspec = (prev.fetchurl {
          url = "mirror://luarocks/luaposix-36.3-1.rockspec";
          sha256 = "6/sAsOWrrXjdzPlAp/Z5FetQfzrkrf6TmOz3FZaBiks=";
        }).outPath;
        src = prev.fetchzip {
          url = "http://github.com/luaposix/luaposix/archive/v36.3.zip";
          sha256 = "RKDH1sB7r7xDqueByWwps5fBfl5GBL9L86FjzfStBUw=";
        };
      });
    };
  };

  # cuda_compat only has redistributables for aarch64-linux (Jetson).
  # On x86_64-linux it fails to build because $src is empty.
  # Stub it out on non-Jetson platforms.
  cudaCompatFixOverlay = final: prev:
    lib.optionalAttrs (prev.stdenv.hostPlatform.system != "aarch64-linux") {
      cudaPackages = prev.cudaPackages.overrideScope (cfinal: cprev: {
        cuda_compat = cprev.cuda_compat.overrideAttrs (old: {
          src = null;
          dontUnpack = true;
          dontPatch = true;
          dontConfigure = true;
          dontBuild = true;
          dontFixup = true;
          installPhase = "mkdir -p $out/lib";
        });
      });
    };

  communityOverlays = [
    knsOverlay
    inputs.neovim-nightly-overlay.overlays.default
    inputs.nix-darwin-browsers.overlays.default
    #inputs.nix-darwin-firefox.overlays.default
    inputs.nur.overlays.default

    lua54posixOverlay
    cudaCompatFixOverlay
  ];

  customDerivationsOverlay = final: prev: {
    x = import ./pkgs { pkgs = prev; };
  };

in lib.composeManyExtensions (
  communityOverlays ++ [
    unstableOverlay
    customDerivationsOverlay
  ]
)
