{ config, lib, pkgs, ... }:
let
  cfg = config.x.programs.nix-ld;
in {
  options.x.programs.nix-ld = {
    enable = lib.mkEnableOption "nix-ld with common libraries";
  };

  config = lib.mkIf cfg.enable {
    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [
      stdenv.cc.cc.lib
      zlib
      libpng
      libjpeg
      openssl
      bzip2
      xz
      ncurses
      readline
      sqlite
      libffi
      expat
      libxml2
      libxslt
      libGL
      mesa
      glib
      gtk3
      libx11
      libxext
      libxrender
      libxi
      libxrandr
      libxcursor
      libxinerama
      libxxf86vm
    ];
  };
}
