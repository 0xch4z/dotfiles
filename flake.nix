{
  description = "0xch4z's systems configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-kns-fork.url = "github:0xch4z/nixpkgs/kns-unix-support";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
    nur.url = "github:nix-community/nur";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/neovim-nightly-overlay";
    };
  };

  outputs = inputs @ { darwin, home-manager, nur, nixpkgs, nixpkgs-kns-fork, neovim-nightly-overlay, ... }:
    let
      overlay-kns-fork = final: prev: {
        kns-fork = nixpkgs-kns-fork.legacyPackages.${prev.system};
      };
      nixpkgsConfig = {
        config.allowUnfree = true;
        overlays = [
          overlay-kns-fork
          neovim-nightly-overlay.overlay
          nur.overlay
        ];
      };
    in {
      darwinConfigurations.USMK9RK6N3FN2 = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          {nixpkgs = nixpkgsConfig;}
          ./machines/USMK9RK6N3FN2
          home-manager.darwinModules.home-manager
        ];
        specialArgs = { inherit inputs nixpkgs nixpkgsConfig; };
      };
    };
}
