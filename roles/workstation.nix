{ pkgs, lib, ... }: {
  fonts.fontconfig = {
    enable = lib.mkDefault true;

    defaultFonts = {
      monospace = [ "Source Code Pro" ];
      sansSerif = [ "Noto Sans" ];
      serif = [ "Noto Serif" ];
    };
  };

  home.packages = with pkgs; [
    # fonts
    inter
    noto-fonts
    noto-fonts-color-emoji
    font-awesome

    # home
    xdg-utils

    # fonts
    font-awesome
    fira-mono
    nerd-fonts.fira-code
    lato
    fontconfig

    # remote util
    rsync

    # network util
    bandwhich
    curl
    grpcurl
    httpie
    jwt-cli
    netcat
    nmap
    speedtest-cli

    # dev
    codespell
    editorconfig-core-c
    #mimir
    tree-sitter

    # viewers
    bat
    eza
    glow

    # system
    htop
    tmux

    # keyboard
    # via

    # utility
    file
    grc
    watch
    wget
    #pinentry

    # misc
    typespeed
  ];

  programs.home-manager.enable = lib.mkDefault true;

  x.home = {
    applications = {
      browser = {
        firefox.enable = lib.mkDefault true;
        zen.enable = lib.mkDefault true;
      };
      music = { spotify.enable = lib.mkDefault true; };
      passwords = { bitwarden.enable = lib.mkDefault true; };
      terminal.alacritty.enable = lib.mkDefault true;
      terminal.kitty.enable = lib.mkDefault true;
    };
    development.enable = lib.mkDefault true;
    editor = {
      neovim.enable = lib.mkDefault true;
      vscode.enable = lib.mkDefault true;
    };
    tools = {
      coreutils = "full";

      containers.enable = lib.mkDefault true;
      file.enable = lib.mkDefault true;
      infrastructure.enable = lib.mkDefault true;
      io.enable = lib.mkDefault true;
      networking.enable = lib.mkDefault true;
      productivity.enable = lib.mkDefault true;
      secrets.enable = lib.mkDefault true;
    };
  };
}
