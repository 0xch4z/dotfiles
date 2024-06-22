{pkgs, ...}: {
  xdg.configFile."tmux" = {
    source = ./config;
    recursive = true;
  };

  programs.tmux = {
   enable = true;
   shell = "${pkgs.fish}/bin/fish";
   terminal = "tmux-256color";
   historyLimit = 100000;
  };
}
