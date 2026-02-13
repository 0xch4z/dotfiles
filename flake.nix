{
  description = "0xch4z's systems configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";

    nixpkgs-darwin = { url = "github:nixos/nixpkgs/nixpkgs-25.11-darwin"; };

    # community
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops = { url = "github:Mic92/sops-nix"; };

    nur = { url = "github:nix-community/nur"; };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    nix-darwin-browsers = {
      url = "github:wuz/nix-darwin-browsers?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin-firefox = {
      url = "github:bandithedoge/nixpkgs-firefox-darwin?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # necessary for linking per-user apps to /Applications directory on MacOS
    mac-app-util.url = "github:hraban/mac-app-util";

    ashell.url =
      "github:MalpenZibo/ashell/220c7e06da3c6dc2cba7d256566771da3a81ece6";

    # custom
    nixpkgs-kns-fork.url = "github:0xch4z/nixpkgs/kns-unix-support";

    gauntlet.url = "github:project-gauntlet/gauntlet/v17";
    gauntlet.inputs.nixpkgs.follows = "nixpkgs";

    hyprcursor-phinger.url = "github:jappie3/hyprcursor-phinger";
  };

  outputs = { self, ... }: {
    constants = import ./constants.nix self;
    overlays = import ./overlays.nix self;
    lib = import ./lib.nix self;
    users = import ./home self;
    machines = import ./machines self;
    modules = import ./modules;
    roles = import ./roles;

    nixosConfigurations = self.lib.buildMachinesForOS "nixos";
    darwinConfigurations = self.lib.buildMachinesForOS "darwin";
    homeConfigurations = self.lib.buildHomeConfigurations { };
  };
}
