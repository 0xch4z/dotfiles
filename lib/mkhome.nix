{ inputs, nixpkgs }:

rec {
  overlayKnsFork = final: prev: {
    knsFork = inputs.nixpkgs-kns-fork.legacyPackages.${prev.system};
  };

  # set nixpkgs config and overlays.
  nixpkgsConfig = {
    config.allowUnfree = true;
    overlays = with inputs; [
      overlayKnsFork
      nur.overlays.default
      neovim-nightly-overlay.overlay
    ];
  };

  _baseHomeModules = { user, meta }:
    [
      { nixpkgs = nixpkgsConfig; }
      meta.homeModule
    ] ++ meta.lib.optionals(user != "") [
      meta.homeModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.sharedModules = if meta.darwin then [
          # link applications to "/Applications" dir for macos
          inputs.mac-app-util.homeManagerModules.default
        ] else [];
+        home-manager.users.${user}.imports = [({config, lib, ...}: import meta.homeModule {
          user = user;
          inputs = inputs;
          config = config;
          lib = meta.lib;
          pkgs = meta.pkgs;
          darwin = meta.darwin;
       })];
      }
    ];

  baseHomeModules = {
    name,   # the system name
    system, # the system arch
    user,   # the user name
  }:
    let
      meta = import ./meta.nix {
        inherit inputs nixpkgs name system user;
      };
    in _baseHomeModules {
      inherit name system user meta;
    };

  mkHome = {
    name,   # the system name
    system, # the system arch
    user,   # the user name
  }:
    let
      meta = import ./meta.nix {
        inherit inputs nixpkgs name system user;
      };
    in meta.homeFactory rec {
      pkgs = meta.pkgs;
      modules = _baseHomeModules { inherit user meta; };
      extraSpecialArgs = {
        inherit inputs nixpkgs name system user;
      };
    };
}

