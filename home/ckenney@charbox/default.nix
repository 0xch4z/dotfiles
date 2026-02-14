{ lib, self, pkgs, ... }: {
  imports = [
    ../../profiles/nixos

    self.outputs.modules
  ];

  x.role = "nix-workstation";

  x.home.editor.neovim.nightly = true;

  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "FiraCode Nerd Font:size=12";
        terminal = "alacritty";
        icons-enabled = "yes";
        icon-theme = "hicolor";
        lines = 10;
        width = 40;
        horizontal-pad = 20;
        vertical-pad = 15;
        layer = "overlay";
        anchor = "top";
        y-margin = 8;
      };
      colors = {
        background = "000000dd";
        text = "ffffffff";
        match = "ff69b4ff";
        selection = "ff00ffff";
        selection-text = "ffffffff";
        selection-match = "ffffffdd";
        border = "ff69b480";
      };
      border = {
        width = 2;
        radius = 12;
      };
    };
  };

  home.stateVersion = lib.mkForce "22.11";
  home.homeDirectory = "/home/ckenney";
}
