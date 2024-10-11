{
  description = "0xch4z's systems configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-24.05-darwin";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";

    # community
    nur.url = "github:nix-community/nur";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:lnl7/nix-darwin/48b50b3b137be5cfb9f4d006835ce7c3fe558ccc";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wsl = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/NixOS-WSL";
    };
    neovim-nightly-overlay = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/neovim-nightly-overlay";
    };
    # necessary for linking per-user apps to /Applications directory on MacOS
    mac-app-util.url = "github:hraban/mac-app-util";

    # custom
    nixpkgs-kns-fork.url = "github:0xch4z/nixpkgs/kns-unix-support";
  };

  outputs = inputs @ { darwin, wsl, home-manager, nur, nixpkgs, nixpkgs-kns-fork, neovim-nightly-overlay, ... }:
    let
      mkSystem = import ./lib/mksystem.nix {
        inherit nixpkgs inputs;
      };
    in {
      # machines
      nixosConfigurations.charbox2wsl = mkSystem "charbox2wsl" {
        system = "x86_64-linux";
        user   = "char";
      };
      darwinConfigurations.USMK9RK6N3FN2 = mkSystem "USMK9RK6N3FN2" {
        system = "aarch64-darwin";
        user   = "ckenney";
      };
      darwinConfigurations.Charlies-MacBook-Pro = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        user   = "char";
      };

      # homes
      homeConfigurations."ckenney@USMK9RK6N3FN2" = home-manager.lib.homeManagerConfiguration {
        inherit nixpkgs;
        modules = [
          "./home/ckenney@USMK9RK6N3FN2"
        ];
      };
    };
}
