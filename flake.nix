{
  description = "0xch4z's systems configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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

  outputs = { darwin, home-manager, nur, nixpkgs, neovim-nightly-overlay, ... }:
    let
      homeManagerConfFor = config:
        { ... }: {
          nixpkgs.overlays = [
            neovim-nightly-overlay.overlay
            nur.overlay
          ];
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
