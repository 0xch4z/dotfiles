{
  description = "0xch4z's systems configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-25.05-darwin";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";

    # community
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wsl = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/NixOS-WSL";
    };

    nur = {
      url = "github:nix-community/nur";
    };

    neovim-nightly-overlay = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/neovim-nightly-overlay";
    };

    # necessary for linking per-user apps to /Applications directory on MacOS
    mac-app-util.url = "github:hraban/mac-app-util";

    # custom
    nixpkgs-kns-fork.url = "github:0xch4z/nixpkgs/kns-unix-support";

    gauntlet.url = "github:project-gauntlet/gauntlet/v17";
    gauntlet.inputs.nixpkgs.follows = "nixpkgs";
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
