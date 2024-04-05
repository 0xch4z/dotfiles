{ pkgs, nixpkgs, lib, ... }:

{
  imports = [
  ];

  environment.systemPackages = with pkgs;
    [
      coreutils
      ffmpeg
      fswatch
      fzf
      gnupg
      home-manager
      openssl
      tree
      wget
    ];

  programs.zsh.enable = true;

  programs.tmux = {
    enable = true;
  };

  system.stateVersion = 4;

  users.users.ckenney = {
    home = /Users/ckenney;
    shell = pkgs.fish;
  };

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };

  # allow authing with touch-id for sudo
  security.pam.enableSudoTouchIdAuth = true;

  nix = {
    nixPath = lib.mkForce [
      "nixpkgs=${nixpkgs}"
    ];
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  services.nix-daemon.enable = true;
}
