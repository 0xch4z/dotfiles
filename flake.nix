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

  outputs = { darwin, home-manager, nur, nixpkgs, nixpkgs-kns-fork, neovim-nightly-overlay, ... }:
    let
      overlay-kns-fork = final: prev: {
        kns-fork = nixpkgs-kns-fork.legacyPackages.${prev.system};
      };
      homeManagerConfFor = config:
        { ... }: {
          nixpkgs.overlays = [
            overlay-kns-fork
            neovim-nightly-overlay.overlay
            nur.overlay
          ];
          nixpkgs.config.allowUnfree = true;
          imports = [ config ];
        };
      darwinSystem = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./hosts/work-mbp
          home-manager.darwinModules.home-manager
          {
            home-manager.users.ckenney =
              homeManagerConfFor ./hosts/work-mbp/home.nix;
          }
        ];
        specialArgs = { inherit nixpkgs; };
      };
    in {
      darwinConfigurations.USMK9RK6N3FN2 = darwinSystem;
    };
}
