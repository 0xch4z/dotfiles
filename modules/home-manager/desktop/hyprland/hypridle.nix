{ config, pkgs, lib, ... }:
let
  cfg = config.x.home.desktop.hyprland;
in {
  config = lib.mkIf cfg.enable {
  };
}
