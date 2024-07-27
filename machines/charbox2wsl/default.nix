{
  lib,
  inputs,
  nixpkgs,
  pkgs,
  ...
}: {
  environment.shells = [pkgs.fish];
  environment.enableAllTerminfo = true;

  programs.fish.enable = true;

  environment.systemPackages = with pkgs; [
      coreutils
      ffmpeg
      fswatch
      fzf
      gnupg
      home-manager
      kitty
      openssl
      mods
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.char = {
      imports = [
        ../../profiles/nixos
        ../../roles/nixos
      ];
    };
  };

  users.users.char = {
    name = "char";
    home = "/home/char";
    shell = pkgs.fish;
  };

  wsl = {
    enable = true;
    defaultUser = "char";
    startMenuLaunchers = true;
  };

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

    package = pkgs.nixUnstable;
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
