{pkgs, ...}: {
  programs.alacritty = {
    enable = true;

    settings = {
      window = {
        title = "Terminal";
        opacity = 0.85;

        padding = { y = 16; x = 18; };
        dynamic_padding = false;
        decorations = "buttonless";
      };

      font = {
        normal.family = "SFMono Nerd Font";
        size = 22.0;
      };

      shell = { program = "${pkgs.fish}/bin/fish"; };

      colors = {
        primary = {
          background = "0x000000";
          foreground = "0xEBEBEB";
        };
        cursor = {
          text = "0xFF261E";
          cursor = "0xFF261E";
        };
        normal = {
          black = "0x0D0D0D";
          red = "0xFF301B";
          green = "0xA0E521";
          yellow = "0xFFC620";
          blue = "0x178AD1";
          magenta = "0x9f7df5";
          cyan = "0x21DEEF";
          white = "0xEBEBEB";
        };
        bright = {
          black = "0x6D7070";
          red = "0xFF4352";
          green = "0xB8E466";
          yellow = "0xFFD750";
          blue = "0x1BA6FA";
          magenta = "0xB978EA";
          cyan = "0x73FBF1";
          white = "0xFEFEF8";
        };
      };
    };
  };

  home.sessionVariables = {
    SHELL = "fish";
  };
}
