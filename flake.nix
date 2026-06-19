{
  description = "0xch4z's systems configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";

    nixpkgs-darwin = {
      url = "github:nixos/nixpkgs/nixpkgs-26.05-darwin";
    };

    # community
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops = {
      url = "github:Mic92/sops-nix";
    };

    nur = {
      url = "github:nix-community/nur";
    };

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

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # necessary for linking per-user apps to /Applications directory on MacOS
    mac-app-util.url = "github:hraban/mac-app-util";

    ashell.url = "github:0xch4z/ashell/db9f96236832c73bbe77a07245709ec85178a657";

    # custom
    nixpkgs-kns-fork.url = "github:0xch4z/nixpkgs/kns-unix-support";

    gauntlet.url = "github:project-gauntlet/gauntlet/v17";
    gauntlet.inputs.nixpkgs.follows = "nixpkgs";

    hyprcursor-phinger.url = "github:jappie3/hyprcursor-phinger";

    linodectl.url = "github:0xch4z/linodectl";
    linodectl.inputs.nixpkgs.follows = "nixpkgs";

    den.url = "github:denful/den";
    import-tree.url = "github:vic/import-tree";
    nixos-facter-modules.url = "github:nix-community/nixos-facter-modules";
  };

  outputs =
    { self, ... }:
    let
      denFlake =
        (self.inputs.nixpkgs.lib.evalModules {
          modules = [
            (self.inputs.import-tree ./modules)
            (self.inputs.import-tree ./hosts)
            (self.inputs.import-tree ./home)
          ];
          specialArgs = {
            inherit self;
            inputs = self.inputs // {
              inherit self;
            };
          };
        }).config.flake;
    in
    {
      lib = self.inputs.nixpkgs.lib.extend (
        _: prev: {
          mkEnabledOption =
            description:
            prev.mkOption {
              inherit description;
              type = prev.types.bool;
              default = true;
            };
          mkDesktopEnabledOption =
            config: description:
            prev.mkOption {
              inherit description;
              type = prev.types.bool;
              default = config.x.home.desktop.enable;
            };
          templateFile =
            { file, data }:
            builtins.replaceStrings (map (name: "{{ " + name + " }}") (builtins.attrNames data)) (
              builtins.attrValues data
            ) (builtins.readFile file);
        }
      );

      overlays = import ./overlays.nix {
        inherit (self) inputs;
        lib = self.inputs.nixpkgs.lib;
      };

      nixosConfigurations = denFlake.nixosConfigurations;
    };
}
