{pkgs, lib, ...}:
let
  inherit (lib) mkDefault;

  mkTrue = true;
in {

  # TODO move out of here
  xdg.enable = true;
  gtk.font.name = "Inter";
  gtk.font.size = 10;
  fonts.fontconfig = {
    enable = true;

    defaultFonts = {
      monospace = ["Source Code Pro"];
      sansSerif = ["Noto Sans"];
      serif = ["Noto Serif"];
    };
  };

  home.packages = with pkgs; [
    # fonts
    inter
    noto-fonts
    noto-fonts-emoji
    font-awesome

    # home
    xdg-utils

    # fonts
    font-awesome
    fira-mono
    fira-code-nerdfont
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
    pinentry

    # misc
    typespeed
  ];

  programs.home-manager.enable = true;

  x.home = {
    browser = {
      firefox.enable = mkTrue;
      zen.enable = mkTrue;
    };
    development.enable = mkTrue;
    editor = {
      neovim.enable = mkTrue;
      vscode.enable = mkTrue;
    };
    terminal.alacritty.enable = mkTrue;
    tools = {
      containers.enable = mkTrue;
      infrastructure.enable = mkTrue;
      networking.enable = mkTrue;
      productivity.enable = mkTrue;
      secrets.enable = mkTrue;
    };
  };
}
