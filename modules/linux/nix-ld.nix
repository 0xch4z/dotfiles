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
      xorg.libX11
      xorg.libXext
      xorg.libXrender
      xorg.libXi
      xorg.libXrandr
      xorg.libXcursor
      xorg.libXinerama
      xorg.libXxf86vm
    ];
  };
}
