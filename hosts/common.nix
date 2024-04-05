{ pkgs, ... }: {
  imports = [
  ];

  home = {
    stateVersion = "23.11";
    packages = with pkgs; [
      _1password
      bash
      colima
      devenv
      docker
      elixir
      erlang
      fish
      go
      grpcurl
      jq
      kns-fork.kns
      kubectl
      kubelogin
      kubelogin-oidc
      lua
      nodejs_21
      protobuf
      protoc-gen-go
      protoc-gen-go-grpc
      ripgrep
      tree
      vim
      zsh
    ];
  };

  programs.home-manager.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv = { enable = true; };
  };

  programs.fish = {
    enable = true;
  };

  programs.kitty = {
    enable = true;
    settings = {
      scrollback_lines = 100000;
      hide_window_decorations = "yes";
    };
  };

  programs.tmux = {
   enable = true;
   shell = "${pkgs.fish}/bin/fish";
   terminal = "tmux-256color";
   historyLimit = 100000;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  programs.fzf.enable = true;

  programs.bat = {
    enable = true;
    config.theme = "ansi";
  };
}
