{
  description = "0xch4z's systems configurations";

  inputs = {
    # TODO: pin back to unstable channel when https://github.com/LnL7/nix-darwin/issues/1317 is closed
    nixpkgs.url = "github:NixOS/nixpkgs?rev=d2faa1bbca1b1e4962ce7373c5b0879e5b12cef2";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-24.05-darwin";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";

    # community
    nur.url = "github:nix-community/nur";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
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

  outputs = { self, ... }: {
    constants = import ./constants.nix self;
    overlays = import ./overlays.nix self;
    lib = import ./lib.nix self;
    users = import ./home self;
    machines = import ./machines self;

    nixosConfigurations = self.lib.buildMachinesForOS "nixos";
    darwinConfigurations = self.lib.buildMachinesForOS "darwin";
    homeConfigurations = self.lib.buildHomeConfigurations {};
  };
}
