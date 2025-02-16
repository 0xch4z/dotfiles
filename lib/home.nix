{ inputs, nixpkgs }:

rec {
  overlay-kns-fork = final: prev: {
    kns-fork = inputs.nixpkgs-kns-fork.legacyPackages.${prev.system};
  };

  # set nixpkgs config and overlays.
  nixpkgsConfig = {
    config.allowUnfree = true;
    overlays = with inputs; [
      overlay-kns-fork
      nur.overlays.default
      neovim-nightly-overlay.overlays.default
    ];
  };

  mkHome = {
    name,   # the system name
    system, # the system arch
    user,   # the user name
  }:
    let
      darwin = nixpkgs.lib.strings.hasInfix "darwin" system;

      pkgs = import (if darwin then inputs.nixpkgs-darwin else inputs.nixpkgs) {
        inherit system;
        config.allowUnfree = true;
      };

      lib = pkgs.lib;

      userHost = "${user}@${name}";

      homeModule = ../home/${userHost}/default.nix;

      extraSpecialArgs = {
        inherit inputs nixpkgs name system user;
      };

    in inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs extraSpecialArgs;
      modules = [
        { nixpkgs = nixpkgsConfig; }
        {
          home.username = "${user}";
        }
        ../home/${userHost}/default.nix
      ];
    };
}

