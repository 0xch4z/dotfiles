{ lib, config, homeDir, ... }:
let cfg = config.x.role;
in {
  imports = [ ./workstation.nix ];

  config = lib.mkIf (cfg == "mac-workstation") {
    x.home.tools.containers.colima.enable = true;
    x.home.desktop.backend = "aerospace";
    x.home.applications.utility.caffeine.enable = true;
    x.home.applications.utility.gitify.enable = true;
    x.home.fonts.apple-nerdfont.enable = true;

    x.home.theme.font.mono = "SFMono Nerd Font";

    home.activation = {
      "setWallpaper" = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        set -e
        echo "[+] setting wallpaper"

        /usr/bin/osascript -e 'tell application "Finder" to set desktop picture to POSIX file "${homeDir}/.dotfiles/assets/philly-light.jpg"'
      '';
    };
  };
}
