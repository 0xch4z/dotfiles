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

  communityOverlays = [
    knsOverlay
    inputs.neovim-nightly-overlay.overlays.default
    inputs.nix-darwin-browsers.overlays.default
    #inputs.nix-darwin-firefox.overlays.default
    inputs.nur.overlays.default

    lua54posixOverlay
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
