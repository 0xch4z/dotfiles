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
    #../../pkgs/infra
    #../../pkgs/networking
    ../../pkgs/productivity
    ../../pkgs/shell
    ../../pkgs/terminal/kitty
    ../../pkgs/terminal/tmux
    ../../pkgs/utility
  ];

  xdg.enable = true;

  home = {
    stateVersion = "22.11";

    sessionPath = [
      "$HOME/.local/bin"
      "/usr/local/bin"
    ];

    sessionVariables = {
      EDITOR = "nvim";
      PAGER = "less";
    };

    packages = with pkgs; [
      # home
      xdg-utils

      # fonts
      font-awesome

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
      mimir
      tree-sitter

      # viewers
      bat
      eza
      glow

      # system
      htop
      tmux

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
