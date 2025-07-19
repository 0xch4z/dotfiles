{lib, config, ...}:
let
  cfg = config.x.role;
in {
  imports = [
    ./workstation.nix
  ];

  config = lib.mkIf (cfg == "mac-workstation") {
    x.home.tools.containers.colima.enable = true;
    x.home.desktop.backend = "none";
    x.home.applications.utility.caffeine.enable = true;
  };
}
