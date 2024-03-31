{ pkgs, ... }: {
  imports = [
  ];

  home = {
    stateVersion = "23.11";
    packages = with pkgs; [
      jq
      lua
      ripgrep
      tree
      vim
    ];
  };

  programs.direnv = {
    enable = true;
    nix-direnv = { enable = true; };
  };

  programs.kitty = {
    enable = true;
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
