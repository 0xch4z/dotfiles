# This function creates a system.
{ nixpkgs, inputs }:

name:
{
  system, # the system name
  user,   # the username
}:
let
  # determine if this is a darwin/macos system.
  darwin = nixpkgs.lib.strings.hasInfix "darwin" system;

  # get the factory for this system.
  systemFunc = if darwin then inputs.darwin.lib.darwinSystem else nixpkgs.lib.nixosSystem;

  # get the home-manager modules for this system
  home-manager = if darwin then inputs.home-manager.darwinModules else inputs.home-manager.nixosModules;

  # define pkgs
  darwin-pkgs = import inputs.nixpkgs-darwin {
    system = system;
    config.allowUnfree = true;
  };
  pkgs = if darwin then darwin-pkgs else import nixpkgs {
    system = system;
    config.allowUnfree = true;
  };
  lib = pkgs.lib;

  overlay-kns-fork = final: prev: {
    kns-fork = inputs.nixpkgs-kns-fork.legacyPackages.${prev.system};
  };
  nixpkgsConfig = {
    config.allowUnfree = true;
    overlays = with inputs; [
      overlay-kns-fork
      nur.overlays.default
      neovim-nightly-overlay.overlays.default
    ];
  };

  # assumes machine config in ../machines/ and home config in .../home/
  userHost = "${user}@${name}";
  machineModule = ../machines/${name}/default.nix;
  homeModule = ../home/${userHost}/default.nix;

in systemFunc rec {
  inherit system;

  # expose some extra arguments to parameterize modules
  specialArgs = {
    currentSystem = system;
    currentSystemName = name;
    inputs = inputs;
    user = user;
    nixpkgs = nixpkgs;
  };

  modules = [
    { nixpkgs = nixpkgsConfig; }
    machineModule
  ] ++ lib.optionals(user != "") [
    home-manager.home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.sharedModules = if darwin then [
        # link applications to "/Applications" dir for macos
        inputs.mac-app-util.homeManagerModules.default
      ] else [];
      home-manager.users.${user}.imports = [({config, lib, ...}: import homeModule {
        user = user;
        inputs = inputs;
        config = config;
        lib = lib;
        pkgs = pkgs;
        darwin = darwin;
      })];
    }
  ];
}
