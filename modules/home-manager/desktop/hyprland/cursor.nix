{ config, pkgs, lib, ... }:
let
  cfg = config.x.home.desktop;
in {
  config = lib.mkIf (cfg.backend == "hyprland") {
    home.packages = with pkgs; [
      capitaine-cursors
    ];

    home.pointerCursor = {
      name = "capitaine-cursors";
      package = pkgs.capitaine-cursors;
      size = 24;
      gtk.enable = true;
      x11.enable = true;
    };
  };
}
