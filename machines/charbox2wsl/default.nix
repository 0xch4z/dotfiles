{
  lib,
  inputs,
  nixpkgs,
  pkgs,
  hostname,
  ...
}: {
  imports = [
    inputs.wsl.nixosModules.default
  ];

  programs.fish.enable = true;

  users.users.char = {
    name = "char";
    home = "/home/char";
    shell = pkgs.fish;
  };

  networking.hostName = hostname;

  wsl = {
    enable = true;
    defaultUser = "char";
    startMenuLaunchers = true;
    useWindowsDriver = true;
    wslConf = {
      automount.root = "/mnt";
      interop.appendWindowsPath = true;
      network.generateHosts = false;
    };
  };

  services.xserver.enable = true;
  services.xserver.windowManager.xmonad = {
    enable = true;
    enableContribAndExtras = true;
  };

  hardware.graphics.enable = true;
  hardware.graphics.extraPackages = [pkgs.mesa.drivers];

  nix = {
    settings = {
      trusted-users = ["char"];
      accept-flake-config = true;
    };

    registry = {
      nixpkgs = {
        flake = inputs.nixpkgs;
      };
    };

    nixPath = [
      "nixpkgs=${nixpkgs}"
      "nixos-config=/etc/nixos/configuration.nix"
      "/nix/var/nix/profiles/per-user/root/channels"
    ];

    package = pkgs.nixVersions.latest;
    extraOptions = ''experimental-features = nix-command flakes'';

    gc = {
      automatic = true;
      options = "--delete-older-than-7d";
    };
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = "24.05";
}
