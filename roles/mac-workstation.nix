{lib, config, ...}:
let
  cfg = config.x.role;
in {
  imports = [
    ./workstation.nix
  ];

  config = lib.mkIf (cfg == "mac-workstation") {
    x.home.tools.containers.colima.enable = true;
    x.home.desktop.backend = "aerospace";
    x.home.applications.utility.caffeine.enable = true;
    x.home.fonts.apple-nerdfont.enable = true;

    x.home.theme.font.mono = "SFMono Nerd Font";
  };
}
