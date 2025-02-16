{
  inputs,
  nixpkgs,
  # special args
  name,   # the system name
  user,   # the user name
  system, # the system arch
}:

rec {
  # determine if this is a darwin/macos system.
  darwin = nixpkgs.lib.strings.hasInfix "darwin" system;

  # get the home-manager module for this system.
  hm =
    if darwin then inputs.home-manager.darwinModules else inputs.home-manager.nixosModules;


  # get platform specific pkgs.
  darwin-pkgs = import inputs.nixpkgs-darwin {
    system = system;
    config.allowUnfree = true;
  };
  pkgs = if darwin then darwin-pkgs else import nixpkgs {
    system = system;
    config.allowUnfree = true;
  };

  lib = pkgs.lib;

  # e.g. char@my-box.
  userHost = "${user}@${name}";

  # entrypoint module to machine configuration.
  #machineModule = ../machines/${name}/default.nix;

  # entrypoint module to home configuration.
  homeModule = ../home/${userHost}/default.nix;

  # get platform-specific home-manager modules.
  homeModules = if darwin then inputs.home-manager.darwinModules else inputs.home-manager.nixosModules;

  homeFactory = inputs.home-manager.lib.homeManagerConfiguration;
}

