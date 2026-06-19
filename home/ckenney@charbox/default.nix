{ den, ... }:
{
  den.aspects.charbox.ckenney = {
    includes = [
      den.aspects.workstation
      den.aspects.personal
      den.aspects.nix-workstation
      den.aspects.games
      den.batteries.primary-user
    ];

    homeManager = {
      x.home.editor.neovim.nightly = false;

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

      home.stateVersion = "22.11";
      home.homeDirectory = "/home/ckenney";
    };
  };
}
