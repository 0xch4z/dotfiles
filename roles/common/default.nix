{
  pkgs,
  ...
}: {
  imports = [
    ../../pkgs/cloud
    ../../pkgs/container
    ../../pkgs/dev
    ../../pkgs/fonts
    ../../pkgs/infra
    ../../pkgs/productivity
    ../../pkgs/shell
    ../../pkgs/terminal
    ../../pkgs/utility
  ];

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

  programs.home-manager.enable = true;

  home = {
    stateVersion = "22.11";

    sessionPath = [
      "$HOME/.local/bin"
      "/usr/local/bin"
      "/opt/homebrew/bin"
    ];

    sessionVariables = {
      EDITOR = "nvim";
      PAGER = "less";
      TERMINAL = "alacritty";
    };

    packages = with pkgs; [
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
  };
}
