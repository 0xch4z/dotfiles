{ den, lib, ... }:
{
  den.aspects.workstation = {
    includes = [
      den.aspects.development
      den.aspects.fonts
      den.aspects.theme
      den.aspects.shell
      den.aspects.browser
      den.aspects.terminal
      den.aspects.editor
      den.aspects.tools
      den.aspects.spotify
      den.aspects.bitwarden
      den.aspects.gitify
    ];

    homeManager = {
      home.sessionVariables = {
        AVANTE_DEFAULT_PROVIDER = "claude-code";
      };

      programs.home-manager.enable = lib.mkDefault true;

      x.home.tools.coreutils = "full";
    };
  };

  den.aspects.personal.homeManager = {
    programs.git.settings.user = {
      email = "me@ch4z.io";
      name = "Charlie Kenney";
    };
  };
  den.aspects.work.homeManager = {
    programs.git.settings.user = {
      email = "charles.kenney@isovalent.com";
      name = "Charlie Kenney";
    };
  };

  den.aspects.nix-workstation = {
    includes = [
      den.aspects.desktop
      den.aspects.hyprland
      den.aspects.ashell
      den.aspects.messaging
      den.aspects._1pass
    ];

    homeManager = {
      home = {
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
      };

      x.home.desktop.backend = lib.mkDefault "hyprland";
    };
  };

  den.aspects.mac-workstation = {
    includes = [
      den.aspects.colima
      den.aspects.caffeine
      den.aspects.gitify
      den.aspects.aerospace
    ];

    homeManager =
      {
        config,
        lib,
        ...
      }:
      {
        x.home.desktop.backend = "aerospace";
        x.home.fonts.apple-nerdfont.enable = true;
        x.home.theme.font.mono = "SFMono Nerd Font";

        home.activation = {
          "setWallpaper" = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            set -e
            echo "[+] setting wallpaper"

            /usr/bin/osascript -e 'tell application "Finder" to set desktop picture to POSIX file "${config.home.homeDirectory}/.dotfiles/assets/philly-light.jpg"'
          '';
        };
      };
  };
}
