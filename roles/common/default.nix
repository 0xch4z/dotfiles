{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../pkgs/cloud
    ../../pkgs/container
    ../../pkgs/dev
    ../../pkgs/editor/neovim
    ../../pkgs/fonts
    ../../pkgs/infra
    #../../pkgs/networking
    ../../pkgs/productivity
    ../../pkgs/shell
    ../../pkgs/terminal
    ../../pkgs/utility
  ];

  xdg.enable = true;

  fonts.fontconfig.enable = true;

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

      # misc
      typespeed
    ];
  };
}
